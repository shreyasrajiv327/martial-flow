// lib/utils/string_extension.dart
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String titleCase() => split(' ').map((s) => s.capitalize()).join(' ');
}