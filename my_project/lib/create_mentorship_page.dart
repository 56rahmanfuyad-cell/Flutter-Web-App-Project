import 'package:flutter/material.dart';
import 'package:my_project/services/supabase_service.dart';

class CreateMentorshipPage extends StatefulWidget {
  const CreateMentorshipPage({super.key, this.mentorship});

  final Map<String, dynamic>? mentorship;

  @override
  State<CreateMentorshipPage> createState() => _CreateMentorshipPageState();
}

class _CreateMentorshipPageState extends State<CreateMentorshipPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  bool isLoading = false;

  bool get isEditing => widget.mentorship != null;

  @override
  void initState() {
    super.initState();
    final mentorship = widget.mentorship;
    if (mentorship != null) {
      titleController.text = mentorship['title']?.toString() ?? '';
      descriptionController.text =
          mentorship['description']?.toString() ?? '';
      priceController.text = mentorship['price']?.toString() ?? '';
    }
  }

  Future<void> saveMentorship() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in before saving.')),
      );
      return;
    }

    setState(() => isLoading = true);
    final price = double.parse(priceController.text.trim());

    try {
      if (isEditing) {
        final updatedRows = await SupabaseService.client
            .from('mentorships')
            .update({
              'title': titleController.text.trim(),
              'description': descriptionController.text.trim(),
              'price': price,
            })
            .eq('id', widget.mentorship!['id'])
            .eq('user_id', userId)
            .select('id');

        if (updatedRows.isEmpty) {
          throw Exception('The listing was not updated. Check your access.');
        }
      } else {
        await SupabaseService.client.from('mentorships').insert({
          'user_id': userId,
          'title': titleController.text.trim(),
          // The existing database column is required, but the form no longer uses it.
          'category': '',
          'description': descriptionController.text.trim(),
          'price': price,
        });
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save mentorship: $error')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Mentorship' : 'Create Mentorship'),
        backgroundColor: const Color(0xFF1E1E2C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Skill or topic',
                  hintText: 'For example, Flutter Development',
                  filled: true,
                  fillColor: Color(0xFF2D2B42),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a skill or topic'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Color(0xFF2D2B42),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a description'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price in BDT',
                  prefixText: '\u09F3 ',
                  filled: true,
                  fillColor: Color(0xFF2D2B42),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a price';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || !price.isFinite) {
                    return 'Enter a valid number';
                  }
                  if (price < 0) return 'Price cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : saveMentorship,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(isEditing ? Icons.save : Icons.publish),
                  label: Text(
                    isLoading
                        ? 'Saving...'
                        : isEditing
                            ? 'Save Changes'
                            : 'Publish Mentorship',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9370DB),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
