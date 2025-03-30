// SUNSET, NOT IN USE
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dialogflow_service.dart';

/// A simple model to hold chat messages
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  ChatbotPageState createState() => ChatbotPageState();
}

class ChatbotPageState extends State<ChatbotPage> {
  final DialogflowService _dialogflowService = DialogflowService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDialogflow();
  }

  Future<void> _initializeDialogflow() async {
    // Initialize the Dialogflow service
    await _dialogflowService.init();
  }

  void _sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    // Add user message to the list
    setState(() {
      _messages.add(ChatMessage(text: userInput, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    // Send message to Dialogflow
    try {
      final response = await _dialogflowService.detectIntent(userInput);
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Error: $e', isUser: false));
        _isLoading = false;
      });
    }
  }

  Widget _buildMessage(ChatMessage message) {
    final alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser ? Colors.blue[300] : Colors.grey[300];
    final textColor = message.isUser ? Colors.white : Colors.black87;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chatbot",
          style: GoogleFonts.dmSerifDisplay(fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          // List of messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1),
          // Input field + send button
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration.collapsed(
                      hintText: "Type your message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
