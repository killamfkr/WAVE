import 'package:flutter_test/flutter_test.dart';
import 'package:wave/core/api/deezer_api_client.dart';

void main() {
  test('fetch chart albums', () async {
    final client = DeezerApiClient();
    final albums = await client.getChartAlbums();
    print('Albums count: \${albums.length}');
    for (final album in albums) {
      print('Album: \${album.title}');
    }

    final newReleases = await client.getNewReleases();
    print('Releases count: \${newReleases.length}');
  });
}
