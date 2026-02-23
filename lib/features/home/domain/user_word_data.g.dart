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
      learningStage: fields[9] as LearningStage,
      easeFactor: fields[10] == null ? 2.5 : fields[10] as double,
      interval: fields[11] == null ? 0 : fields[11] as int,
      repetitions: fields[12] == null ? 0 : fields[12] as int,
      hasBeenTested: fields[13] == null ? false : fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserWordData obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.learningStage)
      ..writeByte(10)
      ..write(obj.easeFactor)
      ..writeByte(11)
      ..write(obj.interval)
      ..writeByte(12)
      ..write(obj.repetitions)
      ..writeByte(13)
      ..write(obj.hasBeenTested);
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
