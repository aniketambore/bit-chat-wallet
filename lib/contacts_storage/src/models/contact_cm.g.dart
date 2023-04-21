// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_cm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactCMAdapter extends TypeAdapter<ContactCM> {
  @override
  final int typeId = 0;

  @override
  ContactCM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactCM(
      id: fields[0] as String,
      name: fields[1] as String,
      npub: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContactCM obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.npub);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactCMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
