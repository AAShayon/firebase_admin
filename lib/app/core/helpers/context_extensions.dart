// lib/app/core/helpers/context_extensions.dart (Your file, no changes needed)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension SafeContextNavigation on BuildContext {
  void safeGo(String path, {Object? extra}) {
    if (mounted) go(path, extra: extra);
  }

  void safeGoNamed(String name, {Map<String, String> pathParameters = const {}, Map<String, dynamic> queryParameters = const {}, Object? extra}) {
    if (mounted) goNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  }

  void safePush(String path, {Object? extra}) {
    if (mounted) push(path, extra: extra);
  }

  void safePushNamed(String name, {Map<String, String> pathParameters = const {}, Map<String, dynamic> queryParameters = const {}, Object? extra}) {
    if (mounted) pushNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  }

  void safePop<T extends Object?>([T? result]) {
    if (mounted) pop(result);
  }

  void safeShowSnackBar(SnackBar snackBar) {
    if (mounted) {
      ScaffoldMessenger.of(this).removeCurrentSnackBar();
      ScaffoldMessenger.of(this).showSnackBar(snackBar);
    }
  }
}