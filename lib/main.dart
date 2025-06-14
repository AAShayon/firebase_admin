import 'package:firebase_admin/app/features/initialization/app_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/core/di/injector.dart';
import 'app/core/network/service/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await LocalNotificationService.initialize();
  runApp(ProviderScope(child: const AdminDashboardAppInitializer()));
}


//// import 'package:firebase_admin/app/features/initialization/app_initializer.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:logging/logging.dart';
// //
// // import 'app/core/di/injector.dart';
// //
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await initDependencies();
// //   Logger.root.level = Level.ALL;
// //   Logger.root.onRecord.listen((record) {
// //     print('${record.level.name}: ${record.message}');
// //   });
// //   runApp(ProviderScope(child: const AdminDashboardAppInitializer()));
// // }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'app/core/configuration/firebase_options.dart';
//
//
// void main() async {
//   // 1. Standard Flutter and Firebase initialization
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // 2. Call the one-time upload function
//   // It's safe to run this every time, as .set() will just overwrite
//   // existing documents with the same ID.
//   await _uploadProductsFromAsset();
//
//   // 3. Run your app
//   runApp(const MyApp());
// }
//
// /// A one-time utility function to upload product data from a local JSON asset.
// Future<void> _uploadProductsFromAsset() async {
//   final firestore = FirebaseFirestore.instance;
//   print("--- Starting Product Upload ---");
//
//   try {
//     // Load the JSON string from the asset file
//     final String jsonString = await rootBundle.loadString('assets/images/products_import.json');
//
//     // Decode the JSON string into a Dart Map
//     final Map<String, dynamic> data = json.decode(jsonString);
//
//     // The JSON file has a top-level key "products" which contains the map of products
//     final Map<String, dynamic> productsMap = data['products'];
//
//     if (productsMap.isEmpty) {
//       print("No products found in the JSON file.");
//       return;
//     }
//
//     // Get the collection reference
//     final CollectionReference productsCollection = firestore.collection('products');
//
//     // Create a batch write operation
//     final WriteBatch batch = firestore.batch();
//     int count = 0;
//
//     // Iterate over the products map
//     // The key is the document ID and the value is the product data
//     productsMap.forEach((documentId, productData) {
//       // Create a document reference for each product using its ID
//       final DocumentReference docRef = productsCollection.doc(documentId);
//
//       // Add a 'set' operation to the batch.
//       // We explicitly cast productData to the correct type.
//       batch.set(docRef, productData as Map<String, dynamic>);
//       count++;
//     });
//
//     // Commit the batch to Firestore
//     await batch.commit();
//
//     print("✅ Successfully uploaded $count products to the 'products' collection.");
//
//   } catch (e) {
//     print("❌ An error occurred during product upload: $e");
//   } finally {
//     print("--- Product Upload Script Finished ---");
//   }
// }
//
//
// // A simple placeholder app to run after the script.
// // You can replace this with your actual app widget.
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Firestore Upload Script',
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Firestore Data Uploader'),
//         ),
//         body: const Center(
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text(
//               'Check your debug console to see the upload status. Once done, you can remove the _uploadProductsFromAsset() call from main().',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }