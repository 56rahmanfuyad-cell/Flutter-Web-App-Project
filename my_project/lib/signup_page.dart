import 'package:flutter/material.dart';
import 'package:my_project/home_page.dart';
import 'package:my_project/services/supabase_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  Future<void> registerUserAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final authResponse = await SupabaseService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
        university: universityController.text.trim(),
        department: departmentController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );

      final user = authResponse.user;
      if (!mounted) return;
      if (authResponse.session != null && user != null) {
        await SupabaseService.saveProfile(
          userId: user.id,
          name: nameController.text.trim(),
          university: universityController.text.trim(),
          department: departmentController.text.trim(),
          phoneNumber: phoneController.text.trim(),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Check your email to confirm your account. Your profile will be saved after you log in.',
            ),
          ),
        );
      } else {
        throw Exception('Supabase did not return a new user account.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    universityController.dispose();
    departmentController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: const Color(0xFF1E1E2C)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', filled: true, fillColor: Color(0xFF2D2B42)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: universityController,
                  decoration: const InputDecoration(labelText: 'University', filled: true, fillColor: Color(0xFF2D2B42)),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Enter your university'
                      : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    filled: true,
                    fillColor: Color(0xFF2D2B42),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Enter your department'
                      : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Include country code if needed',
                    filled: true,
                    fillColor: Color(0xFF2D2B42),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Enter your phone number'
                      : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Address', filled: true, fillColor: Color(0xFF2D2B42)),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter email';
                    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    return emailPattern.hasMatch(val.trim())
                        ? null
                        : 'Enter a valid email address';
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFF2D2B42),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                    ),
                  ),
                  validator: (val) {
                    if (val == null ||
                        !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(val)) {
                      return 'Use 8+ characters with uppercase, lowercase, and a number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    filled: true,
                    fillColor: const Color(0xFF2D2B42),
                    suffixIcon: IconButton(
                      icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(
                        () => isConfirmPasswordVisible = !isConfirmPasswordVisible,
                      ),
                    ),
                  ),
                  validator: (val) => val == passwordController.text
                      ? null
                      : 'Passwords do not match',
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUserAccount,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9370DB)),
                    child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('REGISTER'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
