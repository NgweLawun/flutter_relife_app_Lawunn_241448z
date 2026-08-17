import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/item_request.dart';
import '../model/my_requests_controller.dart';
import 'widgets/item_card.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyRequestsController(),
      child: const _MyRequestsView(),
    );
  }
}

class _MyRequestsView extends StatelessWidget {
  const _MyRequestsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Consumer<MyRequestsController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: TextField(
                            controller: controller.searchController,
                            onChanged: controller.onSearchChanged,
                            decoration: const InputDecoration(
                              hintText: 'Search Your Requests',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.menu, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      Text('My Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.filteredRequests.isEmpty
                          ? const Center(child: Text("You haven't requested anything yet."))
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                              itemCount: controller.filteredRequests.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.62,
                              ),
                              itemBuilder: (context, index) {
                                final request = controller.filteredRequests[index];
                                return _MyRequestCard(
                                  request: request,
                                  status: controller.effectiveStatus(request),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MyRequestCard extends StatelessWidget {
  final ItemRequest request;
  final String status;

  const _MyRequestCard({required this.request, required this.status});

  String get _collectionStatus {
    if (status == 'removed') return 'Item removed by owner';
    if (status == 'declined') return 'Request declined';
    if (request.createdAt == null) return 'Just requested';

    final deadline = request.createdAt!.add(const Duration(hours: 48));
    final remaining = deadline.difference(DateTime.now());
    if (remaining.isNegative) return 'Collection window expired';

    final hours = remaining.inHours;
    if ( status == 'approved') return 'Collection ends in $hours hr';
    if (hours < 1) return 'Collection ends in ${remaining.inMinutes} min';
    // return 'Collection ends in $hours hr';
    return 'This is item is not approved';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ItemCard(
            imageUrl: request.itemImageUrl,
            title: request.itemTitle,
            label: request.itemTitle,
            status: status,
          ),
        ),
        Text(
          _collectionStatus,
          style: const TextStyle(fontSize: 12, color: Colors.red),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Requester: ${request.requesterEmail}',
          style: const TextStyle(fontSize: 11, color: Colors.black45),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Request ID: ${request.id}',
          style: const TextStyle(fontSize: 11, color: Colors.black45),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
