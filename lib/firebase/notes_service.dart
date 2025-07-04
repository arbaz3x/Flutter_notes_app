import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../note.dart';

class FirestoreService {
  CollectionReference get _userNotesCollection {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('[FirestoreService] ERROR: No user is currently signed in!');
      throw Exception('User not signed in');
    }
    final userId = user.uid;
    print('[FirestoreService] Using notes path: users/$userId/notes');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');
  }

  Future<String> addNote(Note note) async {
    print('[FirestoreService] addNote called for note: ${note.title}');
    try {
      final docRef = await _userNotesCollection.add({
        'title': note.title,
        'content': note.content,
        'createdAt': FieldValue.serverTimestamp(),
        'lastEdited': FieldValue.serverTimestamp(),
      });
      print('[FirestoreService] Note added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('[FirestoreService] ERROR in addNote: $e');
      rethrow;
    }
  }

  Future<void> updateNote(String id, Note note) async {
    print('[FirestoreService] updateNote called for note ID: $id');
    try {
      await _userNotesCollection.doc(id).update({
        'title': note.title,
        'content': note.content,
        'lastEdited': FieldValue.serverTimestamp(),
      });
      print('[FirestoreService] Note updated: $id');
    } catch (e) {
      print('[FirestoreService] ERROR in updateNote: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    print('[FirestoreService] deleteNote called for note ID: $id');
    try {
      await _userNotesCollection.doc(id).delete();
      print('[FirestoreService] Note deleted: $id');
    } catch (e) {
      print('[FirestoreService] ERROR in deleteNote: $e');
      rethrow;
    }
  }

  Stream<List<Note>> getNotes() {
    print('[FirestoreService] getNotes stream started');
    return _userNotesCollection
        .orderBy('lastEdited', descending: true)
        .snapshots()
        .map((snapshot) {
      print('[FirestoreService] getNotes snapshot: ${snapshot.docs.length} notes found');
      return snapshot.docs
          .map((doc) => Note.fromDoc(doc))
          .toList();
    });
  }
}
