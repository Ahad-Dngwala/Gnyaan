import 'dart:io';

void main() {
  final files = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    var c = file.readAsStringSync();
    final original = c;
    
    // Replace type names
    c = c.replaceAll('_DocModel', 'DocModel');
    c = c.replaceAll('_Message', 'ChatMessage');
    c = c.replaceAll('_Source', 'ChatSource');
    c = c.replaceAll('_InsightModel', 'InsightModel');
    
    // Fix missing LucideIcons
    c = c.replaceAll('LucideIcons.grid3x3', 'LucideIcons.grid');
    c = c.replaceAll('LucideIcons.squareIcon', 'LucideIcons.square');
    
    if (original != c) {
      file.writeAsStringSync(c);
    }
  }
}
