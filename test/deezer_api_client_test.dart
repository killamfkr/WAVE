import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave/core/api/deezer_api_client.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.responses);
  final Map<String, Map<String, dynamic>> responses;
  final List<String> calls = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final path = options.path;
    calls.add(path);
    final body = responses[path] ?? <String, dynamic>{'data': <dynamic>[]};
    final bytes = Uint8List.fromList(utf8.encode(json.encode(body)));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late _StubAdapter adapter;
  late DeezerApiClient client;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.deezer.com'));
    adapter = _StubAdapter(<String, Map<String, dynamic>>{
      '/chart/0/tracks': <String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'title': 'A',
            'artist': <String, dynamic>{'id': 10, 'name': 'AA'},
          },
          <String, dynamic>{
            'id': 2,
            'title': 'B',
            'artist': <String, dynamic>{'id': 11, 'name': 'BB'},
          },
        ],
      },
      '/search': <String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 99,
            'title': 'Hit',
            'artist': <String, dynamic>{'id': 5, 'name': 'X'},
          },
        ],
      },
      '/album/100': <String, dynamic>{
        'id': 100,
        'title': 'Discovery',
        'nb_tracks': 14,
      },
    });
    dio.httpClientAdapter = adapter;
    client = DeezerApiClient(dio: dio);
  });

  test('getChartTracks parses list', () async {
    final tracks = await client.getChartTracks(limit: 2);
    expect(tracks, hasLength(2));
    expect(tracks.first.title, 'A');
    expect(tracks.first.artist?.name, 'AA');
  });

  test('searchTracks parses list', () async {
    final res = await client.searchTracks('Hit');
    expect(res, hasLength(1));
    expect(res.single.id, 99);
  });

  test('getAlbum parses object', () async {
    final a = await client.getAlbum(100);
    expect(a.title, 'Discovery');
    expect(a.nbTracks, 14);
  });

  test('CancelToken cancels in-flight request', () async {
    final token = CancelToken();
    token.cancel('test cancel');
    expect(
      () => client.getChartTracks(cancelToken: token),
      throwsA(isA<DioException>()),
    );
  });
}
