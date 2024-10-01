import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Main Module Screen class
class Modulescreen extends StatefulWidget {
  final Map<String, dynamic> module; // Module data passed from CoursesScreen
  final String vid; // Video ID for YouTube

  const Modulescreen({Key? key, required this.module, required this.vid})
      : super(key: key);

  @override
  State<Modulescreen> createState() => _ModulescreenState();
}

class _ModulescreenState extends State<Modulescreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize YouTube player controller with the provided video ID
    _controller = YoutubePlayerController(
      initialVideoId: widget.vid,
      flags: const YoutubePlayerFlags(
        autoPlay: false, // Video does not autoplay
      ),
    );

    // Log the video ID to help debug issues with video loading
    print('Received video ID: ${widget.vid}');
  }

  @override
  void dispose() {
    // Dispose of the YouTube player controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  // Function to open a PDF in a new screen
  void _openPDFPage(BuildContext context, String pdfUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFScreen(pdfUrl: pdfUrl),
      ),
    );
  }

  // Function to open a PPT in a new screen
  void _openPPTPage(BuildContext context, String pptUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PPTScreen(pptUrl: pptUrl),
      ),
    );
  }

  // Function to open a video
  void _openVideoPage(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YoutubeVideoScreen(vid: videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Log the received module data for debugging
    print('Received module data: ${widget.module}');

    // Extract the 'fields' array from the module map
    List<dynamic> fields = widget.module['fields'] ?? [];
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.module['moduleName'] ?? 'Module Details'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) {
          // Extract the fieldName and url for each field in the fields array
          String fieldName = fields[index]['fieldName'] ?? 'Unknown Field';
          String url = fields[index]['url'] ?? '';
          String? id = YoutubePlayer.convertUrlToId(url);

          return GestureDetector(
            onTap: () {
              if (fieldName.toLowerCase().contains('pdf')) {
                _openPDFPage(context, url);
              } else if (fieldName.toLowerCase().contains('ppt')) {
                _openPPTPage(context, url);
              } else if (fieldName.toLowerCase().contains('video')) {
                _openVideoPage(context, id!); // Extract video ID from URL
              }
              // You can add more types of resources as needed (e.g., image)
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Container(
                width: width * 0.95,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(9, 0, 0, 0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(9, 0, 0, 0),
                    width: 0.25,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: FaIcon(
                            (fieldName.toLowerCase().contains('pdf'))
                                ? FontAwesomeIcons.filePdf
                                : (fieldName.toLowerCase().contains('ppt'))
                                    ? FontAwesomeIcons.filePowerpoint
                                    : (fieldName
                                            .toLowerCase()
                                            .contains('video'))
                                        ? FontAwesomeIcons.video
                                        : FontAwesomeIcons.image,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Text(
                            fieldName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// PDF viewing screen
class PDFScreen extends StatelessWidget {
  final String pdfUrl; // URL of the PDF document

  const PDFScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: Colors.orange,
      ),
      body: SfPdfViewer.network(
          pdfUrl), // Display the PDF using Syncfusion PDF viewer
    );
  }
}

// PPT viewing screen
// PPT viewing screen using Google Docs Viewer or Office 365 Viewer
class PPTScreen extends StatelessWidget {
  final String pptUrl; // URL of the PPT document

  const PPTScreen({Key? key, required this.pptUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using Google Docs or Office 365 viewer to open PPT URLs
    String fileViewerUrl =
        'https://docs.google.com/gview?embedded=true&url=$pptUrl';

    return Scaffold(
      appBar: AppBar(
        title: const Text('PPT Viewer'),
        backgroundColor: Colors.orange,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri.uri(
              Uri.parse(fileViewerUrl)), // Open the file via Google Docs viewer
        ),
        onLoadStart: (controller, url) {
          // Show a loading message when the PPT starts loading
          print('PPT is loading: $url');
        },
        onLoadStop: (controller, url) {
          // Log when the PPT has finished loading
          print('PPT loaded: $url');
        },
        onLoadError: (controller, url, code, message) {
          // Handle errors during PPT loading
          print('Error loading PPT: $message');
        },
      ),
    );
  }
}

// Video viewing screen (YouTube)
class YoutubeVideoScreen extends StatelessWidget {
  final String vid; // YouTube video ID

  const YoutubeVideoScreen({Key? key, required this.vid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: vid,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
        backgroundColor: Colors.orange,
      ),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
