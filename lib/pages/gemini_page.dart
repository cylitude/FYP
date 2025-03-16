import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/my_app_bar.dart';

/// A page demonstrating Gemini Chatbot features (multi-turn chat & streaming),
/// now tailored to your Virtual Fashion Assistant "Vava."
class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  // Controllers and state
  final TextEditingController _userInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // We'll store conversation messages as simple strings in _messages.
  // "User: <text>" indicates a user message; "Gemini: <text>" indicates the model's response.
  final List<String> _messages = [];

  // For advanced usage, we can store the conversation content:
  final List<Content> _conversation = [];

  // For streaming subscription
  StreamSubscription<dynamic>? _streamSubscription;

  @override
  void dispose() {
    _userInputController.dispose();
    _scrollController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Scroll to the bottom of the chat list (for convenience).
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  /// Adds a user message to the chat, sends it to Gemini (multi-turn chat),
  /// and displays the model’s response in the chat.
  Future<void> _sendMessage() async {
    final text = _userInputController.text.trim();
    if (text.isEmpty) return;

    // Clear user input field
    _userInputController.clear();

    // 1. Add user message to conversation and UI
    setState(() {
      _conversation.add(
        Content(parts: [Part.text(text)], role: 'user'),
      );
      _messages.add("User: $text");
    });

    // 2. Call Gemini’s chat endpoint with the entire conversation so far
    try {
      final response = await Gemini.instance.chat(_conversation);

      // 3. Append the model’s response to the conversation and UI
      final modelText = response?.output ?? '';
      if (modelText.isNotEmpty) {
        setState(() {
          _conversation.add(
            Content(parts: [Part.text(modelText)], role: 'model'),
          );
          _messages.add("Gemini: $modelText");
        });
      }
    } catch (e) {
      setState(() {
        _messages.add("Error: $e");
      });
    }

    // Scroll down to show the latest message
    _scrollToBottom();
  }

  /// Demonstrates streaming a single prompt (instead of multi-turn chat).
  /// The icon next to "Send" calls this. It’s for partial/real-time responses.
  void _streamSinglePrompt() {
    final text = _userInputController.text.trim();
    if (text.isEmpty) return;

    _userInputController.clear();

    // Add user message
    setState(() {
      _messages.add("User (Stream): $text");
    });

    // Cancel any existing subscription
    _streamSubscription?.cancel();

    // Stream the output from Gemini
    _streamSubscription = Gemini.instance
        .promptStream(parts: [Part.text(text)])
        .listen((event) {
      final out = event?.output;
      if (out != null && out.isNotEmpty) {
        setState(() {
          _messages.add("Gemini (Stream): $out");
        });
        _scrollToBottom();
      }
    }, onError: (error) {
      setState(() {
        _messages.add("Stream error: $error");
      });
    }, onDone: () {
      // Stream finished
      setState(() {
        _messages.add("Stream ended.");
      });
      _scrollToBottom();
    });
  }

  /// A helper widget to display chat bubbles differently for "User" vs. "Gemini".
  Widget _buildChatBubble(String message) {
    // Distinguish user vs. Gemini by prefix
    final bool isUser = message.startsWith("User");
    final bool isError = message.startsWith("Error") || message.contains("error");
    //final bool isStream = message.contains("(Stream):");

    // Remove the prefix for display
    String displayText = message;
    if (isUser) {
      displayText = displayText.replaceFirst("User: ", "");
      displayText = displayText.replaceFirst("User (Stream): ", "");
    } else if (message.startsWith("Gemini: ")) {
      displayText = displayText.replaceFirst("Gemini: ", "");
    }

    // Remove double asterisks from the text for cleaner formatting
    displayText = displayText.replaceAll("**", "");

    // Decide alignment and bubble color
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser
        ? Colors.blue[300]
        : (isError ? Colors.red[200] : Colors.grey[300]);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(displayText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the top bar text by passing an empty string to MyAppBar
      appBar: const MyAppBar(
        title: '',
        actions: [],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Bold heading "Vava"
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 25, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Vava",
                    style: GoogleFonts.dmSerifDisplay(fontSize: 32),
                  ),
                ),
              ),
              // Updated description text
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 8,
                ),
                child: Text(
                  "Introducing our Virtual Fashion Assistant Vava! "
                  "Powered by Google Gemini, Vava is here to respond to your "
                  "prompts on anything fashion related.",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    height: 1.5,
                  ),
                ),
              ),
              // Expanded chat area with bubble UI
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatBubble(_messages[index]);
                    },
                  ),
                ),
              ),
              // Text input + action buttons
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // User input field with black cursor
                    Expanded(
                      child: TextField(
                        controller: _userInputController,
                        cursorColor: Colors.black, // <-- Make cursor black
                        decoration: const InputDecoration(
                          hintText: "Type your message...",
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    // Send multi-turn chat
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      tooltip: "Send multi-turn chat message",
                    ),
                    // The icon next to “Send” is for streaming a single prompt
                    IconButton(
                      icon: const Icon(Icons.stream),
                      onPressed: _streamSinglePrompt,
                      tooltip:
                          "Stream single prompt (see partial responses in real-time)",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
