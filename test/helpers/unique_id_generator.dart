import 'package:uuid/uuid.dart';

class UniqueIdGenerator {
  static const _uuid = Uuid();
  static String generate() => _uuid.v4();
}
