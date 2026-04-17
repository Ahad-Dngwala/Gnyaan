/// Design tokens & spacing system for Gnyaan app

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double screenPadding = 20.0;
}

class AppRadius {
  AppRadius._();

  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double pill = 100.0;
  static const double circle = 9999.0;
}

class AppDurations {
  AppDurations._();

  static const Duration tiny = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  static const Duration stagger = Duration(milliseconds: 80);
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Gnyaan';
  static const String tagline = 'AI Knowledge Engine';
  static const String version = '1.0.0';

  // RAG thresholds
  static const double similarityThreshold = 0.30;
  static const int chunkSize = 400;
  static const int chunkOverlap = 50;
  static const int topKResults = 5;

  // File constraints
  static const int maxFileSizeMB = 50;
  static const List<String> supportedExtensions = ['pdf', 'docx', 'txt'];
}
