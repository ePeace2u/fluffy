

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluffy/models/events.dart';
import 'package:fluffy/services/firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  int count = 0;
  bool _isEnabled = true;
  List<Event> events = [];
  final TextEditingController textController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  void openNoteBox({String? docID}){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ToDo"),
            content: TextField(
              controller: textController,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    if (docID == null) {
                      firestoreService.addNote(textController.text, user?.email.toString());
                    }
                    else {
                      firestoreService.updateNote(docID, textController.text);
                    }
                    textController.clear();

                    Navigator.pop(context);
                  },
                  child: Icon(Icons.check))
            ],
          );
        });
  }

  void logout() {
    final navigator = Navigator.of(context);
    FirebaseAuth.instance.signOut();
    navigator.pushNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    print("home");
    print(user!.uid.toString());
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          actions: [
            IconButton(icon: Icon(Icons.logout),
                onPressed: logout
            ),
          ],
          title: const Text(
            'Fluffy.ToDo',
            style: TextStyle(color: Colors.white, fontFamily: 'Satisfy'),
          ),
          centerTitle: true,
          backgroundColor: Colors.cyan,
        ),
        drawer: Drawer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(color: Colors.cyan,
                  height: 121,
                  width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  textDirection: TextDirection.rtl,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Text(user.email.toString(),style: TextStyle(fontSize: 20)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, top: 25),
                      child: Icon(Icons.person, size: 42,),
                    )
                  ],
                ),),
                Padding(
                  padding: const EdgeInsets.only(top: 15,left: 10),
                  child: Icon(Icons.calendar_month),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15,left: 10),
                  child: Icon(Icons.settings),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15,left: 10),
                  child: Icon(Icons.flag),
                ),

              ],
            ),
          ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index){
                    DocumentSnapshot document = notesList[index];
                    String docID = document.id;

                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    String noteText = data['note'];
                      return Card(
                        color: Colors.cyan[300],
                        elevation: 30,
                        shadowColor: Colors.black,
                        margin: EdgeInsets.symmetric(vertical: 7),
                        child: ListTile(
                          enableFeedback: _isEnabled,
                          title: Text(
                            noteText,
                            style: TextStyle(fontSize: 20),
                          ),
                          leading: IconButton(
                              icon: _isEnabled
                                  ? Icon(Icons.check_box_outline_blank)
                                  : Icon(Icons.check_box),
                              onPressed: () => firestoreService.deleteNote(docID),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => openNoteBox(docID: docID),
                          ),
                        ),
                      );
                  }
              );
          }
            else
              return Container();
          }
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.cyan[300],
            onPressed: () => openNoteBox(),
            child: Icon(Icons.add)),
    );
  }
}
