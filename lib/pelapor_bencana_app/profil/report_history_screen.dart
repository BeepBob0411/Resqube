import 'package:flutter/material.dart';
import 'package:pelaporan_bencana/model/report_status.dart';

class ReportHistoryScreen extends StatelessWidget {
  final String userId;

  ReportHistoryScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historis Pelaporan'),
      ),
      body: FutureBuilder<List<Report>>(
        future: Report.fetchReports(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching reports'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada laporan yang dikirim.'));
          } else {
            final userReports = snapshot.data!;
            return ListView.builder(
              itemCount: userReports.length,
              itemBuilder: (context, index) {
                final report = userReports[index];
                return ListTile(
                  leading: report.getStatusIcon(),
                  title: Text(report.disasterType),
                  subtitle: Text(report.getFormattedTimestamp()),
                  onTap: () {
                    // Implement navigation to detailed report view if needed
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
