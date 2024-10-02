import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddUserTocken extends StatefulWidget {
  final String username;
  final String courseName;
  final String email;

  const AddUserTocken({
    Key? key,
    required this.username,
    required this.courseName,
    required this.email,
  }) : super(key: key);

  @override
  State<AddUserTocken> createState() => _AddUserTockenState();
}

class _AddUserTockenState extends State<AddUserTocken> {
  TextEditingController ticketController = TextEditingController();

  @override
  void dispose() {
    ticketController.dispose();
    super.dispose();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

// Import for date formatting

  // Import for date and time formatting

  Future<void> postTicket(String ticketText) async {
    if (user != null && ticketText.isNotEmpty) {
      try {
        final String email = user!.email!;

        // Format the current time as 'dd/MM/yyyy hh:mm a'
        final String formattedTimestamp =
            DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

        // Reference to the tickets collection of the specific course
        CollectionReference ticketsCollection = _firestore
            .collection('Content')
            .doc('Content')
            .collection('Courses')
            .doc(widget.courseName)
            .collection('Tickets');

        // Update the document identified by email and add a new ticket in a Map
        await ticketsCollection.doc(email).set(
          {
            'email': widget.email,
            'tickets': FieldValue.arrayUnion([
              {
                'ticketText': ticketText,
                'timestamp':
                    formattedTimestamp, // Store formatted date and time
                'userName': widget.username,
              }
            ]),
          },
          SetOptions(merge: true),
        );

        // Clear the text field after submission
        ticketController.clear();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket posted successfully!')),
        );
      } catch (e) {
        print('Error posting ticket: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error posting ticket.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raise Token on ' + widget.courseName),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orangeAccent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: ticketController,
              decoration: const InputDecoration(
                hintText: 'Raise a token',
                border: InputBorder.none,
              ),
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Call postTicket function to save the ticket to Firestore
              postTicket(ticketController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, // Set the button color
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Submit Ticket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
