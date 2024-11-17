import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../components/my_button.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                'assets/trolley.json',
              ),
            ),

            const SizedBox(height: 75),

            // message
            Text(
              "Fashion Assistant",
              style: GoogleFonts.bebasNeue(
                fontSize: 48,
                // color: Theme.of(context).colorScheme.inversePrimary,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "For Fashion Geeks",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),

            const SizedBox(height: 25),

            // button
            MyButton(
              onTap: () => Navigator.pushNamed(context, '/shop_page'),
              widget: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
