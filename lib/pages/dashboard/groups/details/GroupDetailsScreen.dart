import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:chat_with_bisky/constant/strings.dart';
import 'package:chat_with_bisky/core/extensions/extensions.dart';
import 'package:chat_with_bisky/core/providers/FileTempProvider.dart';
import 'package:chat_with_bisky/model/GroupAppwrite.dart';
import 'package:chat_with_bisky/model/GroupDetailsState.dart';
import 'package:chat_with_bisky/model/GroupMemberAppwrite.dart';
import 'package:chat_with_bisky/pages/dashboard/groups/details/GroupDetailsViewModel.dart';
import 'package:chat_with_bisky/widget/GroupMemberTileWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class GroupDetailsScreen extends ConsumerStatefulWidget {
  final GroupAppwrite group;
  final String myUserId;

  const GroupDetailsScreen(
      {super.key, required this.group, required this.myUserId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _GroupDetailsScreenState();
  }
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> {
  GroupDetailsViewModel? _notifier;
  GroupDetailsState? _state;

  @override
  Widget build(BuildContext context) {
    _notifier = ref.read(groupDetailsViewModelProvider.notifier);
    _state = ref.watch(groupDetailsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name ?? "")),
      body: SizedBox(
        width: MediaQuery.of(context).size.width, // added
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => pickImage(ImageSource.gallery),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Consumer(builder: (context, ref, child) {
                    final fileAsync = ref.watch(fileTempProvider(
                        Strings.profilePicturesBucketId,
                        _state?.group?.pictureStorageId ?? ""));
                    return fileAsync.when(
                      data: (file) => groupPicturePicture(file),
                      error: (error, stackTrace) {

                        return const CircleAvatar(
                          radius: 50.0,
                          backgroundImage: NetworkImage(Strings.avatarImageUrl),
                        );
                      },
                      loading: () => const SizedBox(
                          width: 20, child: LinearProgressIndicator()),
                    );
                  }),
                  const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 30,
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Group members'),
            ),
            if (_state?.members?.isNotEmpty == true)
              Expanded(
                  child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        GroupMemberAppwrite member = _state!.members![index];
                        return GroupMemberTileWidget(
                            member, _state?.myUserId ?? "");
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: 1,
                        );
                      },
                      itemCount: _state?.members?.length ?? 0))
          ],
        ),
      ),
    );
  }

  groupPicturePicture(File file) {
    Uint8List uint8list = Uint8List.fromList(file.readAsBytesSync());
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(radius: 50.0, backgroundImage: MemoryImage(uint8list)),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialization());
  }

  Future<void> initialization() async {
    _notifier?.setUserId(widget.myUserId);
    _notifier?.setGroup(widget.group);
    _notifier?.getGroupMembers(widget.group.id ?? "");
    _notifier?.getGroupImage();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void pickImage(ImageSource source) async {
    final file = await context.pickAndCropImage(3 / 4, source);

    if (file != null) {
      print(file.path);
      bool? fileUploaded =
      await _notifier?.uploadGroupProfilePicture(file.path);

      if (fileUploaded == true) {
        print('FILE UPLEADED');
      }
    }
  }
}
