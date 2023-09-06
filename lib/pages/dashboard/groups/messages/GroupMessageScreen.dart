import 'package:appwrite/models.dart';
import 'package:auto_route/auto_route.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:chat_with_bisky/constant/strings.dart';
import 'package:chat_with_bisky/core/extensions/extensions.dart';
import 'package:chat_with_bisky/model/GroupAppwrite.dart';
import 'package:chat_with_bisky/model/GroupMessageState.dart';
import 'package:chat_with_bisky/model/MessageState.dart';
import 'package:chat_with_bisky/model/UserAppwrite.dart';
import 'package:chat_with_bisky/model/db/MessageRealm.dart';
import 'package:chat_with_bisky/pages/dashboard/chat/MessageViewModel.dart';
import 'package:chat_with_bisky/pages/dashboard/chat/voice_calls/VoiceCallingPage.dart';
import 'package:chat_with_bisky/pages/dashboard/chat/voice_calls/VoiceCallsWebRTCHandler.dart';
import 'package:chat_with_bisky/pages/dashboard/groups/messages/GroupMessageViewModel.dart';
import 'package:chat_with_bisky/route/app_route/AppRouter.gr.dart';
import 'package:chat_with_bisky/widget/ChatHeadViewModel.dart';
import 'package:chat_with_bisky/widget/ChatMessageItem.dart';
import 'package:chat_with_bisky/widget/DefaultTempImage.dart';
import 'package:chat_with_bisky/widget/GroupChatMessageItem.dart';
import 'package:chat_with_bisky/widget/LoadingPageOverlay.dart';
import 'package:chat_with_bisky/widget/friend_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realm/realm.dart' as realm;

@RoutePage()
class GroupMessageScreen extends ConsumerStatefulWidget {
  String displayGroupName;
  String myUserId;
  String friendUserId;
  GroupAppwrite group;
  String? profilePicture;

  GroupMessageScreen(
      {required this.displayGroupName,
        required this.myUserId,
        required this.friendUserId,
        required this.group,
        this.profilePicture});

  ConsumerState<GroupMessageScreen> createState() => _GroupMessageScreenState(
      displayName: displayGroupName, myUserId: myUserId, friendUserId: friendUserId
      ,profilePicture: profilePicture);
}

class _GroupMessageScreenState extends ConsumerState<GroupMessageScreen> {
  String displayName;
  String myUserId;
  String friendUserId;
  String? profilePicture;

  final TextEditingController _messageController = TextEditingController();
  GroupMessageNotifier? messageNotifier;
  GroupMessageState? messageState;
  final ScrollController _scrollController = ScrollController();

  _GroupMessageScreenState(
      {required this.displayName,
        required this.myUserId,
        required this.friendUserId,
        this.profilePicture});

