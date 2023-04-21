import 'package:hive/hive.dart';

part 'contact_cm.g.dart';

@HiveType(typeId: 0)
class ContactCM {
  const ContactCM({
    required this.id,
    required this.name,
    required this.npub,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String npub;
}
