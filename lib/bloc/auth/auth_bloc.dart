


import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:bloc/bloc.dart';
import 'package:chat_with_bisky/bloc/auth/auth_event.dart';
import 'package:chat_with_bisky/bloc/auth/auth_state.dart';
import 'package:chat_with_bisky/constant/strings.dart';
import 'package:chat_with_bisky/model/UserAppwrite.dart';
import 'package:chat_with_bisky/service/AppwriteClient.dart';
import 'package:flutter/foundation.dart';
import 'package:kiwi/kiwi.dart';

class AuthBloc extends Bloc<AuthEvent,AuthState>{


  final AppWriteClientService  appWriteClientService= KiwiContainer().resolve<AppWriteClientService>();

  AuthBloc(AuthState authState) : super(authState){

    on<MobileNumberLoginEvent>((event,state) async{

      await loginWithMobileNumber(event,state);
    });

    on<MobileNumberVerificationEvent>((event,state) async{

      await mobileNumberVerification(event,state);
    });
    on<UpdateUserEvent>((event,state) async{

      await updateUser(event,state);
    });
    on<UploadProfilePictureEvent>((event,state) async{

      await uploadProfilePicture(event,state);
    });

    on<GetExistingUserEvent>((event,state) async{

      await getExistingUser(event,state);
    });

    on<GetExistingProfilePictureEvent>((event,state) async{

      await getExistingProfilePicture(event,state);
    });

  }


  loginWithMobileNumber(MobileNumberLoginEvent event, Emitter<AuthState> state) async {

    emit(LoadingLoginAuthState());
    try{

      Account account = Account(appWriteClientService.getClient());

      String mobileNumber = event.mobileNumber;
      Token token = await account.createPhoneSession(
        userId: mobileNumber.substring(1), //+32444444
        phone: mobileNumber,
      );


      print(token.$id);
      print(token.userId);
      emit(SuccessLoginAuthState(token));
    }on AppwriteException catch  (exception){

      print(exception);
      emit(FailureLoginAuthState("Error, please try again later"));
    }

  }

  mobileNumberVerification(MobileNumberVerificationEvent event, Emitter<AuthState> state) async {


    emit(LoadingOtpVerificationAuthState());


    try{

      Account account = Account(appWriteClientService.getClient());

      Session session = await account.updatePhoneSession(
        userId: event.userId,
        secret: event.secret,
      );

      emit(SuccessOtpVerificationAuthState(session));

    }catch (exception){

      print(exception);
      emit(FailureOtpVerificationAuthState("Invalid code supplied"));
    }

  }

  updateUser(UpdateUserEvent event, Emitter<AuthState> state) async {

    Databases databases = Databases(appWriteClientService.getClient());
    UserAppwrite userAppwrite= UserAppwrite(userId: event.userId,name: event.name,
        profilePictureStorageId: event.profilePictureStorageId);

    emit(LoadingUpdateUserAuthState());
    try{

      Account account = Account(appWriteClientService.getClient());

      await account.updateName(
        name: event.name
      );

      await databases.getDocument(databaseId: Strings.databaseId,
          collectionId: Strings.collectionUsersId, documentId: event.userId);

      Document document1 = await databases.updateDocument(databaseId: Strings.databaseId, collectionId: Strings.collectionUsersId,
          documentId: event.userId, data: userAppwrite.toJson());

      UserAppwrite userUpdate = UserAppwrite.fromJson(document1.data);

      emit(SuccessUpdateUserAuthState(userUpdate));

    }on AppwriteException  catch (exception){

      print(exception);

      if(exception.code == 404){

        Document document = await databases.createDocument(databaseId: Strings.databaseId, collectionId: Strings.collectionUsersId,
            documentId: event.userId, data: userAppwrite.toJson());

        UserAppwrite user = UserAppwrite.fromJson(document.data);

        emit(SuccessUpdateUserAuthState(user));

      }else{
        emit(FailureUpdateUserAuthState("Failed to update your name. Please try again later"));
      }
    }

  }

  uploadProfilePicture(UploadProfilePictureEvent event, Emitter<AuthState> state) async {

    try{

      emit(LoadingUploadingProfilePictureAuthState());
      Storage storage= Storage(appWriteClientService.getClient());

      if(event.imageExist.isNotEmpty && event.imageId != event.imageExist){

        await storage.deleteFile(bucketId: Strings.profilePicturesBucketId, fileId: event.imageExist);
      }

      print(Strings.profilePicturesBucketId);
      File file = await storage.createFile(
        bucketId: Strings.profilePicturesBucketId,
        fileId: event.imageId,
        file: InputFile(path: event.path, filename: '${event.imageId}.${getFileExtension(event.path)}'),
      );

      emit(SuccessUploadProfilePictureAuthState(file));
    }on AppwriteException  catch (exception){

      print(exception);

      emit(FailureUploadingProfilePictureAuthState("Failed to upload profile picture"));

    }
  }
  String getFileExtension(String fileName) {
    try {
      return ".${fileName.split('.').last}";
    } catch(e){
      return "";
    }
  }


  getExistingUser(GetExistingUserEvent event, Emitter<AuthState> state) async {


    Databases databases = Databases(appWriteClientService.getClient());

    try{


      Document document = await databases.getDocument(databaseId: Strings.databaseId,
          collectionId: Strings.collectionUsersId, documentId: event.userId);
      UserAppwrite userUpdate = UserAppwrite.fromJson(document.data);

      emit(SuccessgetExistingUserAuthState(userUpdate));

    }on AppwriteException  catch (exception){

      print(exception);


    }

  }

  getExistingProfilePicture(GetExistingProfilePictureEvent event, Emitter<AuthState> state) async {

    try{

      Storage storage= Storage(appWriteClientService.getClient());

      Uint8List uint8list = await storage.getFilePreview(
          bucketId: Strings.profilePicturesBucketId,
          fileId: event.imageId);

      emit(ExistingProfilePictureAuthState(uint8list));

    }on AppwriteException  catch (exception){

      print(exception);


    }
  }


}
