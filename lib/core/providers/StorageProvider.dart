import 'package:appwrite/appwrite.dart';
import 'package:chat_with_bisky/core/providers/AppwriteClientProvider.dart';
import 'package:chat_with_bisky/model/db/ChatRealm.dart';
import 'package:chat_with_bisky/model/db/FriendContactRealm.dart';
import 'package:chat_with_bisky/model/db/MessageRealm.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';


final storageProvider=  Provider((ref) => Storage(clientService.getClient()));
