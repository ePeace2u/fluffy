import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  //get
  final CollectionReference userNotes = FirebaseFirestore.instance.collection('userNotes');
  //create

  Future<void> addNote(String note, String? userEmail) {
    FirebaseFirestore.instance.collection('userNotes').doc(userEmail);
    return userNotes.add({
      'note': note,
      'timestamp': Timestamp.now()
    });
  }
  //read
  Stream<QuerySnapshot> getNotesStream(){
    final notesStream = userNotes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  //update
  Future<void> updateNote(String docID, String newNote){
    return userNotes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now()
    });
  }

  //delete
  Future<void> deleteNote(String docID){
    return userNotes.doc(docID).delete();
  }

}