import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_project/home_page.dart';
import 'package:my_project/services/supabase_service.dart';
import 'package:my_project/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> authenticateUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      // Authenticates user against Supabase Auth database
      final response = await SupabaseService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Look up this account's profile by its Auth UUID.
      var profile = await SupabaseService.fetchCurrentProfile();

      // If email confirmation delayed profile creation, use the original
      // signup metadata to create its row, then fetch that row again.
      final metadata = response.user?.userMetadata;
      final name = metadata?['name'] ?? metadata?['full_name'];
      if (profile == null &&
          response.user != null &&
          name is String &&
          name.trim().isNotEmpty) {
        final university = metadata?['university'];
        await SupabaseService.saveProfile(
          userId: response.user!.id,
          name: name.trim(),
          university: university is String ? university : null,
          department: metadata?['department'] is String
              ? metadata!['department'] as String
              : null,
          phoneNumber: metadata?['phone_number'] is String
              ? metadata!['phone_number'] as String
              : null,
        );
        profile = await SupabaseService.fetchCurrentProfile();
      }

      if (!mounted) return;
      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You are signed in, but no profile row was found for this account.',
            ),
          ),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not complete login: $error')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 75, color: Color(0xFF9370DB)),
                const SizedBox(height: 15),
                Text('Campus Skill Share',
                    style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 35),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon:
                        const Icon(Icons.email, color: Color(0xFF9370DB)),
                    filled: true,
                    fillColor: const Color(0xFF2D2B42),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Enter email';
                    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    return emailPattern.hasMatch(value.trim())
                        ? null
                        : 'Enter a valid email address';
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFF9370DB)),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => isPasswordVisible = !isPasswordVisible),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2D2B42),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : authenticateUser,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9370DB)),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('LOGIN'),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupPage())),
                  child: const Text("Don't have an account? Sign Up",
                      style: TextStyle(color: Color(0xFFB69AEF))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
