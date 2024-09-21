import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCourse {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to save combined course data to the user's course collection
  Future<void> saveCourseToUserCollection(String courseName) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Reference to the user's course sub-collection in Firestore
        DocumentReference courseDocRef = _firestore
            .collection('Users')
            .doc(user.email) // Use the user's email as the document ID
            .collection('course')
            .doc(courseName); // Use courseName as the document ID

        DocumentReference courseNamesDocRef = _firestore
            .collection('Users')
            .doc(user.email)
            .collection('courseNames')
            .doc();

        await courseNamesDocRef.set({
          'courseName': courseName,
        });

        print('Course and course name saved successfully!');
      } else {
        print('No user is signed in.');
      }
    } catch (e) {
      print('Failed to save course: $e');
    }
  }
}
