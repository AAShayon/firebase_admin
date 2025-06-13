// lib/core/helpers/sequential_id_generator.dart

class SequentialIdGenerator {
  static int _counter = 0;
  static String generate() {
    _counter++;
    return _counter.toString().padLeft(6, '0');
  }
}