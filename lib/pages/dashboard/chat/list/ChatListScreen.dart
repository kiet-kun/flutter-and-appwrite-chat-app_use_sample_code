import 'package:auto_route/auto_route.dart';
import 'package:chat_with_bisky/model/ChatState.dart';
import 'package:chat_with_bisky/model/UserAppwrite.dart';
import 'package:chat_with_bisky/model/db/ChatRealm.dart';
import 'package:chat_with_bisky/pages/dashboard/chat/list/ChatListViewModel.dart';
import 'package:chat_with_bisky/route/app_route/AppRouter.gr.dart';
import 'package:chat_with_bisky/service/LocalStorageService.dart';
import 'package:chat_with_bisky/widget/ChatHeadItemWidget.dart';
import 'package:chat_with_bisky/widget/custom_app_bar.dart';
import 'package:chat_with_bisky/widget/friend_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  ChatListViewModel? notifier;
  ChatState? model;
  String? userId;
  @override
  Widget build(BuildContext context) {
    notifier = ref.read(chatListViewModelProvider.notifier);
    model = ref.watch(chatListViewModelProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              CustomBarWidget(
                "Chats",
              ),
              model?.chats.isNotEmpty == true
                  ? Expanded(
                      child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            ChatRealm friend = model!.chats[index];
                            return ChatHeadItemWidget(chat: friend,userId: userId?? "");;
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              width: 1,
                            );
                          },
                          itemCount: model?.chats.length ?? 0))
                  : const Center(
                      child: Text(
                          "You do not have chats. Please invite your loved ones and start chatting"),
                    )
            ],
          ),
        ),
      ),
    );
  }

  getChats() async {
     userId =
        await LocalStorageService.getString(LocalStorageService.userId) ?? "";

    notifier?.getChats(userId!);
  }



  Future<void> initialization() async {
    String userId =
        await LocalStorageService.getString(LocalStorageService.userId) ?? "";

    Future.delayed(
      const Duration(seconds: 1),
      () {
        notifier?.changedUserId(userId);
        notifier?.initializeFriends(userId);
        getChats();
      },
    );
  }

  @override
  void initState() {
    super.initState();

    initialization();
  }

  @override
  void setState(VoidCallback fn) {

    if(mounted){
      super.setState(fn);
    }
  }
}
