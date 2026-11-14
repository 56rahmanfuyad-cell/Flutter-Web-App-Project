import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_project/login_page.dart';
import 'package:my_project/services/supabase_service.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  late Future<Map<String, dynamic>?> profileFuture;
  bool isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    profileFuture = SupabaseService.fetchCurrentProfile();
  }

  Future<void> logOut() async {
    try {
      await SupabaseService.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not log out: $error')),
      );
    }
  }

  Future<void> editProfile(Map<String, dynamic> profile) async {
    final nameController = TextEditingController(
      text: profile['name']?.toString() ?? '',
    );
    final universityController = TextEditingController(
      text: profile['university']?.toString() ?? '',
    );
    final departmentController = TextEditingController(
      text: profile['department']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: profile['phone_number']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2D2B42),
        title: const Text('Complete profile details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              TextField(
                controller: universityController,
                decoration: const InputDecoration(labelText: 'University'),
              ),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone number'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                isSavingProfile ? null : () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isSavingProfile
                ? null
                : () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name cannot be empty.')),
                      );
                      return;
                    }
                    final userId = SupabaseService.currentUserId;
                    if (userId == null) return;

                    setState(() => isSavingProfile = true);
                    try {
                      await SupabaseService.saveProfile(
                        userId: userId,
                        name: nameController.text.trim(),
                        university: universityController.text.trim().isEmpty
                            ? null
                            : universityController.text.trim(),
                        department: departmentController.text.trim().isEmpty
                            ? null
                            : departmentController.text.trim(),
                        phoneNumber: phoneController.text.trim().isEmpty
                            ? null
                            : phoneController.text.trim(),
                      );

                      if (!mounted) return;
                      setState(() {
                        isSavingProfile = false;
                        profileFuture = SupabaseService.fetchCurrentProfile();
                      });
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated.')),
                      );
                    } catch (error) {
                      if (!mounted) return;
                      setState(() => isSavingProfile = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Could not update profile: $error')),
                      );
                    }
                  },
            child: isSavingProfile
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );

    nameController.dispose();
    universityController.dispose();
    departmentController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E2C),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9370DB)),
            );
          }

          if (snapshot.hasError) {
            return _buildMessage(
              'Could not load your profile. Please try again.\n${snapshot.error}',
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            final email = SupabaseService.currentUserEmail;
            final emailLabel = email ?? 'Email unavailable';
            return _buildMessage(
              'No profile was found for this account. If you just confirmed '
              'your email, log in again to save your registration details.\n'
              'Signed in as: $emailLabel',
            );
          }

          final name = profile['name'] as String?;
          final university = profile['university'] as String?;
          final department = profile['department'] as String?;
          final phoneNumber = profile['phone_number'] as String?;
          final email = SupabaseService.currentUserEmail;
          final departmentLabel =
              department?.isNotEmpty == true ? department : 'Not added yet';
          final phoneLabel =
              phoneNumber?.isNotEmpty == true ? phoneNumber : 'Not added yet';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2E1A47),
                        Color(0xFF512B81),
                        Color(0xFF9370DB),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name == null || name.isEmpty ? 'Name missing' : name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        university == null || university.isEmpty
                            ? 'University not provided'
                            : university,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: const Color(0xFF2D2B42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                color: Color(0xFF9370DB),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  email ?? 'Email not available',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Department: $departmentLabel',
                            style: GoogleFonts.poppins(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Phone: $phoneLabel',
                            style: GoogleFonts.poppins(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => editProfile(profile),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: logOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Log out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9370DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off, size: 48, color: Color(0xFF9370DB)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: logOut,
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
