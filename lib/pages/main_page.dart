import 'package:cloud_api_fetcher/design/constants.dart';
import 'package:cloud_api_fetcher/states/searchState.dart';
import 'package:cloud_api_fetcher/widgets/resultsWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rainbow_color/rainbow_color.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Global key for the url input
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: cDefaultWidth,
                      minHeight: MediaQuery.of(context).size.height),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const AnimatedMainTitle(),
                      const SizedBox(
                        height: 10,
                        child: VerticalDivider(
                          indent: 10,
                          endIndent: 10,
                        ),
                      ),
                      Text(
                          'Some API endpoints block requests coming from Cloud providers IPs.',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(
                        height: 150,
                        child: VerticalDivider(
                          indent: 10,
                          endIndent: 10,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        child: Provider.of<SearchStateNotifier>(context)
                                    .currentState ==
                                SearchState.noSearch
                            ? SizedBox(
                                child: Column(
                                  children: [
                                    Text(
                                        'Paste the API url and we will retrieve which providers can fetch from it.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 600,
                                            child: TextFormField(
                                              textAlign: TextAlign.center,
                                              decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText:
                                                      "https://www.mycooldomain.com/api/"),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter the API url to check';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                Provider.of<SearchStateNotifier>(
                                                        context,
                                                        listen: false)
                                                    .startSearch("test");
                                              }
                                            },
                                            child: const Text('Check'),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  ResultsWidget(
                                      searchString:
                                          Provider.of<SearchStateNotifier>(
                                                  context)
                                              .searchString),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Provider.of<SearchStateNotifier>(
                                                  context,
                                                  listen: false)
                                              .resetSearch(),
                                      child: const Text("Search again"))
                                ],
                              ),
                      ),
                      const SizedBox(height: 100),
                      _buildFAQ(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Created by Jorge Sánchez Cremades"),
              ))
        ],
      ),
    );
  }

  ExpansionPanelList _buildFAQ() {
    return ExpansionPanelList.radio(
        dividerColor: cPrimaryColor,
        expandedHeaderPadding: EdgeInsets.zero,
        children: [
          _faqExpansionPanel(1, "How does it work?",
              """The provided API url will be sent to the supported Cloud providers and each one will run a HEAD request against it. (i.e. a body-less GET request)

Depending on the API return code a success or failure marker will appear next to each Cloud provider."""),
          _faqExpansionPanel(2, "What can I fetch?",
              """This page was built with API end-points in mind, albeit you can target any HTTP endpoint. It is recommended to use the API healthcheck endpoint to avoid higher latencies."""),
          _faqExpansionPanel(3, "Will more providers be supported?",
              """The number of supported providers will increase over time.

Keep in mind that this page uses the free-tier to reduce costs, so if a Cloud provider do not have a free-tier then it will not be added in the near future."""),
          _faqExpansionPanel(4, "Are endpoints and results cached?",
              "No, but they will be in the future.")
        ]);
  }

  ExpansionPanelRadio _faqExpansionPanel(int id, String title, String body) {
    return ExpansionPanelRadio(
      value: id,
      backgroundColor: cBackgroundColor,
      canTapOnHeader: true,
      headerBuilder: (BuildContext context, bool isExpanded) {
        return Center(
            child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ));
      },
      body: Text(
        body,
        textAlign: TextAlign.start,
      ),
    );
  }
}

class AnimatedMainTitle extends StatefulWidget {
  const AnimatedMainTitle({
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedMainTitle> createState() => _AnimatedMainTitleState();
}

class _AnimatedMainTitleState extends State<AnimatedMainTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color> _colorAnim;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _colorAnim = RainbowColorTween([
      Colors.blue,
      Colors.orange,
      Colors.red,
      const Color(0xFF43C6AC),
      Colors.blue,
    ]).animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
          controller.forward();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Can my ',
        style: Theme.of(context).textTheme.headlineLarge,
        children: <TextSpan>[
          TextSpan(text: 'Cloud', style: TextStyle(color: _colorAnim.value)),
          const TextSpan(text: ' fetch it?'),
        ],
      ),
    );
  }
}
