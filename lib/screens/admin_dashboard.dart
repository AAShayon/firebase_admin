import 'package:firebase_admin/screens/widgets/product_form.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_services.dart';


class AdminDashboard extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
              onPressed: () async {
                await _firebaseService.auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firebaseService.getProductsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          List<Product> products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              Product p = products[index];
              return ListTile(
                title: Text(p.title),
                subtitle: Text("${p.price} | ${p.quantity} left"),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductForm()),
          );
        },
      ),
    );
  }
}