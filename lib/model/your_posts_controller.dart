import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_cpmad/model/item_service.dart';
import 'item.dart';
import 'item_service.dart';

class YourPostsController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final ItemService _itemService = ItemService();

  List<Item> _myItems = [];
  bool isLoading = true;
  StreamSubscription? _itemsSub;

  String _query = '';

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  YourPostsController() {
    _listenToItems();
  }

  void _listenToItems() {

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    _itemsSub = _itemService.getItemsStream().listen((items) {
      _myItems = items.where((item) => item.ownerId == currentUserId).toList();
      isLoading = false;
      notifyListeners();
    });
  }

  List<Item> get filteredItems {
    if (_query.isEmpty) return _myItems;
    return _myItems
        .where((item) =>
            item.title.toLowerCase().contains(_query.toLowerCase()) ||
            item.description.toLowerCase().contains(_query.toLowerCase()))
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
    _itemsSub?.cancel();
    super.dispose();
  }
}
