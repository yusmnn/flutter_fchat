// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String textMessage;
  final String senderId;
  final Timestamp sendAt;
  final String channelId;
  MessageModel({
    required this.id,
    required this.textMessage,
    required this.senderId,
    required this.sendAt,
    required this.channelId,
  });

  Map<String, dynamic> toMap() {
    return {
      'textMessage': textMessage,
      'senderId': senderId,
      'sendAt': sendAt,
      'channelId': channelId,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      textMessage: map['textMessage'] ?? '',
      senderId: map['senderId'] ?? '',
      sendAt: map['sendAt'] ?? '',
      channelId: map['channelId'] ?? '',
    );
  }

  factory MessageModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return MessageModel(
      id: snapshot.id, //! Ambil ID dari metadata dokumen
      textMessage: snapshot['textMessage'] ?? '',
      senderId: snapshot['senderId'] ?? '',
      sendAt: snapshot['sendAt'] ?? '',
      channelId: snapshot['channelId'] ?? '',
    );
  }
}
