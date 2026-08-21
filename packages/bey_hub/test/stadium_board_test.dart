import 'dart:io';
import 'package:bey_hub/bey_hub.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('LanHubServer Stadium Board Tests', () {
    late LanHubServer server;
    const port = 8999;

    setUp(() async {
      server = LanHubServer();
      await server.start(port: port);
    });

    tearDown(() async {
      await server.stop();
    });

    test('serves /stadium-board HTML successfully with status 200', () async {
      final res = await http.get(Uri.parse('http://127.0.0.1:$port/stadium-board'));
      expect(res.statusCode, HttpStatus.ok);
      expect(res.headers['content-type'], contains('text/html'));
      expect(res.body, contains('BEYSCORE · STADIUM JUMBOTRON'));
      expect(res.body, contains('pollStadiumStatus'));
    });
  });
}
