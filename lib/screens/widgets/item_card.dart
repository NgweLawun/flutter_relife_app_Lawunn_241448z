import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String label;
  final String? status; // pending, approved, declined, removed
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.label,
    this.status,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'removed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black38),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported_outlined, color: Colors.black26),
                    ),
                  ),
                ),
                if (status != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status![0].toUpperCase() + status!.substring(1),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Post Title: ' + title,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // const SizedBox(height: 8),
          // Text(
          //   'Description: ' + label,
          //   style: const TextStyle(fontSize: 14),
          //   maxLines: 1,
          //   overflow: TextOverflow.ellipsis,
          // ),
        ],
      ),
    );
  }
}
