import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _captionController = TextEditingController();
  String? userName; // Stores user's name

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Fetch user's name from Firestore
  Future<void> _fetchUserName() async {
    final userDoc =
        await firestore.collection('users').doc(_auth.currentUser!.uid).get();
    setState(() {
      userName = userDoc.data()?['name'] ??
          'User'; // Assuming 'name' is the field name
    });
  }

  // Pick image and show post dialog
  Future pickImage(ImageSource source) async {
    final pickedImage =
        await _picker.pickImage(source: source, imageQuality: 100);
    if (pickedImage != null) {
      setState(() {
        _image = XFile(pickedImage.path);
      });
      _showPostDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected")),
      );
    }
  }

  // Show dialog for adding caption
  void _showPostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Post"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _image != null
                ? SizedBox(
                    height: 200, // Constrain height
                    width: double.infinity, // Constrain width
                    child: Image.file(
                      File(_image!.path),
                      fit: BoxFit
                          .cover, // Adjust the image to fit within the box
                    ),
                  )
                : Container(),
            SizedBox(height: 10),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(hintText: "Enter caption..."),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              uploadImageAndPost();
              Navigator.of(context).pop();
            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }

  // Upload image and post to Firestore
  Future<void> uploadImageAndPost() async {
    if (_image == null || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add an image and a caption")),
      );
      return;
    }

    try {
      String fileName = _auth.currentUser!.uid + DateTime.now().toString();
      firebase_storage.Reference storageRef =
          firebase_storage.FirebaseStorage.instance.ref('/posts/$fileName');
      firebase_storage.UploadTask uploadTask =
          storageRef.putFile(File(_image!.path));

      await uploadTask.whenComplete(() => null);
      final postUrl = await storageRef.getDownloadURL();

      await firestore.collection('posts').add({
        'uid': _auth.currentUser!.uid,
        'mediaUrl': postUrl,
        'caption': _captionController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post Uploaded Successfully")),
      );
      _captionController.clear();
      setState(() {
        _image = null; // Clear the selected image
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading post: $error")),
      );
    }
  }

  // Display user's posts
  Widget buildUserPosts() {
    return StreamBuilder(
      stream: firestore
          .collection('posts')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No posts yet."));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var post =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return PostWidget(
              postData: post,
              postId: snapshot.data!.docs[index].id,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(child: Text("Profile")),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              userName ?? 'User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(child: buildUserPosts()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pickImage(ImageSource.gallery),
        child: Icon(Icons.add),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  final Map<String, dynamic> postData;
  final String postId;

  const PostWidget({required this.postData, required this.postId});

  // Toggle like on post
  Future<void> toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (postData['likes'].contains(user!.uid)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([user.uid])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([user.uid])
      });
    }
  }

  // Fetch user data from Firestore
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

  // Fetch names of users who liked the post
  Future<List<String>> fetchLikersNames(List<String> userIds) async {
    List<String> names = [];
    for (String uid in userIds) {
      final userData = await getUserData(uid);
      if (userData != null) {
        names.add(userData['name'] ?? 'Unknown');
      }
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: getUserData(postData['uid']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return ListTile(
                  title: Text('User'),
                  subtitle: Text('Just now'),
                );
              }

              final userData = snapshot.data;
              final String userName = userData?['name'] ?? 'User';
              final String profilePicUrl = userData?['profilePicUrl'] ?? '';

              return ListTile(
                leading: profilePicUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profilePicUrl),
                      )
                    : CircleAvatar(
                        child: Icon(Icons.person, color: Colors.white),
                        backgroundColor: Colors.deepPurple,
                      ),
                title: Text(
                  userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(postData['timestamp'] != null
                    ? (postData['timestamp'] as Timestamp).toDate().toString()
                    : 'Just now'),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              postData['caption'] ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Image.network(
            postData['mediaUrl'],
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => SizedBox(
              height: 200,
              child: Center(child: Text('Error loading image')),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  postData['likes']
                          .contains(FirebaseAuth.instance.currentUser!.uid)
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  color: postData['likes']
                          .contains(FirebaseAuth.instance.currentUser!.uid)
                      ? Colors.blue
                      : Colors.grey[700],
                ),
                onPressed: () async {
                  await toggleLike();
                },
              ),
              SizedBox(width: 5),
              FutureBuilder<List<String>>(
                future: fetchLikersNames(List<String>.from(postData['likes'])),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                onPressed: () {
                  // Add functionality for commenting
                },
              ),
              SizedBox(width: 5),
              Text("Comment", style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }
}
