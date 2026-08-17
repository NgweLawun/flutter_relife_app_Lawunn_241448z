import 'package:flutter/material.dart';
import 'aboutus.dart';
import 'add_item.dart';
import 'item_details.dart';
import 'profile.dart';
import '../model/userdata.dart';
import 'package:provider/provider.dart';
import '../model/home_controller.dart';
import '../model/item.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'your_posts.dart';
import 'requests_page.dart';
import 'my_requests.dart';
import 'widgets/item_card.dart';
import 'feedback_page.dart';


class Home extends StatelessWidget {

  final UserData userdata;

  const Home({
    super.key,

    required this.userdata,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  static const _categories = ['Household', 'Books', 'Electronics', 'Furniture', 'Other'];

  static const _allItemsValue = '__all__';

  Future<void> _showFilterMenu(BuildContext context, HomeController controller) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Items'),
                trailing: controller.selectedCategory == null ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () => Navigator.pop(context, _allItemsValue),
              ),
              for (final category in _categories)
                ListTile(
                  title: Text(category),
                  trailing: controller.selectedCategory == category
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () => Navigator.pop(context, category),
                ),
            ],
          ),
        );
      },
    );
    // Dismissed without choosing (e.g. tapped outside) — leave the filter as is.
    if (selected == null) return;
    controller.setCategory(selected == _allItemsValue ? null : selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      drawer: const _AppDrawer(),
      floatingActionButton: FloatingActionButton( 
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddItemPage()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Consumer<HomeController>(
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
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.pink.shade300,
                                  child: IconButton(
                                    icon: const Icon(Icons.filter_list, size: 18, color: Colors.white),
                                    onPressed: () => _showFilterMenu(context, controller),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.menu, size: 28),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      const Text('All Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      if (controller.selectedCategory != null) ...[
                        const SizedBox(width: 10),
                        Chip(
                          label: Text(controller.selectedCategory!, style: const TextStyle(fontSize: 12, color: Colors.white)),
                          backgroundColor: Colors.green,
                          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                          onDeleted: () => controller.setCategory(null),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ],
                  ),
                ),
                // 
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.loadError != null
                          ? Center(child: Text('Failed to load items: ${controller.loadError}'))
                          : controller.filteredItems.isEmpty
                          ? const Center(child: Text('No items yet — be the first to post one!'))
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                              itemCount: controller.filteredItems.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                              itemBuilder: (context, index) {
                                final item = controller.filteredItems[index];
                                return _ItemCard(item: item, status: controller.statusForItem(item.id));
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


class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final userdata = context.watch<UserData>();

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Hello, ${userdata.email}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.request_page),
              title: const Text('Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
          
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Your Posts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const YourPostsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feed Back'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('My Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyRequestsPage()));
              },
            ),

            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                FirebaseAuth.instance.signOut();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final String? status;

  const _ItemCard({required this.item, this.status});

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      imageUrl: item.imageUrl,
      title: item.title,
      label: item.description,
      status: status,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailsPage(item: item)),
        );
      },
    );
  }
}