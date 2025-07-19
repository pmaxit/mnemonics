// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_word_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserWordDataAdapter extends TypeAdapter<UserWordData> {
  @override
  final int typeId = 0;

  @override
  UserWordData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserWordData(
      word: fields[0] as String,
      notes: fields[1] as String,
      isLearned: fields[2] as bool,
      nextReview: fields[3] as DateTime?,
      reviewCount: fields[4] as int,
      lastReviewedAt: fields[5] as DateTime?,
      firstLearnedAt: fields[6] as DateTime?,
      correctAnswers: fields[7] as int,
      totalAnswers: fields[8] as int,
      learningStage: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserWordData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.notes)
      ..writeByte(2)
      ..write(obj.isLearned)
      ..writeByte(3)
      ..write(obj.nextReview)
      ..writeByte(4)
      ..write(obj.reviewCount)
      ..writeByte(5)
      ..write(obj.lastReviewedAt)
      ..writeByte(6)
      ..write(obj.firstLearnedAt)
      ..writeByte(7)
      ..write(obj.correctAnswers)
      ..writeByte(8)
      ..write(obj.totalAnswers)
      ..writeByte(9)
      ..write(obj.learningStage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserWordDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
