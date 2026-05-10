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

    // 관리자인 경우 채팅방 목록 화면으로
    if (appProvider.isAdmin) {
      return const AdminChatListScreen();
    }

    // userId 또는 userName이 null이면 로딩 화면 표시
    final userId = appProvider.userId;
    final userName = appProvider.userName;

    if (userId == null || userName == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 일반 고객인 경우 1:1 채팅방으로
    return FutureBuilder(
      future: StorageService.getOrCreateChatRoom(userId, userName),
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

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('채팅방을 불러올 수 없습니다')),
          );
        }

        final chatRoom = snapshot.data!;
        return ChatRoomScreen(chatRoom: chatRoom);
      },
    );
  }
}
