import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fchat/models/channel_model.dart';
import 'package:flutter_fchat/models/message_model.dart';
import 'package:flutter_fchat/models/user_model.dart';

String channelId(String id1, String id2) {
  if (id1.hashCode < id2.hashCode) {
    return '$id1-$id2';
  } else {
    return '$id2-$id1';
  }
}

class FirebaseDatasource {
  FirebaseDatasource._init();

  static final FirebaseDatasource instance = FirebaseDatasource._init();

  Stream<List<UserModel>> allUser() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapShot) {
      List<UserModel> rs = [];

      for (var element in snapShot.docs) {
        rs.add(UserModel.fromDocumentSnapshot(element));
      }
      return rs;
    });
  }

  Stream<List<ChannelModel>> channelStream(String userId) {
    return FirebaseFirestore.instance
        .collection('channels')
        .where('memberIds', arrayContains: userId)
        .orderBy('lastTime', descending: true)
        .snapshots()
        .map((querySnapshot) {
      List<ChannelModel> rs = [];
      for (var element in querySnapshot.docs) {
        rs.add(ChannelModel.fromDocumentSnapshot(element));
      }
      return rs;
    });
  }

  Future<void> updateChannel(
      String channelId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('channels')
        .doc(channelId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> addMessage(MessageModel message) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .add(message.toMap());
  }

  Stream<List<MessageModel>> messageStream(String channelId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('channelId', isEqualTo: channelId)
        .orderBy('sendAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      List<MessageModel> rs = [];
      for (var element in querySnapshot.docs) {
        rs.add(MessageModel.fromDocumentSnapshot(element));
      }
      return rs;
    });
  }
}
