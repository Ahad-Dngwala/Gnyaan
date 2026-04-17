import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) return;
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    var content = file.readAsStringSync();
    if (content.contains("import '../../..")) {
      content = content.replaceAll(RegExp(r"import '\.\./\.\./\.\./core/"), "import 'package:gnyaan/core/");
      content = content.replaceAll(RegExp(r"import '\.\./\.\./\.\./shared/"), "import 'package:gnyaan/shared/");
      content = content.replaceAll(RegExp(r"import '\.\./\.\./core/"), "import 'package:gnyaan/core/");
      content = content.replaceAll(RegExp(r"import '\.\./\.\./shared/"), "import 'package:gnyaan/shared/");
      content = content.replaceAll(RegExp(r"import '\.\./core/"), "import 'package:gnyaan/core/");
      content = content.replaceAll(RegExp(r"import '\.\./shared/"), "import 'package:gnyaan/shared/");
      file.writeAsStringSync(content);
    }
  }
}
