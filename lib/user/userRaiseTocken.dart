import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:happy_school/user/addUserTocken.dart';

class UserRaiseTocken extends StatefulWidget {
  final String username;
  final String courseName;
  final String email;

  const UserRaiseTocken({
    Key? key,
    required this.username,
    required this.courseName,
    required this.email,
  }) : super(key: key);

  @override
  State<UserRaiseTocken> createState() => _UserRaiseTockenState();
}

class _UserRaiseTockenState extends State<UserRaiseTocken> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future to fetch tickets for the user
  Future<List<Map<String, dynamic>>> fetchUserTickets() async {
    try {
      // Reference to the user's tickets collection
      final userDoc = await _firestore
          .collection('Content')
          .doc('Content')
          .collection('Courses')
          .doc(widget.courseName)
          .collection('Tickets')
          .doc(widget.email)
          .get();

      if (userDoc.exists) {
        // Get the 'tickets' field (array of maps)
        List<dynamic> tickets = userDoc.data()?['tickets'] ?? [];
        return List<Map<String, dynamic>>.from(tickets);
      } else {
        return []; // No tickets found
      }
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Tokens on ${widget.courseName}'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future:
                  fetchUserTickets(), // Fetch the tickets using FutureBuilder
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While the data is loading, show a progress indicator
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Handle error cases
                  return const Center(child: Text('Error loading tickets.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // No tickets found
                  return const Center(child: Text('No tickets found.'));
                } else {
                  // Tickets are successfully retrieved
                  final tickets = snapshot.data!;

                  return SizedBox(
                    height:
                        MediaQuery.of(context).size.height * 0.6, // Set height
                    child: ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: const Icon(Icons.description),
                            title: Text('Ticket: ${ticket['ticketText']}'),
                            subtitle: Text(
                              'Submitted on: ${ticket['timestamp']}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to the AddUserTocken screen to raise a new ticket
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddUserTocken(
                username: widget.username,
                courseName: widget.courseName,
                email: widget.email,
              ),
            ),
          );
        },
        label: const Text(
          'Raise Tickets',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.question_answer_sharp),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
