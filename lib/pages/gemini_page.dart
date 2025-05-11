// lib/pages/gemini_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import '../components/my_app_bar.dart';

import 'vava_reco.dart';
import '../models/product.dart';
import 'popup_page.dart';

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  final List<ChatMessage> _chatMessages = [];
  StreamSubscription<dynamic>? _streamSubscription;
  Product? _recommendation;

  final ChatUser _user      = ChatUser(id: 'user', firstName: 'You');
  final ChatUser _assistant = ChatUser(id: 'vava', firstName: 'Vava');

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Keep your old scroll helper
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // dash_chat_2 auto-scrolls for us
    });
  }

  /// Retry wrapper around Gemini.instance.prompt(...)
  Future<String> _callGeminiWithRetry(String promptText) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        // Use prompt() instead of deprecated text()
        final resp = await Gemini.instance.prompt(
          parts: [Part.text(promptText)],
        );
        // Null-safe trim
        return (resp?.output ?? '').trim();
      } catch (e) {
        if (attempt == maxAttempts) rethrow;
        // Exponential back-off
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }
    return '';
  }

  Future<void> _handleSendMessage(ChatMessage message) async {
    final text = message.text.trim();
    if (text.isEmpty) return;

    // 1) Show the user message
    setState(() {
      _chatMessages.insert(0, message);
    });

    try {
      // 2) Call Gemini.prompt with retry
      final modelText = await _callGeminiWithRetry(text);

      // 3) Show the assistant’s reply
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
        });

        // 4) Extract keywords & match
        final keys = extractKeywords(modelText);
        final best = await findBestMatch(keys);
        setState(() {
          _recommendation = best;
        });
      }
    } catch (e) {
      final err = e.toString().contains('503')
          ? 'Service unavailable, please try again later.'
          : 'Error: $e';
      setState(() {
        _chatMessages.insert(
          0,
          ChatMessage(
            user: _assistant,
            text: err,
            createdAt: DateTime.now(),
          ),
        );
      });
    }

    _scrollToBottom();
  }

  Future<void> _showRecommendationDialog() async {
    final ctx = context;
    final want = await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Recommendation'),
        content: const Text(
          'Do you want VAVA to recommend you what you are looking for?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (!ctx.mounted || want != true) return;

    if (_recommendation != null) {
      Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => PopupPage(product: _recommendation!),
        ),
      );
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Sorry, no match found.')),
      );
    }
  }

  void _streamSinglePrompt() {
    _streamSubscription?.cancel();
    const text = 'Some single-prompt text to stream...';

    setState(() {
      _chatMessages.insert(
        0,
        ChatMessage(user: _user, text: '(Stream) $text', createdAt: DateTime.now()),
      );
    });

    _streamSubscription = Gemini.instance
        .promptStream(parts: [Part.text(text)])
        .listen((event) {
      final out = event?.output ?? '';
      if (out.isNotEmpty && mounted) {
        final cleaned = out.replaceAll('*', '');
        setState(() {
          _chatMessages.insert(
            0,
            ChatMessage(
              user: _assistant,
              text: cleaned,
              createdAt: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: '', actions: []),
      backgroundColor: const Color(0xFF7B6997),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'VAVA',
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
                      child: const Text('Recommend me!'),
                    ),
                  ],
                ),
              ),

              // Intro
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: Text(
                  'Introducing our Virtual Fashion Assistant Vava! Powered by Google Gemini, '
                  'Vava is here to respond to your prompts on anything fashion related.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ),

              // Chat
              Expanded(
                child: DashChat(
                  currentUser: _user,
                  messages: _chatMessages,
                  onSend: _handleSendMessage,
                  messageOptions: MessageOptions(
                    showOtherUsersAvatar: true,
                    showCurrentUserAvatar: true,
                    showTime: true,
                    currentUserContainerColor: Colors.blueGrey,
                    containerColor: Colors.white,
                  ),
                  inputOptions: InputOptions(
                    inputDecoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Colors.grey[300],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    trailing: [
                      IconButton(
                        icon: const Icon(
                          Icons.stream,
                          color: Colors.deepPurple,
                        ),
                        onPressed: _streamSinglePrompt,
                        tooltip: 'Stream single prompt',
                      ),
                    ],
                  ),
                  scrollToBottomOptions: const ScrollToBottomOptions(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
