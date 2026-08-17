import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_cpmad/model/mappage.dart';
import '../model/item.dart';
import '../model/item_service.dart';
import 'package:location/location.dart';

class AddItemPage extends StatelessWidget {
  final Item? editItem;
  final ValueNotifier<LocationData?> userLocation = ValueNotifier<LocationData?>(null);
  final location = Location();

  Future<LocationData?> _getLocation() async { 
    LocationData? currentLocation; 
    try { 
      currentLocation = await location.getLocation(); 
    } catch (e) { 
      currentLocation = null; 
    } 
    return currentLocation; 
  } 

  late final _titleController = TextEditingController(text: editItem?.title ?? '');
  late final _descController = TextEditingController(text: editItem?.description ?? '');
  late final _locationController = TextEditingController(text: editItem?.pickupLocation ?? '');

  late final ValueNotifier<String> _categoryNotifier =
      ValueNotifier(editItem != null && _categories.contains(editItem!.category) ? editItem!.category : 'Household');
  final ValueNotifier<File?> _imageFileNotifier = ValueNotifier(null);
  late final ValueNotifier<String?> _existingImageUrlNotifier = ValueNotifier(editItem?.imageUrl);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier(false);

  final _itemService = ItemService();

  final List<String> _categories = ['Household', 'Books', 'Electronics', 'Furniture', 'Other'];

  bool get _isEditing => editItem != null;

  AddItemPage({super.key, this.editItem});

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      _imageFileNotifier.value = File(picked.path);
    }
  }

  Future<void> _submit(BuildContext context) async {
    final hasImage = _imageFileNotifier.value != null || _existingImageUrlNotifier.value != null;
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and add a photo')),
      );
      return;
    }

    _isSavingNotifier.value = true;

    try {
      final imageUrl = _imageFileNotifier.value != null
          ? await _itemService.uploadImage(_imageFileNotifier.value!)
          : _existingImageUrlNotifier.value!;

      if (_isEditing) {
        await _itemService.updateItem(
          itemId: editItem!.id,
          title: _titleController.text,
          description: _descController.text,
          imageUrl: imageUrl,
          category: _categoryNotifier.value,
          pickupLocation: userLocation.value != null
              ? '${userLocation.value!.latitude}, ${userLocation.value!.longitude}'
              : _locationController.text,
        );
      } else {
        await _itemService.addItem(
          title: _titleController.text,
          description: _descController.text,
          imageUrl: imageUrl,
          category: _categoryNotifier.value,
          pickupLocation: userLocation.value != null
              ? '${userLocation.value!.latitude}, ${userLocation.value!.longitude}'
              : _locationController.text,
        );
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save item: $e')),
        );
      }
    } finally {
      _isSavingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(_isEditing ? 'Edit Item' : 'Give Away an Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ValueListenableBuilder<File?>(
              valueListenable: _imageFileNotifier,
              builder: (context, imageFile, child) {
                return GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(imageFile, fit: BoxFit.cover),
                          )
                        : _existingImageUrlNotifier.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(_existingImageUrlNotifier.value!, fit: BoxFit.cover),
                              )
                            : const Center(
                                child: Icon(Icons.add_a_photo, size: 40, color: Colors.black38)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Item Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: _categoryNotifier,
              builder: (context, category, child) {
                return DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => _categoryNotifier.value = val!,
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<LocationData?>
            (
              valueListenable: userLocation, 
              
              builder: (context, currentLocation, _){
                
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async{
                          userLocation.value = await _getLocation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Get Current Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),   ),
                        const SizedBox(height: 16),
                        currentLocation == null 
                        ? const CircularProgressIndicator() 
                        : Text('Location: ${currentLocation.latitude} ${currentLocation.longitude}'),
                    ElevatedButton(
                      onPressed: () {
                        if (currentLocation == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(
                              location: LatLng(currentLocation.latitude!, currentLocation.longitude!),
                            ),
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
                    ],
                  );
              }
            ),
                
            
              

            // TextField(
            //   controller: _locationController,
            //   decoration: const InputDecoration(
            //     labelText: 'Pick-up Location',
            //     border: OutlineInputBorder(),
            //   ),
         
            const SizedBox(height: 24),
            ValueListenableBuilder<bool>(
              valueListenable: _isSavingNotifier,
              builder: (context, isSaving, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: isSaving ? null : () => _submit(context),
                    child: isSaving
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isEditing ? 'Update Item' : 'Post Item', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}