import 'package:appwrite/models.dart';
import 'package:auto_route/auto_route.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:chat_with_bisky/core/extensions/extensions.dart';
import 'package:chat_with_bisky/model/MessageState.dart';
import 'package:chat_with_bisky/model/UserAppwrite.dart';
import 'package:chat_with_bisky/model/db/MessageRealm.dart';
import 'package:chat_with_bisky/pages/dashboard/chat/MessageViewModel.dart';
import 'package:chat_with_bisky/pages/dashboard/chat/voice_calls/VoiceCallingPage.dart';
import 'package:chat_with_bisky/pages/dashboard/chat/voice_calls/VoiceCallsWebRTCHandler.dart';
import 'package:chat_with_bisky/widget/ChatHeadViewModel.dart';
import 'package:chat_with_bisky/widget/ChatMessageItem.dart';
import 'package:chat_with_bisky/widget/LoadingPageOverlay.dart';
import 'package:chat_with_bisky/widget/friend_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realm/realm.dart' as realm;
import 'package:chat_with_bisky/pages/dashboard/chat/video_calls/one_to_one/VideoCallVMScreen.dart';


@RoutePage()
class MessageScreen extends ConsumerStatefulWidget {
  String displayName;
  String myUserId;
  String friendUserId;
  UserAppwrite friendUser;
  String? profilePicture;

  MessageScreen(
      {required this.displayName,
      required this.myUserId,
      required this.friendUserId,
      required this.friendUser,
      this.profilePicture});

  ConsumerState<MessageScreen> createState() => _MessageScreenState(
      displayName: displayName, myUserId: myUserId, friendUserId: friendUserId
  ,profilePicture: profilePicture);
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  String displayName;
  String myUserId;
  String friendUserId;
  String? profilePicture;

  final TextEditingController _messageController = TextEditingController();
  MessageNotifier? messageNotifier;
  MessageState? messageState;
  final ScrollController _scrollController = ScrollController();

  _MessageScreenState(
      {required this.displayName,
      required this.myUserId,
      required this.friendUserId,
        this.profilePicture});

  @override
  Widget build(BuildContext context) {
    messageNotifier = ref.read(messageNotifierProvider.notifier);
    messageState = ref.watch(messageNotifierProvider);
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
                  FriendImage(profilePicture),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
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
                            messageState?.onlineStatus ?? '',
                            style: TextStyle(
                                color:messageState?.onlineStatus.contains('typing') == true?Colors.blue.shade600:Colors.grey.shade600, fontSize: 13)
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        ref.invalidate(voiceCallsWebRtcProvider);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VoiceCallingPage(
                              user: widget.friendUser,
                            )));
                      },
                      child: const Icon(
                        Icons.phone,
                        size: 27,
                        color: Colors.blue,
                      )),
                  const SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VideoCallVMScreen(
                              isCaller: true,
                              friend: widget.friendUser,
                              sessionDescription: null,
                              sessionType: null,
                              selId: widget.myUserId,
                            )));
                      },
                      child: const Icon(
                        Icons.video_call,
                        size: 27,
                        color: Colors.blue,
                      ))
                ],
              ),
            ),
          ),
        ),
        body: Form(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10.0),
                itemBuilder: (context, index) {
                  MessageRealm message =
                      messageState?.messages.elementAt(index) ??
                          MessageRealm(realm.ObjectId());

                  return chatMessageItem(message);
                },
                itemCount: messageState?.messages.length,
                reverse: true,
              )),
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
    messageNotifier?.initializeMessages(myUserId, friendUserId);
    messageNotifier?.getUserPresenceStatus(friendUserId);
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

    messageNotifier?.friendUserIdChanged(friendUserId);
    messageNotifier?.myUserIdChanged(myUserId);
    messageNotifier?.messageTypeChanged(type);
    messageNotifier?.messageChanged(message);
    messageNotifier?.sendMessage();
    _messageController.text = "";
  }

  void getMessages() {
    messageNotifier?.friendUserIdChanged(friendUserId);
    messageNotifier?.myUserIdChanged(myUserId);
    messageNotifier?.getMessages();
  }

  Widget chatMessageItem(MessageRealm documentSnapshot) {
    return ChatMessageItem(
      message: documentSnapshot,
      displayName: displayName,
      myMessage: documentSnapshot.senderUserId == myUserId,
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
}
