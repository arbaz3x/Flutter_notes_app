import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? lastEdited;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.lastEdited
  });

  factory Note.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      lastEdited: data['lastEdited'] != null
          ? (data['lastEdited'] as Timestamp).toDate()
          : null,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'lastEdited': lastEdited,
    };
  }
}

