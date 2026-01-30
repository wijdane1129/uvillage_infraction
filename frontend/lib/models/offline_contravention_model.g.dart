// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_contravention_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineContraventionAdapter extends TypeAdapter<OfflineContravention> {
  @override
  final int typeId = 1;

  @override
  OfflineContravention read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineContravention(
      id: fields[0] as String,
      description: fields[1] as String,
      typeLabel: fields[2] as String,
      userAuthorId: fields[3] as int,
      tiersId: fields[4] as int?,
      mediaUrls: (fields[5] as List).cast<String>(),
      mediaTypes: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      isSynced: fields[9] as bool,
      syncError: fields[10] as String?,
      syncAttempts: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineContravention obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.typeLabel)
      ..writeByte(3)
      ..write(obj.userAuthorId)
      ..writeByte(4)
      ..write(obj.tiersId)
      ..writeByte(5)
      ..write(obj.mediaUrls)
      ..writeByte(6)
      ..write(obj.mediaTypes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.syncError)
      ..writeByte(11)
      ..write(obj.syncAttempts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineContraventionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
