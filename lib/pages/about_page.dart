import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/my_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const MyAppBar(
        title: '',
        actions: [],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title heading
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 25),
                child: Text(
                  "About",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                  ),
                ),
              ),

              // message
              Padding(
                padding: const EdgeInsets.only(
                    left: 25.0, top: 10, bottom: 10, right: 25),
                child: Text(
                  "This is a Virtual Fashion Assistant Mobile Application that aims to help users visualise themselves wearing clothes in store, helping them save precious time queuing in the dressing room and also payment counters ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    height: 1.5,
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
