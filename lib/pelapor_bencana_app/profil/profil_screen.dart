import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pelaporan_bencana/pelapor_bencana_app/profil/edit_profile_screen.dart';
import 'package:pelaporan_bencana/pelapor_bencana_app/profil/report_history_screen.dart';
import 'package:pelaporan_bencana/model/report_status.dart' as pelaporan_bencana_model;
import 'dart:io';
import 'package:pelaporan_bencana/pelapor_bencana_app/ui_view/foto_pengurus_view.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late String _firstName = '';
  late String _lastName = '';
  late String _email = '';
  late String _userId = '';
  late List<pelaporan_bencana_model.Report> _userReports = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _membersCollection = FirebaseFirestore.instance.collection('members');

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        _email = user.email ?? '';

        // Fetch user document by email
        QuerySnapshot querySnapshot = await _membersCollection.where('email', isEqualTo: _email.trim()).get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          if (documentSnapshot.exists) {
            setState(() {
              _firstName = documentSnapshot.get('firstName') ?? '';
              _lastName = documentSnapshot.get('lastName') ?? '';
              _email = documentSnapshot.get('email') ?? '';
              _userId = documentSnapshot.id;
            });
            print('User data: ${documentSnapshot.data()}');
            _getUserReports(); // Fetch user reports after getting user data
          } else {
            print('Document does not exist for email: $_email');
          }
        } else {
          print('No document found for email: $_email');
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _getUserReports() async {
    try {
      List<pelaporan_bencana_model.Report> reports = await pelaporan_bencana_model.Report.fetchReports(_userId);
      setState(() {
        _userReports = reports;
      });
    } catch (e) {
      print('Error fetching user reports: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pop(context);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _refreshData() async {
    await _getUserData();
    await _getUserReports();
  }

  void _updateProfilePicture(File image) {
    // Placeholder function to handle profile picture update
    print("Profile picture updated: $image");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.person, size: 120), // Placeholder icon
                ),
                SizedBox(height: 16),
                Text(
                  '$_firstName $_lastName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Historis Pelaporan'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportHistoryScreen(
                          userId: _userId,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.support),
                  title: Text('Tentang Kami'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AreaListView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          updateProfilePicture: _updateProfilePicture,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 32),
                TextButton(
                  onPressed: _signOut,
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Log Out', style: TextStyle(color: Colors.red)),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TrainingScreen(),
  ));
}
