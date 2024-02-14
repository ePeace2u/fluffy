import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {

  //create
  createCollection(String userEmail){

    final CollectionReference userNotes = FirebaseFirestore.instance.collection(userEmail);
    return userNotes;
  }

  Future<void> addNote(CollectionReference userNotes,String note) {
    return userNotes.doc().set({
      'note': note,
      'timestamp': Timestamp.now()
    });
  }
  //read
  Stream<QuerySnapshot> getNotesStream(CollectionReference userNotes){
    final notesStream = userNotes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  //update

  Future<void> updateNote(CollectionReference userNotes,String docID, String newNote){
    return userNotes.doc(docID).update({
      'note': newNote
    });
  }

  //delete
  Future<void> deleteNote(CollectionReference userNotes,String docID){
    return userNotes.doc(docID).delete();
  }

}