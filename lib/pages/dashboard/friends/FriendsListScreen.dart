import 'package:auto_route/auto_route.dart';
import 'package:chat_with_bisky/bloc/friend/friend_bloc.dart';
import 'package:chat_with_bisky/bloc/friend/friend_state.dart' as fBloc;
import 'package:chat_with_bisky/model/FriendContact.dart';
import 'package:chat_with_bisky/model/FriendState.dart' as frendRiverpodState;
import 'package:chat_with_bisky/model/UserAppwrite.dart';
import 'package:chat_with_bisky/model/db/FriendContactRealm.dart';
import 'package:chat_with_bisky/pages/dashboard/friends/FriendListViewModel.dart';
import 'package:chat_with_bisky/route/app_route/AppRouter.gr.dart';
import 'package:chat_with_bisky/service/LocalStorageService.dart';
import 'package:chat_with_bisky/widget/custom_app_bar.dart';
import 'package:chat_with_bisky/widget/friend_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../bloc/friend/friend_event.dart';
import '../../../bloc/friend/friend_state.dart';

class FriendsListScreen extends  ConsumerStatefulWidget {
  @override
  ConsumerState<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends ConsumerState<FriendsListScreen> {

  FriendListNotifier? notifier;
  frendRiverpodState.FriendState? model;
  
  


  @override
  Widget build(BuildContext context) {


    notifier = ref.read(friendListNotifierProvider.notifier);
    model = ref.watch(friendListNotifierProvider);
    
    
    
    return BlocListener<FriendBloc, fBloc.FriendState>(
      listener: (context, state) async {

        if (state is ReloadFriendsState){

          getFriends();

        }else if (state is FriendsListState){
          getFriends();
    
        }

      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [

                CustomBarWidget(
                  "Friends",
                  actions: Row(
                    children: [

                      if (!kIsWeb)
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            print("your menu action here to refresh");

                            refreshFriends();
                          },
                        ),

                    ],
                  ),
                ),


                model?.friends.isNotEmpty == true
                    ? Expanded(
                        child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              
                              FriendContactRealm friend  = model!.friends[index];
                              return ListTile(
                                leading: FriendImage(friend.base64Image),
                                title: Text(friend.displayName ?? ""),
                                onTap: () async {

                                  String userId =  await LocalStorageService.getString(LocalStorageService.userId) ?? "";

                                  AutoRouter.of(context).push(MessageRoute(displayName: friend.displayName ?? "",myUserId:userId,friendUserId:friend.mobileNumber ?? "",
                                      friendUser: UserAppwrite(userId: friend.mobileNumber,
                                      name: friend.displayName)));

                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                width: 1,
                              );
                            },
                            itemCount:  model?.friends.length ?? 0))
                    : const Center(
                  child: Text("You do not have friends. Please invite your loved ones and start chatting"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  getFriends() async {

    print("getfriemnds");
    if(mounted){
      String userId =  await LocalStorageService.getString(LocalStorageService.userId) ?? "";

      notifier?.getMyFriends(userId);
    }
  }

  void refreshFriends() {

    BlocProvider.of<FriendBloc>(context).add(ContactsListEvent());

  }


  Future<void> initialization() async {

    String userId =  await LocalStorageService.getString(LocalStorageService.userId) ?? "";

    Future.delayed(const Duration(seconds: 1),() {

      notifier?.changedUserId(userId);
      notifier?.initializeFriends(userId);

    },);

  }

  @override
  void initState() {
    super.initState();

    initialization();

  }
}
