import 'package:bluesky/bluesky.dart';
import 'package:bluesky/cardyb.dart' as cardyb;
import 'package:bluesky_text/bluesky_text.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'session.dart';

final _utcFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
const _tags = ['amazon', 'aws', 'awsnews'];

Future<void> post() async {
  final response = await http.get(Uri.https(
    'aws.amazon.com',
    '/about-aws/whats-new/recent/feed',
  ));

  final templates = <AwsNewsTemplate>[];
  for (final item in RssFeed.parse(response.body).items) {
    if (item.title == null) continue;
    if (item.link == null) continue;
    if (item.pubDate == null) continue;

    final pubDate = _utcFormat.parseUtc(item.pubDate!);
    final thirtyMinutesAgo = DateTime.now().toUtc().add(Duration(minutes: -30));

    if (pubDate.isAfter(thirtyMinutesAgo)) {
      templates.add(
        AwsNewsTemplate(
          item.title!,
          item.link!,
          pubDate,
        ),
      );
    }
  }

  final bsky = Bluesky.fromSession(await session);

  await bsky.feed.postInBulk(await _preparePostParams(bsky, templates));
}

Future<List<PostParam>> _preparePostParams(
  final Bluesky bsky,
  final List<AwsNewsTemplate> templates,
) async {
  final params = <PostParam>[];
  for (final template in templates.reversed) {
    final text = BlueskyText(
      template.build(),
      linkConfig: const LinkConfig(
        excludeProtocol: true,
        enableShortening: true,
      ),
    );

    final facets = await text.links.toFacets();

    params.add(
      PostParam(
        text: text.value,
        facets: facets.map(Facet.fromJson).toList(),
        embed: await _getEmbedExternal(template.link, bsky),
        languageTags: ['en'],
        tags: _tags,
      ),
    );
  }

  return params;
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

    buffer.write(title);

    return buffer.toString();
  }
}
