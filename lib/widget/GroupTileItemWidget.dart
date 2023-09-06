import 'package:auto_route/auto_route.dart';
import 'package:chat_with_bisky/constant/strings.dart';
import 'package:chat_with_bisky/core/extensions/extensions.dart';
import 'package:chat_with_bisky/core/providers/GetGroupMessageInfoProvider.dart';
import 'package:chat_with_bisky/core/providers/GroupMessagesInfoRepositoryProvider.dart';
import 'package:chat_with_bisky/model/GroupAppwrite.dart';
import 'package:chat_with_bisky/route/app_route/AppRouter.gr.dart';
import 'package:chat_with_bisky/widget/DefaultTempImage.dart';
import 'package:chat_with_bisky/widget/friend_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GroupTileItemWidget extends ConsumerStatefulWidget {
  final GroupAppwrite group;
  final String userId;
  const GroupTileItemWidget({
    super.key,
    required this.group,
    required this.userId,
  });
  @override
  _GroupTileItemWidget createState() {

    return _GroupTileItemWidget();
  }
}
class _GroupTileItemWidget extends ConsumerState <GroupTileItemWidget>{

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme;
    bool isRead = widget.group.read == true;

    return ListTile(
      leading: DefaultTempImage(Strings.profilePicturesBucketId,widget.group.pictureStorageId,size: 50,),
      title:  Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(widget.group.name ?? "",
              maxLines: 1,
              style: style.labelSmall?.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,),
          ),

          const Spacer(flex: 2,),
          Text(widget.group.sendDate!.getFormattedTime(), maxLines: 1,
            overflow: TextOverflow.ellipsis,style: style.labelSmall?.copyWith(fontSize: 10),),
        ],
      ),
      // subtitle: Text(friend.message ?? ""),
      subtitle: Row(
        children: [
          Expanded(
            child:  chatMessage(isRead),
          ),

          if(myMessage())
            Icon(widget.group.read == true || widget.group.delivered == true?
            Icons.done_all_rounded : Icons.done_rounded,
              size: 16,
              color: widget.group.read == true? Colors.green.shade800:Colors.grey,),
          if (!isRead && !myMessage())
            Consumer(builder: (context, ref, child) {

              final messageInfoAsync =ref.watch(getGroupMessageInfoProvider(widget.group,widget.userId));
              return messageInfoAsync.when(data: (data) {


                if(data?.read == true){
                  return const SizedBox();
                }
                return const CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 8,
                  child: Text(
                    '',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                );

              }, error: (error, stackTrace) => const SizedBox(), loading: () =>  const SizedBox(width: 20, child: LinearProgressIndicator()));
            },),
        ],
      ),
      onTap: () async {

        AutoRouter.of(context).push(GroupMessageRoute(displayGroupName: widget.group.name ?? "",
            myUserId:widget.userId,
            friendUserId:widget.group.sendUserId ?? "",group: widget.group,profilePicture: widget.group.pictureStorageId));
        ref.read(groupMessagesInfoRepositoryProvider).updateGroupMemberMessagesInfoSeen(widget.group.id??"",widget.userId,widget.group.messageId?? "");


      },
    );
  }

  Widget chatMessage(bool isRead) {
    if (widget.group.messageType == 'IMAGE') {
      return const Align(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Icon(Icons.image,color: Colors.blue),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("image",style: TextStyle(color: Colors.blue,fontSize: 12),),
            )
          ],
        ),
      );
    } else if (widget.group.messageType == 'VIDEO') {
      return const Align(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Icon(Icons.video_chat,color: Colors.blue,),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text("video",style: TextStyle(color: Colors.blue,fontSize: 12),),
            )
          ],
        ),
      );
    } else {
      return  Text(
        widget.group.message ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: !isRead && !myMessage() ? FontWeight.bold : null,
        ),
      );
    }
  }

  bool myMessage(){

    return widget.group.sendUserId == widget.userId;
  }


}
