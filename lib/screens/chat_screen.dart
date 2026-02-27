import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';
import 'admin_chat_list_screen.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    if (appProvider.isAdmin) {
      return const AdminChatListScreen();
    }

    return FutureBuilder(
      future: StorageService.getOrCreateChatRoom(
        appProvider.userId!,
        appProvider.userName!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('오류가 발생했습니다: ${snapshot.error}'),
            ),
          );
        }
        final chatRoom = snapshot.data!;
        return ChatRoomScreen(chatRoom: chatRoom);
      },
    );
  }
}
