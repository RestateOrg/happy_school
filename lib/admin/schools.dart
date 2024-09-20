import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy_school/admin/SchoolInfo.dart';

class Schools extends StatefulWidget {
  const Schools({super.key});

  @override
  State<Schools> createState() => _SchoolsState();
}

class _SchoolsState extends State<Schools> {
  // Reference to the Firebase Firestore collection "schools"
  final CollectionReference schoolsRef =
      FirebaseFirestore.instance.collection('Schools');
  TextEditingController schoolNameController = TextEditingController();
  TextEditingController noOfUsersController = TextEditingController();
  Future<void> addschool() {
    schoolsRef.add({
      'SchoolName': schoolNameController.text,
      'No.ofUsers': int.tryParse(noOfUsersController.text) ?? 0,
      'UsersCount': int.tryParse(noOfUsersController.text) ?? 0,
    });
    schoolNameController.clear();
    noOfUsersController.clear();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Row with Add School button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('Add School'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  TextField(
                                    controller: schoolNameController,
                                    decoration: InputDecoration(
                                      labelText: 'School Name',
                                      hintText: 'Enter the school name',
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: noOfUsersController,
                                    decoration: InputDecoration(
                                      labelText: 'No. of Users',
                                      hintText: 'Enter No.of Users',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.black)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Add',
                                    style: TextStyle(color: Colors.orange)),
                                onPressed: () {
                                  addschool();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text("Add School",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ))
            ],
          ),

          // Expanded widget to display the list of schools
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: schoolsRef.snapshots(), // Fetch schools in real-time
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                // Show a loading spinner if the data is still loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Check if there is any data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No schools available"));
                }

                // List of schools fetched from Firestore
                final List<DocumentSnapshot> schoolDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: schoolDocs.length,
                  itemBuilder: (context, index) {
                    var schoolData =
                        schoolDocs[index].data() as Map<String, dynamic>;
                    String schoolName = schoolData['SchoolName'] ??
                        'Unnamed School'; // Replace with the correct field name

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SchoolInfo(name: schoolName)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.grey, width: 0.25),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ]),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, right: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        schoolName,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        // Delete the school from Firestore
                                        await schoolsRef
                                            .doc(schoolDocs[index].id)
                                            .delete();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'No. of Users: ${schoolData['No.ofUsers']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
