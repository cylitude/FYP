import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top section
          Column(
            children: [
              // Drawer header: logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: DrawerHeader(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: Lottie.asset(
                        'assets/trolley.json',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              
              // 1) VAVA tile
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/gemini_page');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const ListTile(
                      leading: Icon(
                        Icons.assistant,
                        color: Colors.white,
                      ),
                      title: Text(
                        "V A V A",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 2) MOODBOARD tile 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                child: GestureDetector(
                  onTap: () {
                    // Close the drawer first
                    Navigator.pop(context);
                    // Navigate to the Moodboard page
                    Navigator.pushNamed(context, '/moodboard_page');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD291BC),
                          Color(0xFFFEC8D8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        FontAwesomeIcons.brush,
                        color: Colors.white,
                      ),
                      title: Text(
                        "MOODBOARD",
                        style: GoogleFonts.dancingScript(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 3) SHOP tile
              MyListTile(
                text: "S H O P",
                icon: Icons.home,
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // 4) CART tile
              MyListTile(
                text: "C A R T",
                icon: Icons.shopping_cart,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/cart_page');
                },
              ),

              // 5) ORDERS tile
              MyListTile(
                text: "O R D E R S",
                icon: Icons.receipt,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/orders_page');
                },
              ),

              // 6) ACCOUNT tile
              MyListTile(
                text: "A C C O U N T",
                icon: Icons.person,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile_page');
                },
              ),

              
            ],
          ),

          // Bottom section: LOGOUT tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              text: "L O G O U T",
              icon: Icons.logout,
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/intro_page',
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
