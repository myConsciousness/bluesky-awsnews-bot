import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:bluesky/bluesky.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:bluesky/cardyb.dart' as cardyb;
import 'package:intl/intl.dart';

import '../aws/aws_s3.dart';
import 'feed.dart' as aws;

const _kMaxCountPerHour = 5;

final _utcFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss');

final class AwsNewsPoster {
  const AwsNewsPoster(
    final S3 s3,
    final aws.Feed feed,
    final Session session,
  )   : _s3 = s3,
        _feed = feed,
        _session = session;

  final S3 _s3;
  final aws.Feed _feed;
  final Session _session;

  Future<void> execute() async {
    final response = await http.get(Uri.parse(_feed.uri));
    if (response.statusCode != 200) return;

    final items = RssFeed.parse(response.body).items;
    if (items.isEmpty) return;

    final guidBucketKey = 'head_guid_${_feed.name}.txt';
    final headGuid = await getObject(_s3, bucketKey: guidBucketKey);

    final today = DateTime.now().toUtc();
    final news = <AwsNews>[];
    for (int i = 0; i < _kMaxCountPerHour;) {
      final item = items[i];
      if (headGuid == item.guid) {
        //* No more news.
        break;
      }

      if (item.pubDate == null) continue;
      final parsedPubDate = _utcFormat.parse(item.pubDate!);

      if (today.difference(parsedPubDate).inDays > 2) {
        //* No more news.
        break;
      }

      if (item.title == null) continue;
      if (item.link == null) continue;

      news.add(
        AwsNews(
          item.title!,
          item.link!,
          item.categories.map((e) => e.value!).take(8).toList(),
        ),
      );

      i++;
    }

    if (news.isNotEmpty) {
      await _post(news);
      await putObject(_s3, items.first.guid!, bucketKey: guidBucketKey);
    }
  }

  Future<void> _post(final List<AwsNews> news) async {
    if (news.isEmpty) return;

    final bsky = Bluesky.fromSession(_session);

    for (final $news in news.reversed) {
      await bsky.feed.post(
        text: $news.toString(),
        embed: await _getEmbedExternal($news.link, bsky),
        tags: $news.tags,
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

final class AwsNews {
  const AwsNews(
    this.title,
    this.link,
    this.tags,
  );

  final String title;
  final String link;
  final List<String> tags;
}