  @override
  Widget build(BuildContext context) {
    messageNotifier = ref.read(groupMessageNotifierProvider.notifier);
    messageState = ref.watch(groupMessageNotifierProvider);
    return LoadingPageOverlay(
      loading: messageState?.loading ?? false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  DefaultTempImage(Strings.profilePicturesBucketId,widget.group.pictureStorageId,size: 50,),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        AutoRouter.of(context).push(GroupDetailsRoute(myUserId: messageState?.myUserId ??"", group: messageState?.group??GroupAppwrite()));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            displayName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Expanded(
                            child: Text(
                                messageState?.groupDetails ?? '',
                                style: TextStyle(
                                    color:messageState?.groupDetails.contains('typing') == true?Colors.blue.shade600:Colors.grey.shade600, fontSize: 13)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
        body: Form(
          child: Column(
            children: [
              messageState?.messages?.isNotEmpty == true?
              Flexible(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      MessageRealm message =
                          messageState?.messages?.elementAt(index) ??
                              MessageRealm(realm.ObjectId());

                      return chatMessageItem(message);
                    },
                    itemCount: messageState?.messages?.length,
                    reverse: true,
                  )):Flexible(child: Container(),),
              chatInputWidget()
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => initialization(context));
  }

  initialization(BuildContext context) {
    messageNotifier?.initializeMessages();
    messageNotifier?.listenFriendIsTyping();
    getMessages();
  }


  chatInputWidget() {


    return  MessageBar(
      onSend: (message) =>  sendMessage("TEXT", message),
      onTextChanged: (value) {
        messageNotifier?.typingChanges(value);
      },
      actions: [
        InkWell(
          child: const Icon(
            Icons.add,
            color: Colors.black,
            size: 24,
          ),
          onTap: () {
            _modalBottomSheet();
          },
        ),
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: InkWell(
            child: Icon(
              Icons.camera_alt,
              color: Colors.blue,
              size: 24,
            ),
            onTap: () {

              pickImage(ImageSource.camera);
            },
          ),
        ),
      ],
    );
  }

  void pickImage(ImageSource source) async {
    Navigator.pop(context);
    final file = await context.pickAndCropImage(3 / 4, source);

    if (file != null) {
      print(file.path);

      File? fileUploaded = await messageNotifier?.uploadMedia(
          realm.ObjectId().hexString, file.path);

      if (fileUploaded != null) {
        sendMessage("IMAGE", fileUploaded.$id, file: fileUploaded);
      }
    }
  }

  void pickVideo() async {
    Navigator.pop(context);
    context.pickVideo(
      context,
          (file) async {
        print(file.path);

        File? fileUploaded = await messageNotifier?.uploadMedia(
            realm.ObjectId().hexString, file.path);

        if (fileUploaded != null) {
          sendMessage("VIDEO", fileUploaded.$id, file: fileUploaded);
        }
      },
    );
  }

  void sendMessage(String type, String message, {File? file}) {
    if (file != null) {
      messageNotifier?.onChangedUploadedFile(file);
    }

    messageNotifier?.updateGroupId(widget.group.id??'');
    messageNotifier?.myUserIdChanged(myUserId);
    messageNotifier?.messageTypeChanged(type);
    messageNotifier?.messageChanged(message);
    messageNotifier?.sendMessage();
    _messageController.text = "";
  }

  void getMessages() {
    messageNotifier?.updateGroupId(widget.group.id??'');
    messageNotifier?.setGroup(widget.group);
    messageNotifier?.myUserIdChanged(myUserId);
    messageNotifier?.getMessages();
  }

  Widget chatMessageItem(MessageRealm documentSnapshot) {
    return GroupChatMessageItem(
      message: documentSnapshot,
      displayName: displayName,
      myMessage: documentSnapshot.senderUserId == myUserId,
      myUserId: myUserId,
      messageLongPress: (value) => onMessageLongPress(value),
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _modalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          height: 250.0,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text("Select an Option"),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    pickVideo();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 38,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Icon(
                          Icons.video_camera_front,
                          color: Colors.grey,
                        ),
                        Text("Video"),
                        Spacer()
                      ],
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    pickImage(ImageSource.gallery);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 38,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                        Text("Image"),
                        Spacer()
                      ],
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    pickImage(ImageSource.camera);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 38,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                        ),
                        Text("Camera"),
                        Spacer()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    messageNotifier?.disconnect();
    ref.invalidate(chatHeadViewModelProvider);
    super.dispose();


  }


  void _messageInfoModalBottomSheet(MessageRealm messageRealm) {

    if(!myMessage(messageRealm)){
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          height: 250.0,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text("Actions"),
                const SizedBox(
                  height: 10,
                ),
                if(myMessage(messageRealm))
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      AutoRouter.of(context).push(GroupMessageDetailsRoute(myUserId: messageState?.myUserId ??"", group: messageState?.group??GroupAppwrite(), message: messageRealm));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 38,
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Icon(
                            Icons.info,
                            color: Colors.blue,
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("View Details"),
                          ),
                          Spacer()
                        ],
                      ),
                    ),
                  ),
                const Divider(),
                if(myMessage(messageRealm))
                  InkWell(
                    onTap: () async{
                      Navigator.pop(context);

                      bool? deleted = await messageNotifier?.deleteMessage(messageRealm.messageIdUpstream??"");
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 38,
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Delete"),
                          ),
                          Spacer()
                        ],
                      ),
                    ),
                  ),

              ],
            ),
          ),
        );
      },
    );
  }

  bool myMessage(MessageRealm messageRealm) => myUserId == messageRealm.senderUserId;

  onMessageLongPress(MessageRealm value) {

    _messageInfoModalBottomSheet(value);
  }
}
