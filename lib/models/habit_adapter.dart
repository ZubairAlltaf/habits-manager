import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'habit.dart';

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    return Habit(
      id: reader.readString(),
      name: reader.readString(),
      icon: IconData(reader.readInt(), fontFamily: 'MaterialIcons'),
      createdAt: DateTime.parse(reader.readString()),
      dailyStatus: Map<String, bool>.from(reader.readMap()),
      category: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.icon.codePoint);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeMap(obj.dailyStatus);
    writer.writeString(obj.category);
  }
}
