// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewActivityAdapter extends TypeAdapter<ReviewActivity> {
  @override
  final int typeId = 2;

  @override
  ReviewActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewActivity(
      word: fields[0] as String,
      reviewedAt: fields[1] as DateTime,
      rating: fields[2] as ReviewDifficultyRating,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewActivity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.reviewedAt)
      ..writeByte(2)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
