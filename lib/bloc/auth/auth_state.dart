

import 'package:appwrite/models.dart';
import 'package:chat_with_bisky/model/UserAppwrite.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class  AuthState extends Equatable{


  @override
  List<Object> get props => [];
}

class InitialAuthState extends AuthState{}
class LoadingLoginAuthState extends AuthState{}
class SuccessLoginAuthState extends AuthState{


  Token token;
  SuccessLoginAuthState(this.token);

  @override
  List<Object> get props => [token];

}

class FailureLoginAuthState extends AuthState{

  String message;
  FailureLoginAuthState(this.message);

  @override
  List<Object> get props => [message];

}

class LoadingOtpVerificationAuthState extends AuthState{}

class FailureOtpVerificationAuthState extends AuthState{

  String message;
  FailureOtpVerificationAuthState(this.message);

  @override
  List<Object> get props => [message];

}

class SuccessOtpVerificationAuthState extends AuthState{


  Session session;
  SuccessOtpVerificationAuthState(this.session);

  @override
  List<Object> get props => [session];

}

class LoadingUpdateUserAuthState extends AuthState{}


class SuccessUpdateUserAuthState extends AuthState{


  UserAppwrite userAppwrite;
  SuccessUpdateUserAuthState(this.userAppwrite);

  @override
  List<Object> get props => [userAppwrite];

}

class FailureUpdateUserAuthState extends AuthState{

  String message;
  FailureUpdateUserAuthState(this.message);

  @override
  List<Object> get props => [message];

}


class LoadingUploadingProfilePictureAuthState extends AuthState{}
class FailureUploadingProfilePictureAuthState extends AuthState{

  String message;
  FailureUploadingProfilePictureAuthState(this.message);

  @override
  List<Object> get props => [message];

}
class SuccessUploadProfilePictureAuthState extends AuthState{


  File file;
  SuccessUploadProfilePictureAuthState(this.file);

  @override
  List<Object> get props => [file];

}
class SuccessgetExistingUserAuthState extends AuthState{


  UserAppwrite user;
  SuccessgetExistingUserAuthState(this.user);

  @override
  List<Object> get props => [user];

}
class ExistingProfilePictureAuthState extends AuthState{


  Uint8List uint8list;
  ExistingProfilePictureAuthState(this.uint8list);

  @override
  List<Object> get props => [uint8list];

}
