import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/cardyb.dart' as cardyb;
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../aws/aws_s3.dart';
import 'session.dart';

final _utcFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss');

const _kTags = ['amazon', 'aws', 'awsnews'];
const _kCountPerHour = 15;

Future<void> post(final S3 s3) async {
  final response = await http.get(Uri.https(
    'aws.amazon.com',
    '/about-aws/whats-new/recent/feed',
  ));

  final headGuid = await getObject(s3);
  final channel = RssFeed.parse(response.body);

  final items = channel.items;
  final templates = <AwsNewsTemplate>[];
  for (int i = 0; i < _kCountPerHour;) {
    final item = items[i];

    if (item.title == null) continue;
    if (item.link == null) continue;
    if (item.pubDate == null) continue;

    if (headGuid == item.guid) {
      break;
    }

    templates.add(
      AwsNewsTemplate(
        item.title!,
        item.link!,
        _utcFormat.parseUtc(item.pubDate!),
      ),
    );

    i++;
  }

  await _post(templates);
  await putObject(s3, channel.items.first.guid!);
}

Future<void> _post(final List<AwsNewsTemplate> templates) async {
  if (templates.isEmpty) return;

  final bsky = Bluesky.fromSession(await session);

  for (final template in templates.reversed) {
    await bsky.feed.post(
      text: template.build(),
      embed: await _getEmbedExternal(template.link, bsky),
      tags: _kTags,
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

final class AwsNewsTemplate {
  const AwsNewsTemplate(
    this.title,
    this.link,
    this.pubDate,
  );

  final String title;
  final String link;
  final DateTime pubDate;

  String build() {
    final buffer = StringBuffer();

    buffer
      ..write(title)
      ..write(' ')
      ..write('(${_utcFormat.format(pubDate)})');

    return buffer.toString();
  }
}
