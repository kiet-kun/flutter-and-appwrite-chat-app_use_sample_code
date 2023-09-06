import 'package:chat_with_bisky/model/GroupMemberAppwrite.dart';
import 'package:chat_with_bisky/widget/UserImage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GroupMemberTileWidget extends HookConsumerWidget {
  GroupMemberAppwrite member;
  String userId;

  GroupMemberTileWidget(this.member, this.userId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style = theme.textTheme;
    return ListTile(
      leading: UserImage(member.memberUserId ?? ""),
      title: Text(
        member.name ?? "",
        maxLines: 1,
        style: style.labelSmall
            ?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text((member.admin == true) ? "Admin" : 'Member'),
        ],
      ),
      onTap: () async {},
    );
  }
}
