import 'package:aws_lambda_dart_runtime_ns/aws_lambda_dart_runtime_ns.dart';
import 'package:aws_s3_api/s3-2006-03-01.dart';

import '../bsky/post.dart';

FunctionHandler postAwsnews(S3 s3) => FunctionHandler(
      name: 'post.awsnews',
      action: (context, event) async {
        await post(s3);

        return InvocationResult(requestId: context.requestId);
      },
    );
