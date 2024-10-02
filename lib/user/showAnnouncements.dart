import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Assuming you'll use this for UI

class Showannouncements extends StatefulWidget {
  final Map<String, dynamic> announcementData; // Add this to accept data

  // Modify constructor to take in the announcementData
  const Showannouncements({super.key, required this.announcementData});

  @override
  State<Showannouncements> createState() => _ShowannouncementsState();
}

class _ShowannouncementsState extends State<Showannouncements> {
  @override
  Widget build(BuildContext context) {
    // Access announcementData through widget.announcementData
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.announcementData['title'] ?? 'Announcement'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              height: width * 0.5,
              color: Colors.black12,
              child: widget.announcementData['imageUrl'].isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.announcementData['imageUrl'],
                      placeholder: (context, url) => Center(),
                      key: UniqueKey(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    )
                  : Center(child: Text(widget.announcementData['title'])),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discription',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.announcementData['description'] ?? 'No Description',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Add more widgets to display other parts of the announcement data
          ],
        ),
      ),
    );
  }
}
