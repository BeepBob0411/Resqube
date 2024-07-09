import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ReportStatus { sent, inProgress, completed, rejected }

class Report {
  final String id;
  final String userId;
  final String disasterType;
  final String imagePath;
  final double latitude;
  final double longitude;
  final String keterangan;
  final Timestamp timestamp;
  final ReportStatus status;

  Report({
    required this.id,
    required this.userId,
    required this.disasterType,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.keterangan,
    required this.timestamp,
    required this.status,
  });

  factory Report.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Report(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      disasterType: data['disasterType'] ?? '',
      imagePath: data['imageUrl'] ?? '',
      latitude: (data['location'] as GeoPoint).latitude,
      longitude: (data['location'] as GeoPoint).longitude,
      keterangan: data['description'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      status: ReportStatus.values.firstWhere(
            (e) => e.toString() == 'ReportStatus.${data['status'] ?? 'sent'}',
        orElse: () => ReportStatus.sent,
      ),
    );
  }

  Icon getStatusIcon() {
    switch (status) {
      case ReportStatus.sent:
        return Icon(Icons.send, color: Colors.blue);
      case ReportStatus.inProgress:
        return Icon(Icons.hourglass_top, color: Colors.orange);
      case ReportStatus.completed:
        return Icon(Icons.done, color: Colors.green);
      case ReportStatus.rejected:
        return Icon(Icons.close, color: Colors.red);
      default:
        return Icon(Icons.help); // Handle unexpected cases
    }
  }

  String getFormattedTimestamp() {
    final DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  static Future<List<Report>> fetchReports(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('laporan')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => Report.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error fetching user reports: $e');
      return [];
    }
  }
}
