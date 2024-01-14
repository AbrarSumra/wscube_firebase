import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wscube_firebase/models/note_model.dart';
import 'package:wscube_firebase/widget_constant/custom_textfield.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FirebaseFirestore firestore;

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Fire base Note App",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: firestore.collection("notes").get(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Note not loaded ${snapshot.hasError}"),
            );
          } else if (snapshot.hasData) {
            var mData = snapshot.data!.docs;
            return ListView.builder(
              itemCount: mData.length,
              itemBuilder: (_, index) {
                NoteModel currNote = NoteModel.fromMap(mData[index].data());
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                  ),
                  child: ListTile(
                    title: Text(
                      currNote.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(currNote.desc),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              bottomSheet(
                                isUpdate: true,
                                title: currNote.title,
                                desc: currNote.desc,
                                docId: mData[index].id,
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              var collRef = firestore.collection("notes");
                              collRef.doc(mData[index].id).delete();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bottomSheet();
        },
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }

  void bottomSheet({
    bool isUpdate = false,
    String title = "",
    String desc = "",
    String docId = "",
  }) {
    titleController.text = title;
    descController.text = desc;
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                NoteTextField(
                  label: "Enter title",
                  controller: titleController,
                ),
                NoteTextField(
                  label: "Enter description",
                  controller: descController,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty &&
                            descController.text.isNotEmpty) {
                          var collRef = firestore.collection("notes");
                          if (isUpdate) {
                            /// For Update Note
                            collRef.doc(docId).update(NoteModel(
                                    title: titleController.text.toString(),
                                    desc: descController.text.toString())
                                .toMap());
                          } else {
                            /// For Add New Note
                            collRef.add(NoteModel(
                                    title: titleController.text.toString(),
                                    desc: descController.text.toString())
                                .toMap());
                          }
                          titleController.clear();
                          descController.clear();
                          setState(() {});
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: Text(
                        isUpdate ? "Update" : "Add",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}