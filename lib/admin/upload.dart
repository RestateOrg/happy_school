import 'package:flutter/material.dart';
import 'package:happy_school/admin/uploadcourse.dart';
import 'package:happy_school/admin/uploadworkshop.dart';

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text('Upload Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Course Card
            GestureDetector(
              onTap: () {
                // Action when "Upload Course" card is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadCourse()),
                );
              },
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 60, color: Colors.blue),
                      SizedBox(height: 10),
                      Text(
                        'Upload Course',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Upload Workshop Card
            GestureDetector(
              onTap: () {
                // Action when "Upload Workshop" card is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadWorkshop()),
                );
              },
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.work, size: 60, color: Colors.green),
                      SizedBox(height: 10),
                      Text(
                        'Upload Challenge',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
