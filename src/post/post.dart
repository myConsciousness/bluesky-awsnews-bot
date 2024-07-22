import 'dart:io';
import 'dart:typed_data';

import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:bluesky/app_bsky_embed_external.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:bluesky/cardyb.dart' as cardyb;
import 'package:image/image.dart';
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

    final today = DateTime.now().toUtc();
    if (_isNotNews(today, _utcFormat.parse(items.first.pubDate!))) {
      //* No more news.
      return;
    }

    final guidBucketKey = 'head_guid_${_feed.name}.txt';
    final headGuid = await getObject(_s3, bucketKey: guidBucketKey);

    final news = <AwsNews>[];
    for (int i = 0; i < _kMaxCountPerHour;) {
      final item = items[i];
      if (headGuid == item.guid) {
        //* No more news.
        break;
      }

      final parsedPubDate = _utcFormat.parse(item.pubDate!);

      if (_isNotNews(today, parsedPubDate)) {
        //* No more news.
        break;
      }

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
      await putObject(_s3, items.first.guid!, bucketKey: guidBucketKey);
      await _post(news);
    }
  }

  bool _isNotNews(final DateTime today, final DateTime headPubDate) =>
      today.difference(headPubDate).inDays > 2;

  Future<void> _post(final List<AwsNews> news) async {
    if (news.isEmpty) return;

    final bsky = Bluesky.fromSession(_session);
    final records = <PostRecord>[];
    for (final $news in news.reversed) {
      final embed = await _getEmbedExternal($news.link, bsky);
      if (embed == null) continue;

      records.add(
        PostRecord(
          text: $news.title,
          embed: embed,
          tags: $news.tags,
          createdAt: DateTime.now().toUtc(),
        ),
      );

      //* https://github.com/bluesky-social/atproto/issues/2468
      sleep(const Duration(microseconds: 5));
    }

    await bsky.feed.post.createInBulk(records);
  }

  Future<UPostEmbed?> _getEmbedExternal(
    final String url,
    final Bluesky bsky,
  ) async {
    try {
      final preview = await cardyb.findLinkPreview(Uri.parse(url));

      final imageBlob = await http.get(Uri.parse(preview.data.image));
      final uploaded = await bsky.atproto.repo.uploadBlob(
        bytes: _compressImage(imageBlob.bodyBytes),
      );

      return UPostEmbed.external(
        data: External(
          external: ExternalExternal(
            uri: preview.data.url,
            title: preview.data.title,
            description: preview.data.description,
            thumb: uploaded.data.blob,
          ),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Uint8List _compressImage(Uint8List fileBytes) {
    int quality = 100;

    while (fileBytes.length > 976.56 * 1024) {
      final decodedImage = decodeImage(fileBytes);
      final encodedImage = encodeJpg(decodedImage!, quality: quality);

      final compressedSize = encodedImage.length;

      if (compressedSize < 976.56 * 1024) {
        quality += 10;
      } else {
        quality -= 15;
      }

      fileBytes = encodedImage;
    }

    return fileBytes;
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
