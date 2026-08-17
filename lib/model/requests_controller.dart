import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item_request.dart';
import 'item_service.dart';
import 'request_service.dart';

class RequestsController extends ChangeNotifier {
  final RequestService _requestService = RequestService();
  final ItemService _itemService = ItemService();

  List<ItemRequest> _allRequests = [];
  Set<String> _existingItemIds = {};
  bool _itemsLoaded = false;
  bool isLoading = true;
  StreamSubscription? _requestsSub;
  StreamSubscription? _itemsSub;

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  RequestsController() {
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
    _requestsSub = _requestService.getRequestsStream().listen((requests) {
      _allRequests = requests;
      isLoading = false;
      notifyListeners();
    });
  }

  // Display-only: covers requests left pointing at an item that's gone — either
  // from before ItemService.deleteItem started cascading this, or a doc removed
  // some other way. Computed locally instead of written back, since any client
  // viewing this page may not have permission to edit someone else's request doc.
  String effectiveStatus(ItemRequest request) {
    final isActive = request.status == 'pending' || request.status == 'approved';
    if (_itemsLoaded && isActive && !_existingItemIds.contains(request.itemId)) {
      return 'removed';
    }
    return request.status;
  }

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  List<ItemRequest> get receivedRequests =>
      _allRequests.where((r) => r.ownerId == _currentUserId).toList();

  List<ItemRequest> get sentRequests =>
      _allRequests.where((r) => r.requesterId == _currentUserId).toList();

  Future<void> approve(String requestId) =>
      _requestService.updateStatus(requestId, 'approved');

  Future<void> decline(String requestId) =>
      _requestService.updateStatus(requestId, 'declined');

  Future<void> addSentRequest(ItemRequest request) async {
    await _requestService.addRequest(request);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestsSub?.cancel();
    _itemsSub?.cancel();
    super.dispose();
  }
}
