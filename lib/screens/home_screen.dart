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
  dynamic collection = CollectionReference;
  bool enabled = false;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // TODO: implement initState

    collection = firestoreService.createCollection(user!.email.toString());
  }

  @override
  void dispose() {
    textController.dispose();

    super.dispose();
  }

  // DocumentReference documentReference = FirebaseFirestore.instance.collection(user!.email.toString()).doc(note);
  //
  //
  // createData(String note){
  //   Map<String, dynamic> notesdata= {
  //     'note': note,
  //     'timestamp': Timestamp.now()
  //   };
  //   documentReference.set(notesdata).whenComplete((){
  //     print('complete');
  //   });
  // }
  //
  // getNotes(){
  //   documentReference.get().then((snapshot){
  //     print('complete');
  //   });
  // }

  check(docID) {
    if (docID == null) {
      firestoreService.addNote(collection, textController.text);
    } else {
      firestoreService.updateNote(collection, docID, textController.text);
    }
    textController.clear();
    Navigator.pop(context);
  }

  _setDisabled(text) {
    if (text.isNotEmpty) {
      setState(() {
        enabled = true;
      });
    } else {
      setState(() {
        enabled = false;
      });
    }
  }

  void openNoteBox({String? docID, String? textId}) {
    // textController.addListener(() {
    //   setState(() {
    //     enabled = textController.text.isNotEmpty;
    //   });
    // });
    if (textId != null) {
      enabled = true;
      textController.text = textId;
    } else {
      enabled = false;
      textController.text = '';
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ToDo"),
            backgroundColor: Colors.white,
            content: TextFormField(
              autofocus: true,
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  value != null && value.length < 1 ? 'Введите ToDo' : null,
              controller: textController,
              onChanged: (text) {
                print("$text");
                _setDisabled(text);
                print(enabled);
              },
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    print(enabled);
                    if (enabled == true) {
                      check(docID);
                    } else {
                      null;
                    }
                  },
                  child: Icon(Icons.check))
              //     onPressed: () {
              //       if (docID == null) {
              //         firestoreService.addNote(textController.text, user?.email.toString());
              //       }
              //       else {
              //         firestoreService.updateNote(docID, textController.text);
              //       }
              //       textController.clear();
              //
              //       Navigator.pop(context);
              //     },
              //     child: Icon(Icons.check))
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
          IconButton(icon: Icon(Icons.logout), onPressed: logout),
        ],
        title: const Text(
          'Fluffy.ToDo',
          style: TextStyle(
              color: Colors.white, fontFamily: 'Satisfy', fontSize: 28),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.cyan,
                height: 121,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  textDirection: TextDirection.rtl,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Text(user.email.toString(),
                          style: TextStyle(fontSize: 20)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, top: 25),
                      child: Icon(
                        Icons.person,
                        size: 42,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 10),
                child: Icon(Icons.calendar_month),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 10),
                child: Icon(Icons.settings),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 10),
                child: Icon(Icons.flag),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getNotesStream(collection),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List notesList = snapshot.data!.docs;
                return ListView.builder(
                    itemCount: notesList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = notesList[index];
                      String docID = document.id;

                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String noteText = data['note'];
                      return Card(
                        color: Colors.cyan[300],
                        elevation: 7,
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
                            onPressed: () =>
                                firestoreService.deleteNote(collection, docID),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                                openNoteBox(docID: docID, textId: noteText),
                          ),
                        ),
                      );
                    });
              } else
                return Container(color: Colors.white);
            }),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.cyan[300],
          onPressed: () => openNoteBox(),
          child: Icon(Icons.add)),
    );
  }
}
