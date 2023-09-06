

import 'package:equatable/equatable.dart';

abstract class  AuthEvent extends Equatable{


  @override
  List<Object> get props => [];
}


class MobileNumberLoginEvent extends AuthEvent{

  String mobileNumber;

  MobileNumberLoginEvent(this.mobileNumber);

  @override
  List<Object> get props => [mobileNumber];

}
class MobileNumberVerificationEvent extends AuthEvent{

  String userId;
  String secret;

  MobileNumberVerificationEvent(this.userId,this.secret);

  @override
  List<Object> get props => [userId,secret];

}


class UpdateUserEvent extends AuthEvent{

  final String userId;
  final String name;
  final String profilePictureStorageId;

   UpdateUserEvent(this.userId, this.name, this.profilePictureStorageId);

  @override
  List<Object> get props => [userId,name,profilePictureStorageId];

}

class UploadProfilePictureEvent extends AuthEvent{

  final String path;
  final String imageId;
  final String imageExist;

  UploadProfilePictureEvent( this.path,  this.imageId, this.imageExist);

  @override
  List<Object> get props => [path,imageId,imageExist];

}


class GetExistingUserEvent extends AuthEvent{

  final String userId;

  GetExistingUserEvent(this.userId);

  @override
  List<Object> get props => [userId];

}
class GetExistingProfilePictureEvent extends AuthEvent{

  final String imageId;

  GetExistingProfilePictureEvent(this.imageId);

  @override
  List<Object> get props => [imageId];

}
