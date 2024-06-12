import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientDetailsPage extends StatefulWidget {
  final String visitId;

  const PatientDetailsPage({required this.visitId, Key? key}) : super(key: key);

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late String _visitId;
  Map<String, dynamic>? patientDetails;
  List<dynamic>? medications;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
    _visitId = widget.visitId;
  }

  Future<void> _fetchPatientDetails() async {
    final url =
        Uri.parse('http://10.143.10.37/ApiPhamacySmartLabel/PatientDetails');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'emplid': widget.visitId, 'pass': ""});

    print('Fetching patient details with body: $body'); // Debug print

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Patient details response: $jsonResponse'); // Debug print

        if (jsonResponse['status'] == '200') {
          setState(() {
            patientDetails =
                (jsonResponse['detailsH'] as List<dynamic>?)?.first;
            medications = jsonResponse['detailsB'] as List<dynamic>?;
          });
        } else {
          _showSnackBar(
              'Failed to load patient details: ${jsonResponse['message']}');
        }
      } else {
        _showSnackBar('Failed to load patient details');
      }
    } catch (e) {
      print('Error fetching patient details: $e'); // Error handling
      _showSnackBar('An error occurred while fetching patient details.');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Details')),
      body: patientDetails != null && medications != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${patientDetails!['patient_name'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Gender: ${patientDetails!['fix_gender_id'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Birthdate: ${patientDetails!['birthdate'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Age: ${patientDetails!['age'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Diagnosis: ${patientDetails!['diagnosis'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Doctor: ${patientDetails!['opddoctorname'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  const Text('Medications',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: medications!.length,
                    itemBuilder: (context, index) {
                      final medication = medications![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${medication['item_name'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 18)),
                              Text(
                                  'Instructions: ${medication['instruction_text_line1'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                  '${medication['instruction_text_line2'] ?? ''}',
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                  '${medication['instruction_text_line3'] ?? ''}',
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                  'Description: ${medication['item_deacription'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                  'Caution: ${medication['item_caution'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
