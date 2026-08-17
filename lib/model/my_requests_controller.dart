import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item_request.dart';
import 'item_service.dart';
import 'request_service.dart';

class MyRequestsController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final RequestService _requestService = RequestService();
  final ItemService _itemService = ItemService();

  List<ItemRequest> _myRequests = [];
  Set<String> _existingItemIds = {};
  bool _itemsLoaded = false;
  bool isLoading = true;
  StreamSubscription? _requestsSub;
  StreamSubscription? _itemsSub;

  String _query = '';

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  MyRequestsController() {
    _listenToItems();
    _listenToRequests();
  }

  void _listenToItems() {
    _itemsSub = _itemService.getItemsStream().listen((items) {
      _existingItemIds = items.map((i) => i.id).toSet();
      _itemsLoaded = true;
      notifyListeners();
    });
  }

  void _listenToRequests() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    _requestsSub = _requestService.getRequestsStream().listen((requests) {
      _myRequests = requests.where((r) => r.requesterId == currentUserId).toList();
      isLoading = false;
      notifyListeners();
    });
  }


  String effectiveStatus(ItemRequest request) {
    final isActive = request.status == 'pending' || request.status == 'approved';
    if (_itemsLoaded && isActive && !_existingItemIds.contains(request.itemId)) {
      return 'removed';
    }
    return request.status;
  }

  List<ItemRequest> get filteredRequests {
    if (_query.isEmpty) return _myRequests;
    return _myRequests
        .where((r) => r.itemTitle.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  void onSearchChanged(String value) {
    _query = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    searchController.dispose();
    _requestsSub?.cancel();
    _itemsSub?.cancel();
    super.dispose();
  }
}
