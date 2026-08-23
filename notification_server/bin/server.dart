import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as cors;
import 'package:notification_server/services/services.dart';
import 'package:notification_server/routes/api_routes.dart';

Future<void> main() async {
  final apiKey = Platform.environment['OPENROUTER_API_KEY'] ?? '';
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final host = Platform.environment['HOST'] ?? '0.0.0.0';
  final dataDir = Platform.environment['DATA_DIR'] ?? 'data';

  final dataDirectory = Directory(dataDir);
  if (!dataDirectory.existsSync()) {
    dataDirectory.createSync(recursive: true);
  }

  print('Starting Mnemonics Notification Server...');
  print('Port: $port | Host: $host | Data: $dataDir | API key: ${apiKey.isNotEmpty}');

  final logService = ActivityLogService(
    persistencePath: '$dataDir/activity_logs.jsonl',
  );
  final notificationService = NotificationService(
    persistencePath: dataDir,
  );
  final agentService = NotificationAgentService(
    apiKey: apiKey,
    model: Platform.environment['AI_MODEL'] ?? 'google/gemma-4-12b-instruct',
  );

  logService.seedDemoData();
  notificationService.seedDemoData({});

  final apiRouter = ApiRouter(
    logService: logService,
    notificationService: notificationService,
    agentService: agentService,
  );

  final handler = const Pipeline()
      .addMiddleware(cors.corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(apiRouter.router.call);

  final server = await shelf_io.serve(handler, host, port);
  print('Server running on http://${server.address.host}:${server.port}');

  ProcessSignal.sigint.watch().listen((_) {
    print('Shutting down...');
    agentService.dispose();
    server.close(force: true);
  });
}
