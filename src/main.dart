import 'package:aws_lambda_dart_runtime_ns/aws_lambda_dart_runtime_ns.dart';

import 'aws/aws_lambda.dart';

Future<void> main() async => await invokeAwsLambdaRuntime([
      postAwsnews(),
    ]);
