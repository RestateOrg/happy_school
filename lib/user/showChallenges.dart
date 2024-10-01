import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Showchallenges extends StatefulWidget {
  final List<Map<String, dynamic>> challengeInfo;
  final List<Map<String, dynamic>> tasks;

  Showchallenges({
    required this.challengeInfo,
    required this.tasks,
  });

  @override
  State<Showchallenges> createState() => _ShowchallengesState();
}

class _ShowchallengesState extends State<Showchallenges> {
  bool isExpanded = false;
  bool isMExpanded = false;

  Widget _buildTasks(int index, Map<String, dynamic> task) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {},
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
                    child: Text(
                      "Task " + (index + 1).toString() + ":",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Text(
                      task['taskName'] ?? '',
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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    String courseDis = widget.challengeInfo[0]['ChallengeDescription'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challengeInfo[0]['ChallengeName']),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              width: width,
              height: width * 0.7,
              child: CachedNetworkImage(
                imageUrl: widget.challengeInfo[0]['ChallengeImage'],
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                key: UniqueKey(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              ),
            ),

            // Description title
            const Padding(
              padding: EdgeInsets.only(top: 10, left: 10),
              child: Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Description text
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: RichText(
                text: TextSpan(
                  text: isExpanded
                      ? courseDis
                      : courseDis.length > 500
                          ? courseDis.substring(0, 500) + ' '
                          : courseDis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                  children: courseDis.length > 500
                      ? [
                          TextSpan(
                            text: isExpanded ? ' less' : 'more...',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                          ),
                        ]
                      : [],
                ),
                textAlign: TextAlign.justify,
                softWrap: true,
              ),
            ),

            // Tasks list

            const Padding(
              padding: EdgeInsets.only(top: 10, left: 10),
              child: Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: isMExpanded
                        ? widget.tasks.length
                        : 1, // Show only two tasks initially
                    itemBuilder: (context, index) {
                      return _buildTasks(index, widget.tasks[index]);
                    },
                  ),

                  // Show more/less tasks button
                  if (widget.tasks.length > 1)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMExpanded = !isMExpanded; // Toggle expansion
                          });
                        },
                        child: Container(
                          width: width * 0.94,
                          height: width * 0.15,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(15), // Rounded corners
                            border: Border.all(
                                color: Colors.black, width: 1), // Black border
                          ),
                          child: Center(
                            child: Text(
                              isMExpanded
                                  ? 'Show less Tasks'
                                  : 'Show more Tasks',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
