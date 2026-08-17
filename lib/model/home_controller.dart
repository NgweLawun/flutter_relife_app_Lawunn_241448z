
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item.dart';
import 'item_service.dart';
import 'item_request.dart';
import 'request_service.dart';

class HomeController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final ItemService _itemService = ItemService();
  final RequestService _requestService = RequestService();

  List<Item> _allItems = [];
  List<ItemRequest> _allRequests = [];
  bool isLoading = true;
  String? loadError;
  StreamSubscription? _itemsSub;
  StreamSubscription? _requestsSub;

  String _query = '';
  String? selectedCategory;

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  HomeController() {
    _listenToItems();
    _listenToRequests();
  }


  bool get _isSignOutArtifact => FirebaseAuth.instance.currentUser == null;

  void _listenToItems(){
       _itemsSub = _itemService.getItemsStream().listen((items) {
      _allItems = items;
      isLoading = false;
      loadError = null;
      notifyListeners();
    }, onError: (Object error) {
      if (_isSignOutArtifact) return;
      isLoading = false;
      loadError = error.toString();
      notifyListeners();
        debugPrint('Items stream error: $error');
    });
  }

  void _listenToRequests() {
    _requestsSub = _requestService.getRequestsStream().listen((requests) {
      _allRequests = requests;
      notifyListeners();
    }, onError: (Object error) {
      if (_isSignOutArtifact) return;
      debugPrint('Requests stream error: $error');
    });
  }

  // Global status for this item, visible to every browsing user — not just
  // whoever sent the request. An approved request means the item is spoken
  // for; otherwise a pending one means someone's already asked for it.
  String? statusForItem(String itemId) {
    final itemRequests = _allRequests.where((r) => r.itemId == itemId);
    if (itemRequests.any((r) => r.status == 'approved')) return 'approved';
    if (itemRequests.any((r) => r.status == 'pending')) return 'pending';
    return null;
  }

  List<Item> get filteredItems {
    var items = _allItems;
    if (selectedCategory != null) {
      items = items.where((item) => item.category == selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      items = items
          .where((item) =>
              item.title.toLowerCase().contains(_query.toLowerCase()) ||
              item.description.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    return items;
  }

  void onSearchChanged(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(String? category) {
    selectedCategory = category;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _disposed = true;
    searchController.dispose();
    _itemsSub?.cancel();
    _requestsSub?.cancel();
    super.dispose();
  }
}