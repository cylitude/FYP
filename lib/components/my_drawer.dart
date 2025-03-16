import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
              // Shop tile
              MyListTile(
                text: "S H O P",
                icon: Icons.home,
                onTap: () => Navigator.pop(context),
              ),
              // Cart tile
              MyListTile(
                text: "C A R T",
                icon: Icons.shopping_cart,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/cart_page');
                },
              ),
              // Orders tile
              MyListTile(
                text: "O R D E R S",
                icon: Icons.receipt,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/orders_page');
                },
              ),
              // Chatbot tile
              MyListTile(
                text: "C H A T B O T",
                icon: Icons.chat,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chatbot_page');
                },
              ),
              // Analytics tile
              MyListTile(
                text: "V A V A",
                icon: Icons.assistant,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/gemini_page');
                },
              ),
              // Settings tile
              MyListTile(
                text: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings_page');
                },
              ),
              // Profile tile 
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: MyListTile(
                  text: "P R O F I L E",
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
              ),
            ],
          ),
          // Exit tile
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
