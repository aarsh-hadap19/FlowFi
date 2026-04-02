part of 'savings_streak.dart';

class SavingsStreakAdapter extends TypeAdapter<SavingsStreak> {
  @override
  final int typeId = 2;

  @override
  SavingsStreak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsStreak(
      currentStreak: fields[0] as int,
      longestStreak: fields[1] as int,
      createdAt: fields[3] as DateTime,
    )..lastUpdated = fields[2] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, SavingsStreak obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currentStreak)
      ..writeByte(1)
      ..write(obj.longestStreak)
      ..writeByte(2)
      ..write(obj.lastUpdated)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsStreakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
