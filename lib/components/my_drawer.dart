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
              // drawer header: logo
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

              // shop tile
              MyListTile(
                text: "S H O P",
                icon: Icons.home,
                onTap: () => Navigator.pop(context),
              ),

              // cart tile
              MyListTile(
                text: "C A R T",
                icon: Icons.shopping_cart,
                onTap: () {
                  // pop drawer first
                  Navigator.pop(context);

                  // go to settings page
                  Navigator.pushNamed(context, '/cart_page');
                },
              ),

              // settings tile
              MyListTile(
                text: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {
                  // pop drawer first
                  Navigator.pop(context);

                  // go to settings page
                  Navigator.pushNamed(context, '/settings_page');
                },
              ),

              // about tile
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: MyListTile(
                  text: "A B O U T",
                  icon: Icons.info,
                  onTap: () {
                    // pop drawer first
                    Navigator.pop(context);

                    // go to about page
                    Navigator.pushNamed(context, '/about_page');
                  },
                ),
              ),
            ],
          ),

          // about tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              text: "E X I T",
              icon: Icons.logout,
              onTap: () {
                // go to about page
                Navigator.pushNamedAndRemoveUntil(
                    context, '/intro_page', (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
