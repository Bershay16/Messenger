import 'package:flutter/material.dart';
import 'package:my_messenger/components/user_tile.dart';
import 'package:my_messenger/services/auth/auth_service.dart';
import 'package:my_messenger/services/chat/chat_service.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  // chat & auth services
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  void _showUnblockBox(BuildContext context,String userId){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Unblock User"),
        content: Text("Are you sure you want to unblock this user?"),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          //block button
          TextButton(
            onPressed: () {
              ChatService().unblockedUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("User Unblocked!!!"),
                ),
              );
            },
            child: Text("Unblock"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //get current user id
    String userId = authService.getCurrentUser()!.uid;

    // UI
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Blocked Users"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getBlockedUsersStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error Loading..."),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final blockedUsers = snapshot.data ?? [];
          //load complete

          // no blocked users
          if (blockedUsers.isEmpty) {
            return Center(
              child: Text(
                "No Blocked Users",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            );
          }

          // blocked users
          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                onTap: ()=>_showUnblockBox(context,user['uid']),
                text: user['email'],
              );
            },
          );
        },
      ),
    );
  }
}
