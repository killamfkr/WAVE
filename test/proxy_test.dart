import 'package:flutter_test/flutter_test.dart';
import 'package:wave/core/api/deezer_api_client.dart';

void main() {
  test('fetch via proxy', () async {
    await DeezerApiClient.loadEnv();
    DeezerApiClient.proxyUrl = 'http://209.38.209.74:3000/proxy?url=';
    DeezerApiClient.useProxy = true;

    final client = DeezerApiClient();

    print('Testing getChartAlbums...');
    try {
      final albums = await client.getChartAlbums(limit: 25);
      print('Albums count: \${albums.length}');
    } catch (e) {
      print('Albums Error: \$e');
    }

    print('Testing getNewReleases...');
    try {
      final releases = await client.getNewReleases();
      print('Releases count: \${releases.length}');
    } catch (e) {
      print('Releases Error: \$e');
    }

    print('Testing getChartArtists...');
    try {
      final artists = await client.getChartArtists(limit: 25);
      print('Artists count: \${artists.length}');
    } catch (e) {
      print('Artists Error: \$e');
    }
  });
}
