import 'package:aws_lambda_dart_runtime_ns/aws_lambda_dart_runtime_ns.dart';

import '../bsky/post.dart';

FunctionHandler postAwsnews() => FunctionHandler(
      name: 'post.awsnews',
      action: (context, event) async {
        await post();

        return InvocationResult(requestId: context.requestId);
      },
    );
