// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import 'app_router.dart';
//
// class NavigationService {
//   final GoRouter _router = appRouter;
//
//   // Navigate to a named route
//   void navigateTo(String routeName, {Map<String, String> params = const {}}) {
//     final path = AppRoutes.getPathFromName(routeName);
//     if (path != null) {
//       final resolvedPath = _resolvePathWithParams(path, params);
//       _router.push(resolvedPath);
//     } else {
//       throw Exception('Route name "$routeName" not found in AppRoutes');
//     }
//   }
//
//   // Navigate back
//   void goBack({BuildContext? context}) {
//     _router.pop();
//   }
//
//   // Replace current route
//   void replaceWith(String routeName, {Map<String, String> params = const {}}) {
//     final path = AppRoutes.getPathFromName(routeName);
//     if (path != null) {
//       final resolvedPath = _resolvePathWithParams(path, params);
//       _router.replace(resolvedPath);
//     } else {
//       throw Exception('Route name "$routeName" not found in AppRoutes');
//     }
//   }
//
//   // Deep link to nested routes
//   void navigateToNested(String parentRoute, String nestedRoute,
//       {Map<String, String> params = const {}}) {
//     final parentPath = AppRoutes.getPathFromName(parentRoute);
//     if (parentPath != null) {
//       final resolvedPath =
//       _resolvePathWithParams('$parentPath/$nestedRoute', params);
//       _router.push(resolvedPath);
//     } else {
//       throw Exception('Parent route "$parentRoute" not found in AppRoutes');
//     }
//   }
//
//   // Helper to resolve dynamic paths with parameters
//   String _resolvePathWithParams(String path, Map<String, String> params) {
//     params.forEach((key, value) {
//       path = path.replaceAll(':$key', value);
//     });
//     return path;
//   }
// }