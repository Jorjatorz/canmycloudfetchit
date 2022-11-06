import 'dart:math';

import 'package:cloud_api_fetcher/design/constants.dart';
import 'package:flutter/material.dart';

class APIResult {
  bool valid; // True if the request returned sucess
  int? code; // Error code
  String? message; // Error message

  APIResult({
    required this.valid,
    this.code,
    this.message,
  });
}

abstract class APIProvider {
  final Color providerColor = Colors.cyan;

  Widget getTitleWidget(context);
  Future<APIResult> fetchAPI(String url);
}

class AmazonAPIProvider implements APIProvider {
  @override
  Widget getTitleWidget(context) {
    return Text(
      "AWS",
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: providerColor, fontWeight: FontWeight.bold),
    );
  }

  @override
  Future<APIResult> fetchAPI(String url) {
    return Future<APIResult>.delayed(
      const Duration(seconds: 2),
      () => APIResult(
          valid: Random().nextBool(),
          code: 401,
          message: "This is a fake error message"),
    );
  }

  @override
  Color get providerColor => Colors.orange;
}

class APIWidget extends StatefulWidget {
  const APIWidget({super.key, required this.apiProvider});

  final AmazonAPIProvider apiProvider;

  @override
  State<APIWidget> createState() => _APIWidgetState();
}

class _APIWidgetState extends State<APIWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: cPrimaryColor),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        gradient: LinearGradient(
          colors: [
            widget.apiProvider.providerColor.withOpacity(0.15),
            widget.apiProvider.providerColor.withOpacity(0.08),
            cBackgroundColor.withOpacity(0.0)
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.apiProvider.getTitleWidget(context),
          FutureBuilder<APIResult>(
            future: widget.apiProvider.fetchAPI("asdasda"),
            builder: (BuildContext context, AsyncSnapshot<APIResult> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                APIResult result = snapshot.data!;
                if (result.valid) {
                  children = <Widget>[
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 30,
                    ),
                  ];
                } else {
                  children = <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 30,
                    ),
                  ];
                }
              } else {
                children = const <Widget>[
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
