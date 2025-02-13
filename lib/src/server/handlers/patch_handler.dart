import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:shelf/shelf.dart';

import '../../repositories/database_repository.dart';

class PatchHandler {
  final _databaseRepository = GetIt.I.get<DatabaseRepository>();
  Future<Map<String, dynamic>?> execute(Request request) async {
    final segments = request.url.pathSegments;
    final String table = segments.first;

    if (segments.length < 2) {
      return null;
    }

    final String id = segments[1];

    if (_databaseRepository.tableExists(table)) {
      var body = await request.readAsString();
      if (body.contains('#userAuthRef')) {
        body = body.replaceAll('#userAuthRef', request.headers['user'] ?? '0');
      }
      final dataUpdate = jsonDecode(body);
      dataUpdate['id'] = int.parse(id);
      _databaseRepository.save(table, dataUpdate);

      return dataUpdate;
    }

    return null;
  }
}
