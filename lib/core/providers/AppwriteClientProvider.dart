

import 'package:appwrite/appwrite.dart';
import 'package:chat_with_bisky/constant/strings.dart';
import 'package:chat_with_bisky/service/AppwriteClient.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appwriteClientProvider = Provider<Client>(
      (ref)  {
    final channel = Client(
      endPoint: "https://cloud.appwrite.io/v1",
    );
    channel.setProject(Strings.projectId);
    channel.setSelfSigned();
    return channel;
  },
);


final AppWriteClientService clientService = AppWriteClientService();
