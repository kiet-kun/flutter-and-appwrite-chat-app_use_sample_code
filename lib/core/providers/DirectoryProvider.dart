

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final directoryProvider = FutureProvider((ref) => getApplicationDocumentsDirectory());
