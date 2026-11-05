
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContainerPage extends StatelessWidget {
  const ContainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile & Mentorship',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E2C),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),

        child: Column(
          children: [

            // Personal Profile Banner

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
                    "Md. Habibur Rahman Fuyad",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "ID: 64_a | Computer Science Student",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Active Skill / Mentorship Card

            SizedBox(
              width: double.infinity,

              child: Card(
                color: const Color(0xFF2D2B42),
                elevation: 8,
                shadowColor: Colors.purpleAccent,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20.0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Row(
                        children: [

                          const Icon(
                            Icons.school,
                            color: Color(0xFF9370DB),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "My Active Micro-Mentorship",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const Divider(
                        height: 20,
                        color: Colors.white24,
                      ),

                      Text(
                        "Offering micro-mentorship sessions in Flutter Mobile Development, Java, and Database Systems.",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Align(
                        alignment: Alignment.centerRight,

                        child: TextButton(
                          onPressed: () {},

                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF9370DB),
                          ),

                          child: const Text(
                            "Manage Sessions →",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
