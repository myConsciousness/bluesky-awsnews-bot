import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:bluesky/bluesky.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:bluesky/cardyb.dart' as cardyb;
import 'package:intl/intl.dart';

import '../aws/aws_s3.dart';
import 'feed.dart' as feed;
import 'session.dart';

const _kMaxCountPerHour = 5;
const _kTags = ['amazon', 'aws', 'awsnews'];

final _utcFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss');

final class AwsNewsPoster {
  const AwsNewsPoster(
    final S3 s3,
    final feed.Feed feed,
  )   : _s3 = s3,
        _feed = feed;

  final S3 _s3;
  final feed.Feed _feed;

  Future<void> execute() async {
    final response = await http.get(Uri.parse(_feed.uri));
    if (response.statusCode != 200) return;

    final items = RssFeed.parse(response.body).items;
    if (items.isEmpty) return;

    final guidBucketKey = 'head_guid_${_feed.name}.txt';
    final headGuid = await getObject(
      _s3,
      bucketKey: guidBucketKey,
    );

    final today = DateTime.now().toUtc();
    final templates = <AwsNewsTemplate>[];
    for (int i = 0; i < _kMaxCountPerHour;) {
      final item = items[i];
      if (headGuid == item.guid) {
        //* No more news.
        break;
      }

      if (item.pubDate == null) continue;
      final parsedPubDate = _utcFormat.parse(item.pubDate!);

      if (parsedPubDate.year != today.year ||
          parsedPubDate.month != today.month ||
          parsedPubDate.day != today.day) {
        //* No more news.
        break;
      }

      if (item.title == null) continue;
      if (item.link == null) continue;

      templates.add(AwsNewsTemplate(item.title!, item.link!));
      i++;
    }

    if (templates.isNotEmpty) {
      await _post(templates);

      await putObject(
        _s3,
        items.first.guid!,
        bucketKey: guidBucketKey,
      );
    }
  }

  Future<void> _post(final List<AwsNewsTemplate> templates) async {
    if (templates.isEmpty) return;

    final bsky = Bluesky.fromSession(await session);

    for (final template in templates.reversed) {
      await bsky.feed.post(
        text: template.build(),
        embed: await _getEmbedExternal(template.link, bsky),
        tags: [
          ..._kTags,
          _feed.category,
          _feed.title,
        ],
      );
    }
  }

  Future<Embed?> _getEmbedExternal(
    final String url,
    final Bluesky bsky,
  ) async {
    try {
      final preview = await cardyb.findLinkPreview(Uri.parse(url));

      final imageBlob = await http.get(Uri.parse(preview.data.image));
      final uploaded = await bsky.repo.uploadBlob(imageBlob.bodyBytes);

      return Embed.external(
        data: EmbedExternal(
          external: EmbedExternalThumbnail(
            uri: preview.data.url,
            title: preview.data.title,
            description: preview.data.description,
            blob: uploaded.data.blob,
          ),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

final class AwsNewsTemplate {
  const AwsNewsTemplate(
    this.title,
    this.link,
  );

  final String title;
  final String link;

  String build() {
    final buffer = StringBuffer();

    buffer.write(title);

    return buffer.toString();
  }
}
