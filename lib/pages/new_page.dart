import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For time formatting

class NewPage extends StatefulWidget {
  final String email; // Receiving email
  const NewPage({Key? key, required this.email}) : super(key: key);

  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  File? _image;
  final TextEditingController _controller = TextEditingController();
  final CollectionReference messages = FirebaseFirestore.instance.collection('messages');
  final ScrollController _scrollController = ScrollController();

  Future<void> _addMessage(String message) async {
    if (message.isNotEmpty) {
      _controller.clear();
      await messages.add({
        'text': message,
        'createdAt': Timestamp.now(),
        'email': widget.email, // Adding email to the message
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path); // Storing the selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: _image != null
                    ? kIsWeb
                    ? Image.network(
                  _image!.path, // For demonstration; replace with a web-friendly URL if needed
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                )
                    : Image.file(
                  _image!,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                )
                    : const Icon(Icons.person, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Chat App'),
          ],
        ),
        backgroundColor: const Color(0xFF9B7ED3),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFDABFFF),
              Color(0xFF9B7ED3),
              Color(0xFF7E16EE),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messages.orderBy('createdAt', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var message = docs[index].get('text');
                      var email = docs[index].get('email');
                      var timestamp = docs[index].get('createdAt') as Timestamp;
                      DateTime messageTime = timestamp.toDate();

                      bool isMe = email == widget.email;

                      return isMe
                          ? MessageBubble(message: message, time: messageTime, isMe: true)
                          : MessageFriend(message: message, time: messageTime);
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send,    color: Color(0xFF9B7ED3),),
                  onPressed: () => _addMessage(_controller.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime time;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.time,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('hh:mm a').format(time);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomLeft: isMe ? Radius.circular(32) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageFriend extends StatelessWidget {
  final String message;
  final DateTime time;

  const MessageFriend({Key? key, required this.message, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('hh:mm a').format(time);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}