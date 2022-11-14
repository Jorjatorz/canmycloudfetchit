import 'package:cloud_api_fetcher/states/searchState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'apiWidgets.dart';

class APIFetchWidget extends StatefulWidget {
  const APIFetchWidget({super.key});

  @override
  State<APIFetchWidget> createState() => _APIFetchWidgetState();
}

class _APIFetchWidgetState extends State<APIFetchWidget> {
  @override
  Widget build(BuildContext context) {
    FetchStateNotifier currentSearchState =
        Provider.of<FetchStateNotifier>(context);

    if (currentSearchState.fetchString == null) {
      return const SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentSearchState.currentState == FetchState.fetchingLocal)
          APIWidget(
            apiProvider: LocalAPIProvider(),
          )
        else ...[
          APIWidget(
            apiProvider: AmazonAPIProvider(),
          )
        ],
        const SizedBox(
          height: 10,
        ),
        if (currentSearchState.finished)
          ElevatedButton(
              onPressed: () =>
                  Provider.of<FetchStateNotifier>(context, listen: false)
                      .resetFetch(),
              child: const Text("Search again"))
      ],
    );
  }
}
