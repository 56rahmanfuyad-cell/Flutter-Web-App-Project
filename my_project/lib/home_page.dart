
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_project/container_page.dart';
import 'package:my_project/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campus Skill Share',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E2C),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(0xFF9370DB),
            ),
            onPressed: () {},
          ),
        ],
      ),

      // Navigation Drawer
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF2D2B42),
              ),
              accountName: Text(
                'Md. Habibur Rahman Fuyad',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: const Text('fuyad@student.edu'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Color(0xFF9370DB),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),

            // Dashboard
            ListTile(
              leading: const Icon(
                Icons.home,
                color: Color(0xFF9370DB),
              ),
              title: const Text('Explore Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // Profile and Skills
            ListTile(
              leading: const Icon(
                Icons.person_pin,
                color: Color(0xFF9370DB),
              ),
              title: const Text('My Profile & Skills'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContainerPage(),
                  ),
                );
              },
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // Main Dashboard Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4A0E4E),
                    Color(0xFF9370DB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, Fuyad! 👋",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ready to share your skills or learn something new on campus today?",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Explore Categories
            Text(
              "Explore Categories",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryCard(
                  Icons.code,
                  "Coding",
                  Colors.teal,
                ),
                _buildCategoryCard(
                  Icons.security,
                  "Cyber Sec",
                  Colors.indigo,
                ),
                _buildCategoryCard(
                  Icons.storage,
                  "Database",
                  Colors.pinkAccent,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Profile Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContainerPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9370DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.account_circle),
                label: Text(
                  "Go to My Profile & Skills",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF9370DB),
        tooltip: "Post New Skill Offering",
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // Category Card Function
  Widget _buildCategoryCard(
    IconData icon,
    String title,
    Color color,
  ) {
    return Container(
      width: 105,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2B42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
