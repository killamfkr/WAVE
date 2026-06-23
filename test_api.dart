import 'package:wave/core/api/deezer_api_client.dart';
import 'package:wave/core/utils/app_logger.dart';

void main() async {
  try {
    final client = DeezerApiClient();
    final albums = await client.getChartAlbums();
    print('Chart albums: \${albums.length}');
    if (albums.isNotEmpty) {
      print('First: \${albums.first.title}');
    }

    final newReleases = await client.getNewReleases();
    print('New releases: \${newReleases.length}');
    if (newReleases.isNotEmpty) {
      print('First: \${newReleases.first.title}');
    }
  } catch (e, stack) {
    print('Error: $e\\n$stack');
  }
}
