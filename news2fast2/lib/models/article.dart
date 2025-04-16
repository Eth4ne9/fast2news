import 'package:hive/hive.dart';

part 'article.g.dart';

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  String titre;

  @HiveField(1)
  String auteur;

  @HiveField(2)
  String date;

  @HiveField(3)
  String lien;

  @HiveField(4)
  String extrait;

  @HiveField(5)
  String image;

  // Constructor
  Article({
    required this.titre,
    required this.auteur,
    required this.date,
    required this.lien,
    required this.extrait,
    required this.image,
  });

  // Factory for converting Firestore data into an Article object
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      titre: map['titre'] ?? '',
      auteur: map['auteur'] ?? '',
      date: map['date'] ?? '',
      lien: map['lien'] ?? '',
      extrait: map['extrait'] ?? '',
      image: map['image'] ?? '',
    );
  }

  // Convert an Article object into a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'auteur': auteur,
      'date': date,
      'lien': lien,
      'extrait': extrait,
      'image': image,
    };
  }

  // Factory for converting JSON into an Article object
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      titre: json['titre'] ?? '',
      auteur: json['auteur'] ?? '',
      date: json['date'] ?? '',
      lien: json['lien'] ?? '',
      extrait: json['extrait'] ?? '',
      image: json['image'] ?? '',
    );
  }

  // Convert an Article object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'auteur': auteur,
      'date': date,
      'lien': lien,
      'extrait': extrait,
      'image': image,
    };
  }
}
