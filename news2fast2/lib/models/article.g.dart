// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 0;

  @override
  Article read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Article(
      titre: fields[0] as String,
      auteur: fields[1] as String,
      date: fields[2] as String,
      lien: fields[3] as String,
      extrait: fields[4] as String,
      image: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.titre)
      ..writeByte(1)
      ..write(obj.auteur)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.lien)
      ..writeByte(4)
      ..write(obj.extrait)
      ..writeByte(5)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
