import 'dart:io' show Platform;

import 'package:aws_lambda_dart_runtime_ns/aws_lambda_dart_runtime_ns.dart';
import 'package:aws_s3_api/s3-2006-03-01.dart';

import 'aws/aws_lambda.dart';
import 'post/session.dart';

Future<void> main() async {
  final s3 = S3(region: Platform.environment['AWS_REGION']!);

  await invokeAwsLambdaRuntime(
    postAwsNews(s3, await session),
  );
}
