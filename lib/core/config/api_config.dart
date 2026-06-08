class ApiConfig {
  static const String baseUrl = 'https://mnemonics-api-production.up.railway.app';

  static const String vocabulary = '$baseUrl/vocabulary';
  static const String wordSets = '$baseUrl/word_sets';
  static const String categories = '$baseUrl/categories';
  static const String health = '$baseUrl/health';

  static String userProfile(String userId) => '$baseUrl/user_profile/$userId';
  static String notes(String userId, String word) => '$baseUrl/notes/$userId/$word';
  static String learnedStatus(String userId, String word) => '$baseUrl/learned_status/$userId/$word';
  static String allLearnedStatus(String userId) => '$baseUrl/learned_status/$userId';
  static String userProgress(String userId) => '$baseUrl/user_progress/$userId';
  static String wordProgress(String userId, String word) => '$baseUrl/user_progress/$userId/$word';
  static String resetUser(String userId) => '$baseUrl/reset/$userId';
}