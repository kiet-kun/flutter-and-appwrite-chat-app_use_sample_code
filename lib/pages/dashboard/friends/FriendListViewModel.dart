



import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chat_with_bisky/constant/strings.dart';
import 'package:chat_with_bisky/core/providers/DatabaseProvider.dart';
import 'package:chat_with_bisky/core/providers/RealmProvider.dart';
import 'package:chat_with_bisky/model/FriendContact.dart';
import 'package:chat_with_bisky/model/FriendState.dart';
import 'package:chat_with_bisky/model/db/FriendContactRealm.dart';
import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/services.dart';
import 'package:chat_with_bisky/core/providers/StorageProvider.dart';
import 'package:chat_with_bisky/core/providers/UserRepositoryProvider.dart';
import 'package:chat_with_bisky/core/util/Util.dart';
part 'FriendListViewModel.g.dart';
@riverpod
class FriendListNotifier  extends _$FriendListNotifier{

  Databases get _databases => ref.read(databaseProvider);
  Realm get _realm => ref.read(realmProvider);
  Storage get _storage => ref.read(storageProvider);
  @override
  FriendState build(){
    ref.keepAlive();
    return FriendState();
  }


  changedUserId(String userId){

    state = state.copyWith(
      myUserId: userId
    );
  }

  getMyFriends(String userId) async {


    DocumentList documentList = await _databases.listDocuments(databaseId: Strings.databaseId,
        collectionId: Strings.collectionContactsId,
        queries: [
          Query.equal("userId", [userId]),
        ]);

    if(documentList.total > 0){

      List<Document> documents =documentList.documents;

      for(Document document in documents){

        FriendContact friend = FriendContact.fromJson(document.data);

        FriendContactRealm friendContactRealm = FriendContactRealm(
          ObjectId(),
          userId: friend.userId,
          mobileNumber: friend.mobileNumber,
          displayName: friend.displayName,
        );
        final user = await ref.read(userRepositoryProvider).getUser(friend.mobileNumber??"");
        if(user != null && user.profilePictureStorageId != null){
          Uint8List imageBytes = await _storage.getFilePreview(
            bucketId: Strings.profilePicturesBucketId,
            fileId: user.profilePictureStorageId ?? "",
          );
          friendContactRealm.base64Image = uint8ListToBase64(imageBytes);
        }
        createOrUpdateFriend(friendContactRealm);

      }
      initializeFriends(userId);

    }

  }



  createOrUpdateFriend(FriendContactRealm friendContactRealm){

    final results = _realm.query<FriendContactRealm>(r'mobileNumber = $0',[friendContactRealm.mobileNumber]);

    print(friendContactRealm.userId);
    print(friendContactRealm.displayName);
    print(friendContactRealm.mobileNumber);
    print(results.length);
    if(results.isNotEmpty){
      FriendContactRealm retrieved = results.first;
      friendContactRealm.id = retrieved.id;
    }

    _realm.write(() {
      _realm.add(friendContactRealm,update: true);

    });
  }

  initializeFriends(String userId){

    final results = _realm.query<FriendContactRealm>(r'userId = $0 SORT(displayName ASC)',[userId]);

    print(results.length);
    if(results.isNotEmpty){
      state = state.copyWith(
        friends: results.toList()
      );
    }

  }


}
