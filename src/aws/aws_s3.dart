import 'dart:convert';

import 'package:aws_s3_api/s3-2006-03-01.dart';

const _kBucket = 's3-bluesky-bot-awsnews';

Future<void> putObject(
  final S3 s3,
  final String value, {
  required String bucketKey,
}) async =>
    await s3.putObject(
      bucket: _kBucket,
      key: bucketKey,
      body: utf8.encode(value),
    );

Future<String> getObject(
  final S3 s3, {
  required String bucketKey,
}) async {
  try {
    final object = await s3.getObject(bucket: _kBucket, key: bucketKey);

    return object.body != null ? utf8.decode(object.body!) : '';
  } catch (_) {
    return '';
  }
}
