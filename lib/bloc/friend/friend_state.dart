

import 'package:chat_with_bisky/model/FriendContact.dart';
import 'package:equatable/equatable.dart';

abstract class FriendState extends Equatable{

  @override

  List<Object?> get props => [];
}

class InitialFriendState extends FriendState{

}


class LoadingRefreshFriendsState extends FriendState{

}

class ReloadFriendsState extends FriendState{

}
class FriendsListState extends FriendState{


  List<FriendContact> friends;
  FriendsListState(this.friends);

  List<Object?> get props => [friends];
}
