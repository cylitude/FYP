import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/my_app_bar.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key}); // Use super parameter for cleaner code

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
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 25),
                child: Text(
                  "Analytics",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 10, bottom: 10, right: 25),
                child: Text(
                  "This is an analytics page for the Virtual Fashion Assistant Mobile Application. Users can view insights and data trends here.",
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
