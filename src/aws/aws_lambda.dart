import 'package:aws_lambda_dart_runtime_ns/aws_lambda_dart_runtime_ns.dart';
import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:bluesky/bluesky.dart';

import '../post/post.dart';
import '../post/feed.dart' as aws;

List<FunctionHandler> postAwsNews(
  S3 s3,
  final Session session,
) =>
    aws.Feed.values.map((feed) {
      return FunctionHandler(
        name: feed.name,
        action: (context, event) async {
          await AwsNewsPoster(s3, feed, session).execute();

          return InvocationResult(requestId: context.requestId);
        },
      );
    }).toList();
