import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
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
              
              // 1) VAVA tile (special style)
              //    - Shimmer text + gradient background
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
                    child: ListTile(
                      leading: const Icon(
                        Icons.assistant,
                        color: Colors.white,
                      ),
                      title: Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.yellow,
                        child: const Text(
                          "V A V A",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 2) PINTEREST tile (new button)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/pinterest_page');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.pink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        FontAwesomeIcons.pinterest, // Pinterest icon
                        color: Colors.white,
                      ),
                      title: Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.yellow,
                        child: const Text(
                          "PINTEREST",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                  // Add any additional navigation if desired
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

              // 6) PROFILE tile
              MyListTile(
                text: "P R O F I L E",
                icon: Icons.person,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile_page');
                },
              ),

              // 7) SETTINGS tile
              MyListTile(
                text: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings_page');
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
