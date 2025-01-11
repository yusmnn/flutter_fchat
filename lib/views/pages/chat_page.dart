import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fchat/datasources/firebase_datasource.dart';
import 'package:flutter_fchat/models/channel_model.dart';
import 'package:flutter_fchat/models/message_model.dart';
import 'package:flutter_fchat/models/user_model.dart';

import '../widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  final UserModel partnerUser;
  const ChatPage({super.key, required this.partnerUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CupertinoButton(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.partnerUser.name,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
                stream: FirebaseDatasource.instance.messageStream(
                  channelId(widget.partnerUser.id, currentUser!.uid),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<MessageModel> messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('No message found'),
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatBubble(
                        direction: message.senderId == currentUser!.uid
                            ? Direction.right
                            : Direction.left,
                        message: message.textMessage,
                        // photoUrl: message.photoUrl,
                        type: BubbleType.alone,
                      );
                    },
                  );
                }),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMassage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMassage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final channel = ChannelModel(
      id: channelId(currentUser!.uid, widget.partnerUser.id),
      memberIds: [currentUser!.uid, widget.partnerUser.id],
      lastMessage: _messageController.text.trim(),
      lastTime: Timestamp.now(),
      unRead: {
        currentUser!.uid: false,
        widget.partnerUser.id: true,
      },
      members: [UserModel.fromFirebaseUser(currentUser!), widget.partnerUser],
      sendBy: currentUser!.uid,
    );

    FirebaseDatasource.instance.updateChannel(
      channel.id,
      channel.toMap(),
    );

    var docRef = FirebaseFirestore.instance.collection('messages').doc();
    var message = MessageModel(
      id: docRef.id,
      channelId: channel.id,
      senderId: currentUser!.uid,
      textMessage: _messageController.text.trim(),
      sendAt: Timestamp.now(),
    );

    FirebaseDatasource.instance.addMessage(message);

    var channelUpdateData = {
      'lastMessage': message.textMessage,
      'sendBy': currentUser!.uid,
      'lastTime': message.sendAt,
      'unRead': {
        currentUser!.uid: false,
        widget.partnerUser.id: true,
      },
    };

    FirebaseDatasource.instance.updateChannel(channel.id, channelUpdateData);

    _messageController.clear();
  }
}
