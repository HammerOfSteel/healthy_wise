import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart'; // Make sure you have the dart_openai package imported
import 'package:shared_preferences/shared_preferences.dart';

class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  TextEditingController messageController = TextEditingController();
  List<String> chatHistory = [];
  String _aiToken = ''; // Initialize it with your stored API key

  @override
  void initState() {
    super.initState();
    _initializeChat(); // Initialize the API key when the screen initializes
  }

    void _initializeChat() async {
    final prefs = await SharedPreferences.getInstance();
    _aiToken = prefs.getString('chatGPTToken') ?? ''; // Provide a default empty string
    // Initialize the OpenAI API with the stored API key
    OpenAI.apiKey = _aiToken;
    }

  void _addMessageToChat(String message) {
    setState(() {
      chatHistory.add("You: $message");
    });
  }

  Future<void> _sendMessageToAI(String message) async {
    try {
      // Send a message to OpenAI's chat model
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo", // You can specify the model you want to use
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: message,
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );

      final aiResponse = chatCompletion.choices.first.message.content;

      setState(() {
        chatHistory.add("AI: $aiResponse");
      });
    } catch (e) {
      print("Error sending message to AI: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final message = chatHistory[index];
                return ListTile(
                  title: Text(message),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(hintText: 'Type your message...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              final userMessage = messageController.text;
              if (userMessage.isNotEmpty) {
                _addMessageToChat(userMessage);
                _sendMessageToAI(userMessage);
                messageController.clear();
              }
            },
          )
        ],
      ),
    );
  }
}
