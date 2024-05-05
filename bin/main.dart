import 'package:aws_s3_api/s3-2006-03-01.dart';

import '../src/bsky/post.dart';

void main(List<String> args) async {
  await post(S3(region: 'ap-northeast-1'));
}
