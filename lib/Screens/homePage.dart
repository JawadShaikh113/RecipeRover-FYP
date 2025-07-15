import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Function to build posts from Firestore
  Widget buildPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No posts available.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var postData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return PostWidget(postData: postData);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: buildPosts(),
      ),
    );
  }
}

// Post Widget to display each post
class PostWidget extends StatelessWidget {
  final Map<String, dynamic> postData;

  const PostWidget({required this.postData, Key? key}) : super(key: key);

  // Function to get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userDoc.data(); // Returns user's data map
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Function to toggle like
  Future<void> toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final postId =
        postData['id']; // Assuming 'id' is the document ID of the post

    // Check if the user has already liked the post
    if (postData['likes'].contains(userId)) {
      // User has liked the post, remove the like
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      // User has not liked the post, add the like
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // Fetch names of users who liked the post
  Future<List<String>> fetchLikersNames(List<String> likersIds) async {
    List<String> likersNames = [];

    for (String uid in likersIds) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        likersNames.add(userData?['name'] ?? 'User');
      }
    }
    return likersNames;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      // Fetch user data
      future: getUserData(postData['uid']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text("Error loading user data"),
          );
        }

        final userData = snapshot.data;
        final String userName = userData?['name'] ?? 'User';
        final String profilePicUrl = userData?['profilePicUrl'] ?? '';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Header
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: profilePicUrl.isNotEmpty
                          ? NetworkImage(profilePicUrl)
                          : null,
                      backgroundColor: Colors.deepPurple,
                      child: profilePicUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          postData['timestamp'] != null
                              ? (postData['timestamp'] as Timestamp)
                                  .toDate()
                                  .toString()
                              : 'Just now',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),

              // Post Caption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  postData['caption'] ?? '',
                  style: TextStyle(fontSize: 15),
                ),
              ),

              // Post Image
              if (postData['mediaUrl'] != null && postData['mediaUrl'] != '')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      postData['mediaUrl'],
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        height: 200,
                        child: Center(child: Text('Image failed to load')),
                      ),
                    ),
                  ),
                ),

              // Post Actions
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        postData['likes'].contains(
                                FirebaseAuth.instance.currentUser!.uid)
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: postData['likes'].contains(
                                FirebaseAuth.instance.currentUser!.uid)
                            ? Colors.blue
                            : Colors.grey[700],
                      ),
                      onPressed: () async {
                        await toggleLike();
                      },
                    ),
                    SizedBox(width: 5),
                    FutureBuilder<List<String>>(
                      future: fetchLikersNames(
                          List<String>.from(postData['likes'])),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('0 likes');
                        }
                        if (snapshot.hasError) {
                          return Text('Error loading likes');
                        }
                        final likersNames = snapshot.data ?? [];
                        return Text(
                            '${likersNames.length} likes: ${likersNames.join(', ')}');
                      },
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.comment_outlined),
                      color: Colors.grey[700],
                      onPressed: () {},
                    ),
                    SizedBox(width: 5),
                    Text("Comment", style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }
}
