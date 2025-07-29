import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_messenger/models/message.dart';

class ChatService extends ChangeNotifier {
  //get firstore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();
        // return user
        return user;
      }).toList();
    });
  }

  //get all users except blocked uers
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      // Get blocked user IDs
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      // Fetch all users from the 'Users' collection
      final usersSnapshot = await _firestore.collection('Users').get();

      // Exclude the current user and blocked users
      return usersSnapshot.docs
          .where((doc) =>
              doc.data()['email'] !=
                  currentUser.email && // Exclude current user
              !blockedUserIds.contains(doc.id)) // Exclude blocked users
          .map((doc) => doc.data()) // Convert to Map
          .toList();
    });
  }

  //send messages
  Future<void> sendMessage(String receiverID, message) async {
    // get current use info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      message: message,
      receiverID: receiverID,
      senderEmail: currentUserEmail,
      senderID: currentUserID,
      timestamp: timestamp,
    );
    //construct a chat room id for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); //to ensure 2 people have same id
    String chatRoomID = ids.join('_');

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    //construct a chatrroom for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort(); //to ensure 2 people have same id
    String chatRoomID = ids.join('_');

    // add new message to database
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // report user
  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Reports').add(report);
  }

  //block user
  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection("Users")
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
    notifyListeners();
  }

  //unblock user
  Future<void> unblockedUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection("Users")
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  //get blocked users stream
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return _firestore
        .collection('Users') // Access the 'Users' collection
        .doc(userId) // Access the document corresponding to the given userId
        .collection('BlockedUsers') // Access the 'BlockedUsers' subcollection
        .snapshots() // Set up a stream to listen to real-time updates
        .asyncMap((snapshot) async {
      // Get the list of blocked user IDs
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      // Fetch the documents for each blocked user
      final userDocs = await Future.wait(
        blockedUserIds
            .map((id) => _firestore.collection('Users').doc(id).get()),
      );

      // Return the data from each document as a list of maps
      return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }
}
