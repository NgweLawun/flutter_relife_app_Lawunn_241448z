import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/item_request.dart';
import '../model/requests_controller.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RequestsController(),
      child: const _RequestsView(),
    );
  }
}

class _RequestsView extends StatelessWidget {
  const _RequestsView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          elevation: 0,
          title: const Text('Requests'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: Consumer<RequestsController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _ReceivedList(requests: controller.receivedRequests, controller: controller),
                _SentList(requests: controller.sentRequests, controller: controller),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReceivedList extends StatelessWidget {
  final List<ItemRequest> requests;
  final RequestsController controller;

  const _ReceivedList({required this.requests, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(child: Text("You haven't received any requests yet."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        final status = controller.effectiveStatus(request);
        return _RequestCard(
          request: request,
          trailing: status == 'pending'
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Approve',
                      onPressed: () => controller.approve(request.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Decline',
                      onPressed: () => controller.decline(request.id),
                    ),
                  ],
                )
              : _StatusChip(status: status),
          subtitle: 'From: ${request.requesterEmail}',
        );
      },
    );
  }
}

class _SentList extends StatelessWidget {
  final List<ItemRequest> requests;
  final RequestsController controller;

  const _SentList({required this.requests, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(child: Text("You haven't sent any requests yet."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _RequestCard(
          request: request,
          trailing: _StatusChip(status: controller.effectiveStatus(request)),
          subtitle: 'To: ${request.ownerEmail}',
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ItemRequest request;
  final Widget trailing;
  final String subtitle;

  const _RequestCard({required this.request, required this.trailing, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.itemTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                trailing,
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            Text('Requester: ${request.requesterEmail}', style: const TextStyle(fontSize: 12, color: Colors.black45)),
            Text('Request ID: ${request.id}', style: const TextStyle(fontSize: 12, color: Colors.black45)),
            if (request.message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(request.message, style: const TextStyle(fontSize: 14)),
            ],
            const SizedBox(height: 8),
            Text('Collect: ${request.collectTime}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'declined':
        color = Colors.red;
        break;
      case 'removed':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }
    return Chip(
      label: Text(
        status[0].toUpperCase() + status.substring(1),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}