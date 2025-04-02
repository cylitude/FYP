import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import '../components/my_app_bar.dart';

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  // Store messages as ChatMessage objects
  final List<ChatMessage> _chatMessages = [];

  // For Gemini conversation context
  final List<Content> _conversation = [];

  // For streaming subscription
  StreamSubscription<dynamic>? _streamSubscription;

  // Two ChatUsers: one for the user, one for the assistant.
  // Removed 'const' keywords here.
  final ChatUser _user = ChatUser(
    id: 'user',
    firstName: 'You',
    profileImage: null,
  );

  final ChatUser _assistant = ChatUser(
    id: 'vava',
    firstName: 'Vava',
    profileImage: null,
  );

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Optionally scroll to bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // dash_chat_2 typically auto-scrolls
    });
  }

  /// Handle sending a user message (multi-turn chat)
  Future<void> _handleSendMessage(ChatMessage message) async {
    final text = message.text.trim();
    if (text.isEmpty) return;

    // 1. Add user message locally
    setState(() {
      // Insert at index 0 to show new messages at the "top"
      _chatMessages.insert(0, message);
      _conversation.add(Content(parts: [Part.text(text)], role: 'user'));
    });

    // 2. Call Gemini’s chat endpoint
    try {
      final response = await Gemini.instance.chat(_conversation);
      final modelText = response?.output ?? '';

      // 3. If the model responds, add that message
      if (modelText.isNotEmpty) {
        final botMessage = ChatMessage(
          user: _assistant,
          text: modelText,
          createdAt: DateTime.now(),
        );
        setState(() {
          _chatMessages.insert(0, botMessage);
          _conversation.add(
            Content(parts: [Part.text(modelText)], role: 'model'),
          );
        });
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        user: _assistant,
        text: "Error: $e",
        createdAt: DateTime.now(),
      );
      setState(() {
        _chatMessages.insert(0, errorMessage);
      });
    }

    _scrollToBottom();
  }

  /// Demonstrates streaming a single prompt
  void _streamSinglePrompt() {
    _streamSubscription?.cancel();

    final text = "Some single-prompt text to stream...";
    if (text.isEmpty) return;

    final userStreamMsg = ChatMessage(
      user: _user,
      text: "(Stream) $text",
      createdAt: DateTime.now(),
    );
    setState(() {
      _chatMessages.insert(0, userStreamMsg);
    });

    // Stream from Gemini
    _streamSubscription = Gemini.instance
        .promptStream(parts: [Part.text(text)])
        .listen(
      (event) {
        final out = event?.output;
        if (out != null && out.isNotEmpty) {
          final streamingResponse = ChatMessage(
            user: _assistant,
            text: out,
            createdAt: DateTime.now(),
          );
          setState(() {
            _chatMessages.insert(0, streamingResponse);
          });
          _scrollToBottom();
        }
      },
      onError: (error) {
        final errorMessage = ChatMessage(
          user: _assistant,
          text: "Stream error: $error",
          createdAt: DateTime.now(),
        );
        setState(() {
          _chatMessages.insert(0, errorMessage);
        });
      },
      onDone: () {
        final doneMessage = ChatMessage(
          user: _assistant,
          text: "Stream ended.",
          createdAt: DateTime.now(),
        );
        setState(() {
          _chatMessages.insert(0, doneMessage);
        });
        _scrollToBottom();
      },
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

      // Soft purple background
      backgroundColor: const Color.fromARGB(255, 123, 105, 151),

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
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 32,
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                ),
              ),
              // Intro text
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
                    color: const Color.fromARGB(255, 16, 16, 16),
                    height: 1.5,
                  ),
                ),
              ),

              // Wrap DashChat in a Theme to force black cursor and text
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: Colors.black, // black cursor
                    ),
                    // This sets a default text color for input text
                    textTheme: const TextTheme(
                      bodyMedium: TextStyle(color: Colors.black),
                    ),
                  ),
                  child: DashChat(
                    // Current user
                    currentUser: _user,

                    // List of messages
                    messages: _chatMessages,

                    // Callback on sending a message
                    onSend: (ChatMessage message) {
                      _handleSendMessage(message);
                    },

                    // Customize message display
                    messageOptions: MessageOptions(
                      showOtherUsersAvatar: true,
                      showCurrentUserAvatar: true,
                      showTime: true,
                      // Bubble colors for user vs assistant
                      currentUserContainerColor: Colors.blueGrey,
                      containerColor: Colors.white,
                    ),

                    // Basic list options
                    messageListOptions: const MessageListOptions(),

                    // Input styling
                    inputOptions: InputOptions(
                      // Use inputDecoration for border & fill
                      inputDecoration: InputDecoration(
                        hintText: "Type your message...",
                        filled: true,
                        fillColor: Colors.grey,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      // Add trailing icon for streaming
                      trailing: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.stream),
                          onPressed: _streamSinglePrompt,
                          tooltip: "Stream single prompt",
                          color: Colors.deepPurple, // Purple icon
                        ),
                      ],
                    ),

                    // Minimal scroll-to-bottom widget
                    scrollToBottomOptions: const ScrollToBottomOptions(),
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
