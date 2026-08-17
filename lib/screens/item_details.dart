import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_cpmad/model/item_request.dart';
import 'package:project_cpmad/model/report_service.dart';
import 'package:project_cpmad/model/request_service.dart';
import '../model/item.dart';
import '../model/mappage.dart';
import 'my_requests.dart';

// item.pickupLocation is free text unless it was set via the "Get Current
// Location" button in add_item.dart, which stores it as "lat, lng" — that's
// the only form the map can actually show.
LatLng? _parsePickupLocation(String pickupLocation) {
  final parts = pickupLocation.split(',');
  if (parts.length != 2) return null;
  final lat = double.tryParse(parts[0].trim());
  final lng = double.tryParse(parts[1].trim());
  if (lat == null || lng == null) return null;
  return LatLng(lat, lng);
}


class ItemDetailsPage extends StatelessWidget {
  final Item item;

  final TextEditingController _collectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ValueNotifier<int> _ratingNotifier = ValueNotifier<int>(0);
  final RequestService _requestService = RequestService();
  final ReportService _reportService = ReportService();

  ItemDetailsPage({super.key, required this.item});

  Future<void> _reportPost(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Report this post'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Scam'),
            child: const Text('Scam'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Inappropriate'),
            child: const Text('Inappropriate content'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Other'),
            child: const Text('Other'),
          ),
        ],
      ),
    );

    if (reason == null) return;

    try {
      await _reportService.reportPost(itemId: item.id, ownerId: item.ownerId, reason: reason);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post reported. Thanks for letting us know.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _submitRequest(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (user.uid == item.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't request your own post.")),
      );
      return;
    }

    if (_collectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please let the owner know when you can collect')),
      );
      return;
    }

    final alreadyReserved = await _requestService.isItemReserved(item.id);
    if (alreadyReserved) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item has already been given away.')),
      );
      return;
    }

    final newRequest = ItemRequest(
      id: '',
      itemId: item.id,
      itemTitle: item.title,
      itemImageUrl: item.imageUrl,
      ownerId: item.ownerId,
      ownerEmail: item.ownerEmail,
      requesterId: user.uid,
      requesterEmail: user.email ?? '',
      collectTime: _collectController.text.trim(),
      message: _messageController.text.trim(),
      rating: _ratingNotifier.value,
      status: 'pending',
    );

    try {
      await _requestService.addRequest(newRequest);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyRequestsPage()),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        title: const Text('Request Item Page'),
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // To: <owner of the item>
              Text(
                'To: ${item.ownerEmail}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
            
              // Post Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Post Title',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  if (FirebaseAuth.instance.currentUser?.uid != item.ownerId)
                    OutlinedButton.icon(
                      onPressed: () => _reportPost(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.block, size: 16),
                      label: const Text('Report this post', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
                // collection Locaiton

              // Item photo, carried over from the Home page card
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(item.imageUrl, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                item.description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Text(
                'Collection Location: ${item.pickupLocation}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

               ElevatedButton(
                      onPressed: () {
                        final location = _parsePickupLocation(item.pickupLocation);
                        if (location == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No map coordinates available for this location')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(location: location),
                          ),
                        );
                  },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.yellow,
                backgroundColor: Colors.deepOrange,
                elevation: 5,
              ),
              child: const Text(
                'Show Map',
                style: TextStyle(color: Colors.white),
              ),
            ),

              const SizedBox(height: 20),
              _RequestSection(
                item: item,
                requestService: _requestService,
                collectController: _collectController,
                messageController: _messageController,
                ratingNotifier: _ratingNotifier,
                onSubmit: () => _submitRequest(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestSection extends StatelessWidget {
  final Item item;
  final RequestService requestService;
  final TextEditingController collectController;
  final TextEditingController messageController;
  final ValueNotifier<int> ratingNotifier;
  final VoidCallback onSubmit;

  const _RequestSection({
    required this.item,
    required this.requestService,
    required this.collectController,
    required this.messageController,
    required this.ratingNotifier,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId != null && currentUserId == item.ownerId;

    if (isOwner) {
      return const _BlockedNotice(message: "This is your own post — you can't request it.");
    }

    return StreamBuilder<bool>(
      stream: requestService.isItemReservedStream(item.id),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return const _BlockedNotice(message: 'This item has already been given away.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'When could you collect?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: collectController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintText: 'e.g. Tomorrow 6pm',
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Message',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintText: 'Say something to the owner...',
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Rate this post',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ValueListenableBuilder<int>(
              valueListenable: ratingNotifier,
              builder: (context, rating, _) {
                return Row(
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        starIndex <= rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 28,
                      ),
                      onPressed: () => ratingNotifier.value = starIndex,
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 8),

            const Text(
              'Warning: Please collect within 48 hours or the request will get cancelled.',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onSubmit,
                child: const Text('Request'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BlockedNotice extends StatelessWidget {
  final String message;

  const _BlockedNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.black45),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}