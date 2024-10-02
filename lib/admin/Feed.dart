import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happy_school/admin/Uploadpost.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  String _selectedTag = 'All';
  TextEditingController _commentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    // Get current user
  }

  String _calculateTimeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} years ago";
    } else if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} months ago";
    } else if (diff.inDays > 0 && diff.inDays < 10) {
      return "${diff.inDays} day ago";
    } else if (diff.inDays > 10) {
      return "${diff.inDays} days ago";
    } else if (diff.inHours > 1) {
      return "${diff.inHours} hours ago";
    } else if (diff.inHours == 1) {
      return "${diff.inHours} hour ago";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes} minutes ago";
    } else {
      return "Just now";
    }
  }

  String _calculateTimeAgocomments(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} y";
    } else if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} m";
    } else if (diff.inDays > 0 && diff.inDays < 10) {
      return "${diff.inDays} d";
    } else if (diff.inDays > 10) {
      return "${diff.inDays} d";
    } else if (diff.inHours > 1) {
      return "${diff.inHours} h";
    } else if (diff.inHours == 1) {
      return "${diff.inHours} h";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes} m";
    } else {
      return "Just now";
    }
  }

  Future<void> _toggleLike(String postId, List<dynamic> likedBy) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You need to be signed in to like posts."),
        ),
      );
      return;
    }

    try {
      if (likedBy.contains(_currentUser!.uid)) {
        await _firestore.collection('Posts').doc(postId).update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([_currentUser!.uid]),
        });
      } else {
        await _firestore.collection('Posts').doc(postId).update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([_currentUser!.uid]),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _addComment(String postId) async {
    if (_commentController.text.isEmpty) return;

    try {
      var comment = {
        'text': _commentController.text,
        'user': _currentUser?.email == "happyschoolculture@gmail.com"
            ? "Happy School"
            : _currentUser?.displayName ?? 'Anonymous',
        'time': DateTime.now(),
        'replies': [],
      };

      await _firestore.collection('Posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([comment]),
      });

      _commentController
          .clear(); // Clear the input field after adding the comment
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<void> _addReply(
      String postId, int commentIndex, String replyText) async {
    if (_currentUser == null) return;

    var reply = {
      'text': replyText,
      'user': _currentUser?.email == "happyschoolculture@gmail.com"
          ? "Happy School"
          : DateTime.now(),
    };

    try {
      DocumentSnapshot postSnapshot =
          await _firestore.collection('Posts').doc(postId).get();
      List comments = postSnapshot['comments'];

      // Add reply to the correct comment's replies array
      comments[commentIndex]['replies'].add(reply);

      // Update the post document in Firestore
      await _firestore.collection('Posts').doc(postId).update({
        'comments': comments,
      });
    } catch (e) {
      print('Error adding reply: $e');
    }
  }

  void _showReplyInput(BuildContext context, String postId, int commentIndex) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true, // Allow the sheet to take full height
      builder: (BuildContext context) {
        TextEditingController _replyController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom +
                16.0, // Add space for keyboard
            left: 16.0,
            right: 16.0,
            top: 10.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Reply to comment",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      decoration: InputDecoration(
                        hintText: 'Add a reply...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_replyController.text.isNotEmpty) {
                        // Check if the reply is not empty
                        _addReply(postId, commentIndex, _replyController.text);
                        Navigator.pop(
                            context); // Close the modal after sending reply
                      } else {
                        // Optionally show a message if the reply is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Reply cannot be empty')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showComments(BuildContext context, String postId) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Comments",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream:
                      _firestore.collection('Posts').doc(postId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var post = snapshot.data!;
                    var comments = post['comments'] ?? [];

                    // Ensure the comments list is initialized
                    if (comments.isEmpty) {
                      return const Center(child: Text('No comments yet.'));
                    }

                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        var comment = comments[index];
                        var commentText = comment['text'] ?? '';
                        var commentUser = comment['user'] ?? 'Anonymous';
                        var commentTime = comment['time']?.toDate();
                        var replies = comment['replies'] ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Comment Section
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              padding: const EdgeInsets.only(
                                  bottom: 0, left: 10, right: 10, top: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        child: Icon(Icons.person,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              commentUser,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                            ),
                                            if (commentTime != null)
                                              Text(
                                                _calculateTimeAgo(commentTime),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    commentText,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                  // Reply button
                                  TextButton(
                                    onPressed: () {
                                      _showReplyInput(context, postId, index);
                                    },
                                    child: const Text(
                                      'Reply',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Replies Section
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 40, bottom: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Show replies if available
                                  if (replies.isNotEmpty)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: replies.length,
                                      itemBuilder: (context, replyIndex) {
                                        var reply = replies[replyIndex];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.grey,
                                                child: Icon(Icons.person,
                                                    color: Colors.white,
                                                    size: 12),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      reply['user'] ??
                                                          'Anonymous',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      reply['text'] ?? '',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 18,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        _addComment(postId);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Filter buttons for Announcement, Update, and Achievement
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTag = 'Announcement';
                  });
                },
                child: const Text('Announcement'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTag = 'Update';
                  });
                },
                child: const Text('Update'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTag = 'Achievement';
                  });
                },
                child: const Text('Achievement'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Stream of posts
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Posts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var posts = snapshot.data!.docs;

                // Filter posts based on the selected tag
                if (_selectedTag != 'All') {
                  posts = posts.where((post) {
                    final tag = post['tag'] ?? 'None';
                    return tag == _selectedTag;
                  }).toList();
                }

                if (posts.isEmpty) {
                  return const Center(child: Text('No posts available.'));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final postId = posts[index].id;
                    final title = post['title'] ?? 'No Title';
                    final content = post['description'] ?? 'No Content';
                    final imageUrl = post['imageUrl'];
                    final timestamp = post['createdAt'];
                    final user = post['user'];
                    final likes = post['likes'] ?? 0;
                    final likedBy = post['likedBy'] ?? [];
                    final comments = post['comments'];
                    final designation = post['designation'];
                    final tag = post['tag'] ??
                        'None'; // Add this line to show the post's tag

                    bool isLiked = likedBy.contains(_currentUser?.uid);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    user ?? 'Anonymous',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '(${designation ?? "No Designation"})',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              subtitle: timestamp != null
                                  ? Text(_calculateTimeAgo(
                                      (timestamp as Timestamp).toDate()))
                                  : const Text("Unknown"),
                            ),
                            const SizedBox(height: 10),
                            if (imageUrl != null)
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            const SizedBox(height: 10),
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 5),
                            ExpandableText(content: content, maxChars: 35),
                            const Divider(color: Colors.grey),
                            Text('Tag: $tag'), // Display the post's tag
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            isLiked ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () {
                                        _toggleLike(postId, likedBy);
                                      },
                                    ),
                                    Text('$likes'),
                                    GestureDetector(
                                      onTap: () {
                                        _showComments(context, postId);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.comment,
                                                color: Colors.grey),
                                            const SizedBox(width: 5),
                                            Text(comments.length.toString()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                      FontAwesomeIcons.ellipsisVertical,
                                      color: Colors.grey),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
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

class ExpandableText extends StatefulWidget {
  final String content;
  final int maxChars;

  const ExpandableText({required this.content, this.maxChars = 35});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final shouldShowMore = widget.content.length > widget.maxChars;
    final displayedText = _isExpanded || !shouldShowMore
        ? widget.content
        : '${widget.content.substring(0, widget.maxChars)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayedText),
        if (shouldShowMore)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show less' : 'Show more',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
