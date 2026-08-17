import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use hardcoded values instead of querying Firestore
    const version = '1.0.0';
    const mission =
        'To promote sustainable living in our community by making it easy and rewarding to gift or upcycle unwanted items instead of throwing them away.';
    const developer = 'Ngwe Lawunn Phyu';
    const school = 'Nanyang Polytechnic';
    const course = 'Mobile App Development';
    const supportEmail = 'relife@nyp.edu.sg';
    const supportPhone = '+65 8170 3423';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text('About Smart Commute'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.recycling, color: Colors.green, size: 40),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'ReLife',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Version $version',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: 'Our Mission',
                    icon: Icons.rocket_launch,
                    content: mission,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    title: 'Developer',
                    icon: Icons.person,
                    content: 'Developed by: $developer\n'
                        'School: $school\n'
                        'Course: $course',
                  ),
                  const SizedBox(height: 15),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.contact_support, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Contact Support',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email, color: Colors.blue),
                            title: Text(supportEmail),
                          ),
                          ListTile(
                            leading: const Icon(Icons.phone, color: Colors.blue),
                            title: Text(supportPhone),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoCard({required String title, required IconData icon, required String content}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 15, height: 1.4)),
          ],
        ),
      ),
    );
  }
}