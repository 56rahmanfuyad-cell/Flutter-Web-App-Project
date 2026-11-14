import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_project/container_page.dart';
import 'package:my_project/create_mentorship_page.dart';
import 'package:my_project/login_page.dart';
import 'package:my_project/my_mentorships_page.dart';
import 'package:my_project/services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>?> profileFuture;
  late Future<List<Map<String, dynamic>>> mentorshipsFuture;

  @override
  void initState() {
    super.initState();
    profileFuture = SupabaseService.fetchCurrentProfile();
    mentorshipsFuture = fetchMentorships();
  }

  Future<List<Map<String, dynamic>>> fetchMentorships() async {
    final response = await SupabaseService.client.from('mentorships').select(
          'id, user_id, title, description, price, '
          'profiles(name, department, university, phone_number)',
        );
    return List<Map<String, dynamic>>.from(response);
  }

  String profileValue(dynamic profile, String field, String fallback) {
    if (profile is Map && profile[field] is String) {
      final value = profile[field] as String;
      if (value.trim().isNotEmpty) return value;
    }
    return fallback;
  }

  Future<void> openCreateMentorship() async {
    final published = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateMentorshipPage()),
    );

    if (!mounted || published != true) return;

    setState(() => mentorshipsFuture = fetchMentorships());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mentorship published successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campus Skill Share',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E2C),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: profileFuture,
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final name = profile?['name'] as String?;
                final university = profile?['university'] as String?;
                final accountName = snapshot.hasError
                    ? 'Profile unavailable'
                    : snapshot.connectionState == ConnectionState.waiting
                        ? 'Loading profile...'
                        : name == null || name.isEmpty
                            ? 'Profile not found'
                            : name;

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF2D2B42)),
                  accountName: Text(accountName),
                  accountEmail: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (university != null && university.isNotEmpty)
                        Text(university),
                      Text(
                        SupabaseService.currentUserEmail ?? 'Email unavailable',
                      ),
                    ],
                  ),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Color(0xFF9370DB),
                    child: Icon(Icons.person),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.home_outlined, color: Color(0xFF9370DB)),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_pin, color: Color(0xFF9370DB)),
              title: const Text('My Profile'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContainerPage()),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.school_outlined, color: Color(0xFF9370DB)),
              title: const Text('My Mentorships'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyMentorshipsPage(),
                  ),
                );
                if (!mounted) return;
                setState(() => mentorshipsFuture = fetchMentorships());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () async {
                try {
                  await SupabaseService.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not log out: $error')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Mentorships',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Learn from students across your campus community.'),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: mentorshipsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF9370DB)),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Text('Could not load mentorships.'),
                        TextButton(
                          onPressed: () => setState(
                            () => mentorshipsFuture = fetchMentorships(),
                          ),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No mentorships yet. Be the first to publish one!',
                    ),
                  );
                }

                final mentors = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mentors.length,
                  itemBuilder: (context, index) {
                    final mentorship = mentors[index];
                    final relatedProfile = mentorship['profiles'];
                    final providerName = profileValue(
                      relatedProfile,
                      'name',
                      'Student information unavailable',
                    );
                    final department = profileValue(
                      relatedProfile,
                      'department',
                      'Department not provided',
                    );
                    final university = profileValue(
                      relatedProfile,
                      'university',
                      'University not provided',
                    );
                    final phoneNumber = profileValue(
                      relatedProfile,
                      'phone_number',
                      '',
                    );
                    final departmentAndUniversity =
                        '$department \u00B7 $university';
                    final contactLabel =
                        phoneNumber.isEmpty ? 'Not provided' : phoneNumber;
                    return Card(
                      color: const Color(0xFF2D2B42),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFF41345F),
                                  child: Icon(
                                    Icons.school,
                                    color: Color(0xFFB69AEF),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        providerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        departmentAndUniversity,
                                        style: const TextStyle(
                                          color: Color(0xFFB69AEF),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mentorship['title']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD8C9FF),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(mentorship['description']?.toString() ?? ''),
                            const SizedBox(height: 8),
                            Text('Contact: $contactLabel'),
                            const SizedBox(height: 6),
                            Text(
                              '\u09F3${mentorship['price'] ?? ''} BDT',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB69AEF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openCreateMentorship,
        backgroundColor: const Color(0xFF9370DB),
        icon: const Icon(Icons.add),
        label: const Text('Create Mentorship'),
      ),
    );
  }
}
