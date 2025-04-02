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
  final List<ChatMessage> _chatMessages = [];
  final List<Content> _conversation = [];
  StreamSubscription<dynamic>? _streamSubscription;

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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // dash_chat_2 typically auto-scrolls
    });
  }

  Future<void> _showRecommendationDialog() async {
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Recommendation"),
          content: const Text(
            "Do you want VAVA to recommend you what you are looking for?",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text("No"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      // Instead of navigating to ShopPage, navigate to PopupPage.
      Navigator.pushNamed(context, '/popup_page');
    }
  }

  Future<void> _handleSendMessage(ChatMessage message) async {
    final text = message.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.insert(0, message);
      _conversation.add(Content(parts: [Part.text(text)], role: 'user'));
    });

    try {
      final response = await Gemini.instance.chat(_conversation);
      if (!mounted) return;

      final modelText = (response?.output ?? '').replaceAll('*', '');
      if (modelText.isNotEmpty) {
        setState(() {
          _chatMessages.insert(
            0,
            ChatMessage(
              user: _assistant,
              text: modelText,
              createdAt: DateTime.now(),
            ),
          );
          _conversation.add(
            Content(parts: [Part.text(modelText)], role: 'model'),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
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

    _streamSubscription = Gemini.instance
        .promptStream(parts: [Part.text(text)])
        .listen(
      (event) {
        final out = event?.output ?? '';
        if (out.isNotEmpty) {
          final cleanedOutput = out.replaceAll('*', '');
          if (!mounted) return;
          setState(() {
            _chatMessages.insert(
              0,
              ChatMessage(
                user: _assistant,
                text: cleanedOutput,
                createdAt: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        }
      },
      onError: (error) {
        if (!mounted) return;
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
        if (!mounted) return;
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
      appBar: const MyAppBar(title: '', actions: []),
      backgroundColor: const Color.fromARGB(255, 123, 105, 151),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 25.0,
                  top: 25,
                  bottom: 8,
                  right: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "VAVA",
                      style: GoogleFonts.pacifico(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showRecommendationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                      ),
                      child: const Text("Recommend me!"),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 8,
                ),
                child: const Text(
                  "Introducing our Virtual Fashion Assistant Vava! Powered by Google Gemini, Vava is here to respond to your prompts on anything fashion related.",
                  style: TextStyle(
                    color: Color.fromARGB(255, 247, 243, 243),
                    height: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: Colors.black,
                    ),
                    textTheme: const TextTheme(
                      bodyMedium: TextStyle(color: Colors.black),
                    ),
                  ),
                  child: DashChat(
                    currentUser: _user,
                    messages: _chatMessages,
                    onSend: (ChatMessage message) {
                      _handleSendMessage(message);
                    },
                    messageOptions: MessageOptions(
                      showOtherUsersAvatar: true,
                      showCurrentUserAvatar: true,
                      showTime: true,
                      currentUserContainerColor: Colors.blueGrey,
                      containerColor: Colors.white,
                    ),
                    messageListOptions: const MessageListOptions(),
                    inputOptions: InputOptions(
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
                      trailing: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.stream),
                          onPressed: _streamSinglePrompt,
                          tooltip: "Stream single prompt",
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
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
