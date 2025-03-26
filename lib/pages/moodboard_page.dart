import 'package:flutter/material.dart';

class MoodboardPage extends StatefulWidget {
  const MoodboardPage({super.key});

  @override
  State<MoodboardPage> createState() => _MoodboardPageState();
}

class _MoodboardPageState extends State<MoodboardPage> {
  // A list of available filters
  final List<String> _filters = ["90s", "Casual", "Old Money", "Korean"];

  // Track which filter is currently selected
  String? _selectedFilter;

  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();

  // When user taps a filter chip or searches
  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  // Convert filter label to highlight color
  Color _getFilterColor(String label) {
    if (_selectedFilter == label) {
      switch (label) {
        case '90s':
          return Colors.grey;
        case 'Casual':
          return const Color(0xFF808000); // Olive color
        case 'Old Money':
          return const Color(0xFFDEB887); // Burlywood tan
        case 'Korean':
          return Colors.orange;
        default:
          return Colors.blueGrey;
      }
    } else {
      return Colors.grey.shade300;
    }
  }

  // When user presses Enter in the search bar
  void _onSearchSubmitted(String query) {
    final lower = query.trim().toLowerCase();
    for (String filter in _filters) {
      if (filter.toLowerCase() == lower) {
        _selectFilter(filter);
        return;
      }
    }
    setState(() {
      _selectedFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Row: Back Arrow + Search Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _onSearchSubmitted,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: "Search for styles...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filter Row (horizontal scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filterLabel) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          filterLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        selectedColor: _getFilterColor(filterLabel),
                        backgroundColor: Colors.grey.shade300,
                        selected: _selectedFilter == filterLabel,
                        onSelected: (_) => _selectFilter(filterLabel),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Only show images if "Old Money" is selected; else show a placeholder message.
              Expanded(
                child: _selectedFilter == "Old Money"
                    ? GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        // Use an aspect ratio of 1 for square boxes; adjust if needed.
                        childAspectRatio: 1,
                        children: const [
                          MoodboardTile(imagePath: 'assets/OldMoney1.png'),
                          MoodboardTile(imagePath: 'assets/OldMoney2.png'),
                          MoodboardTile(imagePath: 'assets/OldMoney3.png'),
                          MoodboardTile(imagePath: 'assets/OldMoney4.png'),
                          MoodboardTile(imagePath: 'assets/OldMoney5.png'),
                          MoodboardTile(imagePath: 'assets/OldMoney6.png'),
                        ],
                      )
                    : const Center(
                        child: Text(
                          "No moodboard pictures are shown.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
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

/// A simplified widget that displays an image from assets inside a Card.
class MoodboardTile extends StatelessWidget {
  final String imagePath;
  const MoodboardTile({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
      ),
    );
  }
}
