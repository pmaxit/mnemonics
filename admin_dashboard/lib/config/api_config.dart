class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mnemonics-notifications-production.up.railway.app',
  );
}
