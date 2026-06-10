import 'package:drift/drift.dart';

Future<QueryExecutor> openAppDatabaseConnection() {
  throw UnsupportedError(
    'A QueryExecutor is required when AppDatabase runs outside Flutter.',
  );
}
