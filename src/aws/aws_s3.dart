import 'dart:convert';

import 'package:aws_s3_api/s3-2006-03-01.dart';

const _kBucket = 's3-bluesky-bot-awsnews';
const _kBucketKey = 'head_guid.txt';

Future<void> putObject(
  final S3 s3,
  final String value,
) async =>
    await s3.putObject(
      bucket: _kBucket,
      key: _kBucketKey,
      body: utf8.encode(value),
    );

Future<String?> getObject(final S3 s3) async {
  try {
    final object = await s3.getObject(bucket: _kBucket, key: _kBucketKey);

    return object.body != null ? utf8.decode(object.body!) : null;
  } catch (_) {
    return null;
  }
}
