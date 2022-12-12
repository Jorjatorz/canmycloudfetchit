import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:cloud_api_fetcher/design/constants.dart';
import 'package:cloud_api_fetcher/states/searchState.dart';
import 'package:http/http.dart' as http;

class APIResult {
  // Result of a cloud API request

  bool valid; // True if the request returned succeded
  int? code; // Error code
  String? message; // Error message

  APIResult({
    required this.valid,
    this.code,
    this.message,
  });
}

abstract class APIProvider {
  // Class that manages the fetch request to a Cloud provider

  final String providerName;
  final Color providerColor;
  final APIWidgetsController _controller;
  Future<APIResult>? fetchFuture;

  APIProvider(this._controller, this.providerColor, this.providerName);

  Widget getTitleWidget(context) {
    return Text(
      providerName,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: providerColor, fontWeight: FontWeight.bold),
    );
  }

  Future<APIResult> fetchAPI(String url);
}

class LocalAPIProvider extends APIProvider {
  LocalAPIProvider(APIWidgetsController controller)
      : super(controller, Colors.white, "Web Server");

  @override
  Future<APIResult> fetchAPI(String url) {
    fetchFuture = Future<APIResult>(
      () async {
        APIResult? result;
        try {
          final request = await http
              .head(Uri.parse(url))
              .timeout(const Duration(seconds: 5));

          result = APIResult(
              valid: request.statusCode < 400,
              code: request.statusCode,
              message: request.reasonPhrase);
        } on TimeoutException catch (_) {
          result = APIResult(valid: false, code: 404, message: "Timeout error");
        } on SocketException catch (_) {
          result =
              APIResult(valid: false, code: 404, message: "Connection error");
        } catch (e) {
          result = APIResult(valid: false, code: 404, message: e.toString());
        }

        _controller.notifyLocalProviderFinished(this, result);
        return result;
      },
    );
    return fetchFuture!;
  }
}

class AWSAPIProvider extends APIProvider {
  AWSAPIProvider(APIWidgetsController controller)
      : super(controller, Colors.orange, "AWS");

  @override
  Future<APIResult> fetchAPI(String url) {
    fetchFuture = Future<APIResult>(
      () async {
        APIResult? result;
        try {
          final request = await http
              .get(Uri.parse(
                  "https://zb3gzdwpe4.execute-api.eu-west-3.amazonaws.com/production/perform-fetch?url=$url"))
              .timeout(const Duration(seconds: 5));

          result = APIResult(
              valid: request.statusCode < 400,
              code: request.statusCode,
              message: request.reasonPhrase);
        } on TimeoutException catch (_) {
          result = APIResult(valid: false, code: 404, message: "Timeout error");
        } on SocketException catch (_) {
          result =
              APIResult(valid: false, code: 404, message: "Connection error");
        } catch (e) {
          result = APIResult(valid: false, code: 404, message: e.toString());
        } // TODO REfactor duplicated code between APIProviders

        _controller.notifyCloudProviderFinished(this);
        return result;
      },
    );

    return fetchFuture!;
  }
}

class APIWidgetsController {
  // Creates and controls the different APIProviders.

  List<APIProvider> providers = [];
  final FetchStateNotifier stateNotifier;
  int finishedCloudProviders = 0;

  APIWidgetsController(this.stateNotifier) {
    // First provider will always be the local provider
    providers.add(LocalAPIProvider(this)..fetchAPI(stateNotifier.fetchString!));

    // Cloud providers
    providers.add(AWSAPIProvider(this));
  }

  void dispose() {
    providers.clear();
  }

  APIProvider getLocalAPIProvider() {
    return providers.first;
  }

  List<APIProvider> getCloudAPIProviders() {
    return providers.sublist(1);
  }

  void notifyLocalProviderFinished(APIProvider provider, APIResult result) {
    if (result.valid) {
      // Change state and start fetching
      stateNotifier.startCloudFetch();
      for (provider in getCloudAPIProviders()) {
        provider.fetchAPI(stateNotifier.fetchString!);
      }
    } else {
      stateNotifier.fetchFinished();
    }
  }

  void notifyCloudProviderFinished(APIProvider provider) {
    finishedCloudProviders++;
    if (finishedCloudProviders == (providers.length - 1)) {
      // Count all except the local provider
      stateNotifier.fetchFinished();
    }
  }
}

class APIWidget extends StatefulWidget {
  APIWidget({required this.apiProvider})
      : super(key: ValueKey(apiProvider.providerName));

  final APIProvider apiProvider;

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
            future: widget.apiProvider.fetchFuture,
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
                    Tooltip(
                      message: "${result.code} - ${result.message}",
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 30,
                      ),
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
