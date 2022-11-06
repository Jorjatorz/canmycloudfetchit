import 'package:flutter/material.dart';

import 'apiWidgets.dart';

class ResultsWidget extends StatelessWidget {
  const ResultsWidget({super.key, required this.searchString});

  final String? searchString;

  @override
  Widget build(BuildContext context) {
    if (searchString == null) {
      return const SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        APIWidget(
          apiProvider: AmazonAPIProvider(),
        )
      ],
    );
  }
}
