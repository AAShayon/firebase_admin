import 'package:firebase_admin/screens/admin_dashboard.dart';
import 'package:flutter/material.dart';

import '../services/firebase_services.dart';


class LoginScreen extends StatelessWidget {
  final FirebaseService _service = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.login),
          label: Text("Login with Google"),
          onPressed: () async {
            var user = await _service.signInWithGoogle();
            if (user != null) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AdminDashboard()),  (route) => false,);
            }
          },
        ),
      ),
    );
  }
}