


import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:bloc/bloc.dart';
import 'package:chat_with_bisky/bloc/friend/friend_event.dart';
import 'package:chat_with_bisky/bloc/friend/friend_state.dart';
import 'package:chat_with_bisky/constant/strings.dart';
import 'package:chat_with_bisky/model/FriendContact.dart';
import 'package:chat_with_bisky/model/UserAppwrite.dart';
import 'package:chat_with_bisky/service/AppwriteClient.dart';
import 'package:chat_with_bisky/service/LocalStorageService.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:kiwi/kiwi.dart';
import 'package:uuid/uuid.dart';

class FriendBloc extends Bloc<FriendEvent,FriendState>{


  final AppWriteClientService  appWriteClientService= KiwiContainer().resolve<AppWriteClientService>();
  FriendBloc(FriendState friendState): super(friendState){

    on<ContactsListEvent>((event,emit) async{


      await getContactsListAndPersistFriend(event,emit);
    });
    on<LoadExistingFriendsEvent>((event,emit) async{


      await loadExistingFriends(event,emit);
    });
  }

  getContactsListAndPersistFriend(ContactsListEvent event, Emitter<FriendState> emit) async {


    if(kIsWeb){

      return;
    }

    try{


      List<Contact>  contacts = await ContactsService.getContacts(withThumbnails: false);
      print(contacts.length);
      if(contacts.isNotEmpty){



        emit(LoadingRefreshFriendsState());

        List<String> mobileNumbers = [];

        String userId = await LocalStorageService.getString(LocalStorageService.userId) ?? "";

        Map<String,List<String>> contactsMap = {};
        for(Contact contact in contacts){



          if(contact.phones != null && contact.phones?.isNotEmpty == true){


            for(Item item in contact.phones!){

              String? phone = item.value;


              if(phone != null){

                //+3249 323 343
                //+3249-323-343
                //3249323343
                //049323343
                phone = phone.replaceAll(" ", "");

                if(phone.startsWith("+")){

                  phone = phone.substring(1);
                }else if(phone.startsWith("0")){

                  //01222222222
                  String dialCode = await LocalStorageService.getString(LocalStorageService.dialCode) ?? "";
                  //321222222222
                  phone = "$dialCode${phone.substring(1)}";
                }

                phone = removeSpecialCharacters(phone);

                if(phone.isEmpty){

                  continue;
                }

                if(mobileNumbers.length >= 100){

                  contactsMap[const Uuid().v4()] = mobileNumbers;
                  mobileNumbers = [];
                  mobileNumbers.add(phone);

                }else{

                  mobileNumbers.add(phone);

                }

              }


            }


          }


        }

        if(mobileNumbers.isNotEmpty && mobileNumbers.length < 100){

          contactsMap[const Uuid().v4()] = mobileNumbers;

        }

        if(contactsMap.isNotEmpty){
          print(userId);
          contactsMap.forEach((key, value) async {

            Databases databases = Databases(appWriteClientService.getClient());

            print(value);
            DocumentList documentList = await databases.listDocuments(databaseId: Strings.databaseId,
                collectionId: Strings.collectionUsersId,
            queries: [
              Query.equal('userId', value)
            ]);

            if(documentList.total > 0){


              // create friend
              List<FriendContact>  friends = [];
              for(Document document in documentList.documents){

                UserAppwrite user =  UserAppwrite.fromJson(document.data);

                FriendContact contact= FriendContact(
                  mobileNumber: user.userId,
                  displayName: user.name,
                  userId: userId,
                );

                friends.add(contact);


              }

              createOrUpdateMyFriends(friends,userId);

            }
          });
          emit(ReloadFriendsState());
        }


      }


    }catch(exception){


      print(exception);

      emit(ReloadFriendsState());

    }


  }

  String removeSpecialCharacters(String mobileNumber){

    return mobileNumber.replaceAll(RegExp('[^0-9]'), '');
  }

  Future<void> createOrUpdateMyFriends(List<FriendContact> friends,String userId) async {


    Databases databases = Databases(appWriteClientService.getClient());

    for(FriendContact friend in friends){

      try{

        DocumentList documentList = await databases.listDocuments(databaseId: Strings.databaseId, collectionId: Strings.collectionContactsId,
        queries: [
          Query.equal("mobileNumber", [friend.mobileNumber ?? ""]),
          Query.equal("userId", [userId]),
        ]);

        if(documentList.total > 0){

          Document document = documentList.documents.first;
          FriendContact friendContact =  FriendContact.fromJson(document.data);
          friendContact.displayName = friend.displayName;

          Document updatedDocument = await databases.updateDocument(databaseId: Strings.databaseId, collectionId: Strings.collectionContactsId, documentId: document.$id,data: friendContact.toJson());

        print("contact document updated ${updatedDocument.$id}");
        }else{


          Document newDocument = await databases.createDocument(databaseId: Strings.databaseId, collectionId: Strings.collectionContactsId, documentId: const Uuid().v4(), data: friend.toJson());

          print("contact document created ${newDocument.$id}");
        }

      }catch (exception){


        print(exception);

      }

    }


  }

  loadExistingFriends(LoadExistingFriendsEvent event, Emitter<FriendState> emit) async {



    try{


      Databases databases = Databases(appWriteClientService.getClient());


      String userId= await LocalStorageService.getString(LocalStorageService.userId) ?? "";

      DocumentList documentList = await databases.listDocuments(databaseId: Strings.databaseId, collectionId: Strings.collectionContactsId,
          queries: [
            Query.equal("userId", [userId]),
          ]);

      if(documentList.total > 0){

        List<Document> documents =documentList.documents;
        List<FriendContact> friends = [];
        for(Document document in documents){


          FriendContact friend = FriendContact.fromJson(document.data);
          friends.add(friend);
        }

        emit(FriendsListState(friends));

      }


    }catch (exception){

      print(exception);
    }

  }



}
