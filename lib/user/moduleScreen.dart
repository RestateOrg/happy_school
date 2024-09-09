import 'package:flutter/material.dart';
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

  // Function to show a list of available files and open the selected file
  void _showFileSelectionDialog(
      BuildContext context, List<String> fileKeys, bool isPdf) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isPdf ? 'Select PDF' : 'Select PPT'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: fileKeys.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(fileKeys[index]),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // Open the selected file based on its type
                    isPdf
                        ? _openPDFPage(context, widget.module[fileKeys[index]])
                        : _openPPTPage(context, widget.module[fileKeys[index]]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Log the received module data for debugging
    print('Received module data: ${widget.module}');

    // Extract keys for PDFs and PPTs
    List<String> pdfKeys = widget.module.keys
        .where((key) => key.toLowerCase().contains('pdf'))
        .toList();
    List<String> pptKeys = widget.module.keys
        .where((key) => key.toLowerCase().contains('ppt'))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.module['moduleName'] ?? 'Module Details'),
      ),
      body: Column(
        children: [
          // Display the YouTube player if the video ID is valid
          if (widget.vid.isNotEmpty)
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Invalid or missing video URL.',
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          // Button to show available PDFs
          if (pdfKeys.isNotEmpty)
            ElevatedButton(
              onPressed: () => _showFileSelectionDialog(context, pdfKeys, true),
              child: Text('Open PDF'),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No PDFs available.',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
            ),

          // Button to show available PPTs
          if (pptKeys.isNotEmpty)
            ElevatedButton(
              onPressed: () =>
                  _showFileSelectionDialog(context, pptKeys, false),
              child: Text('Open PPT'),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No PPTs available.',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
            ),
        ],
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
      ),
      body: SfPdfViewer.network(
          pdfUrl), // Display the PDF using Syncfusion PDF viewer
    );
  }
}

// PPT viewing screen
class PPTScreen extends StatelessWidget {
  final String pptUrl; // URL of the PPT document

  const PPTScreen({Key? key, required this.pptUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PPT Viewer'),
      ),
      body: Container(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri.uri(
                Uri.parse(pptUrl)), // Ensure the URL is correctly parsed
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
      ),
    );
  }
}
