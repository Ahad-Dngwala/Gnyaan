import 'dart:io';

void main() {
  final files = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    var c = file.readAsStringSync();
    final original = c;
    
    // Replace dark mode linear gradients
    c = c.replaceAll('Color(0xFF16183A), Color(0xFF111620)', 'AppColors.bg800, AppColors.bg600');
    
    if (original != c) {
      file.writeAsStringSync(c);
      print('Updated \');
    }
  }
}
