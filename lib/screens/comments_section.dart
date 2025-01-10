import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentsSection extends StatefulWidget {
  final String documentId;

  const CommentsSection({Key? key, required this.documentId}) : super(key: key);

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        /// ----- Λίστα Σχολίων -----
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('feeding_spawts')
              .doc(widget.documentId)
              .collection('comments')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No comments yet.');
            }

            final commentDocs = snapshot.data!.docs;

            return ListView.builder(
              // Για να χωρέσει μέσα στο SingleChildScrollView του parent
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commentDocs.length,
              itemBuilder: (context, index) {
                final commentData =
                    commentDocs[index].data() as Map<String, dynamic>;

                final username = commentData['username'] ?? 'Anonymous';
                final text = commentData['comment'] ?? '';

                return ListTile(
                  title: Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(text),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),

        /// ----- Πεδίο για Νέο Σχόλιο -----
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.pink),
              onPressed: () async {
                final commentText = commentController.text.trim();

                if (commentText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comment cannot be empty.'),
                    ),
                  );
                  return;
                }

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  // Ο χρήστης δεν είναι συνδεδεμένος
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You need to be signed in to comment.'),
                    ),
                  );
                  return;
                }

                final username = user.displayName ?? 'Anonymous';

                try {
                  await FirebaseFirestore.instance
                      .collection('feeding_spawts')
                      .doc(widget.documentId)
                      .collection('comments')
                      .add({
                    'uid': user.uid,
                    'username': username,
                    'comment': commentText,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  // Αδειάζουμε το TextField
                  commentController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send comment: $e'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
