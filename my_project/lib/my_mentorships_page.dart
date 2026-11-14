import 'package:flutter/material.dart';
import 'package:my_project/create_mentorship_page.dart';
import 'package:my_project/services/supabase_service.dart';

class MyMentorshipsPage extends StatefulWidget {
  const MyMentorshipsPage({super.key});

  @override
  State<MyMentorshipsPage> createState() => _MyMentorshipsPageState();
}

class _MyMentorshipsPageState extends State<MyMentorshipsPage> {
  late Future<List<Map<String, dynamic>>> mentorshipsFuture;
  String? deletingId;

  @override
  void initState() {
    super.initState();
    mentorshipsFuture = fetchMyMentorships();
  }

  Future<List<Map<String, dynamic>>> fetchMyMentorships() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    final response = await SupabaseService.client
        .from('mentorships')
        .select('id, user_id, title, price')
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> openForm({Map<String, dynamic>? mentorship}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMentorshipPage(mentorship: mentorship),
      ),
    );

    if (!mounted || saved != true) return;

    setState(() => mentorshipsFuture = fetchMyMentorships());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mentorship == null ? 'Skill listing added.' : 'Listing updated.',
        ),
      ),
    );
  }

  Future<void> deleteMentorship(Map<String, dynamic> mentorship) async {
    final userId = SupabaseService.currentUserId;
    final listingId = mentorship['id'];
    if (userId == null ||
        mentorship['user_id'] != userId ||
        listingId == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text('Only this mentorship listing will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final idText = listingId.toString();
    setState(() => deletingId = idText);
    try {
      final deletedRows = await SupabaseService.client
          .from('mentorships')
          .delete()
          .eq('id', listingId)
          .eq('user_id', userId)
          .select('id');

      if (!mounted) return;
      if (deletedRows.isEmpty) {
        throw Exception('The listing was not deleted. Check your access.');
      }

      setState(() {
        mentorshipsFuture = fetchMyMentorships();
        deletingId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => deletingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete listing: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Mentorships'),
        backgroundColor: const Color(0xFF1E1E2C),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: mentorshipsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF9370DB),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child:
                        Text('Could not load your listings: ${snapshot.error}'),
                  );
                }

                final mentorships = snapshot.data ?? [];
                if (mentorships.isEmpty) {
                  return const Center(
                    child: Text('You have not added any skills yet.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mentorships.length,
                  itemBuilder: (context, index) {
                    final mentorship = mentorships[index];
                    final id = mentorship['id'].toString();
                    return Card(
                      color: const Color(0xFF2D2B42),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mentorship['title']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Price: \u09F3${mentorship['price'] ?? ''} BDT',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      openForm(mentorship: mentorship),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit'),
                                ),
                                TextButton.icon(
                                  onPressed: deletingId == id
                                      ? null
                                      : () => deleteMentorship(mentorship),
                                  icon: deletingId == id
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.delete_outline),
                                  label: const Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Another Skill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9370DB),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
