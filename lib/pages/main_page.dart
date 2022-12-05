import 'package:cloud_api_fetcher/design/constants.dart';
import 'package:cloud_api_fetcher/states/searchState.dart';
import 'package:cloud_api_fetcher/widgets/apiWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rainbow_color/rainbow_color.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    FetchStateNotifier currentSearchState =
        Provider.of<FetchStateNotifier>(context);

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
                      ),
                      Text(
                          'Some API endpoints block requests coming from Cloud providers IPs.',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(
                        height: 150,
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
                          child: currentSearchState.currentState ==
                                  FetchState.noFetch
                              ? const APISearchBarWidget()
                              : const APIFetchWidget()),
                      const SizedBox(height: 150),
                      const FAQWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                    text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  text: 'Created by ',
                  children: const <TextSpan>[
                    TextSpan(
                        text: 'Jorge Sánchez Cremades',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' - v0.5'),
                  ],
                )),
              ))
        ],
      ),
    );
  }
}

// WIDGETS
class FAQWidget extends StatelessWidget {
  const FAQWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
        dividerColor: cPrimaryColor,
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        children: [
          _faqExpansionPanel(1, "How does it work?",
              """First a query from the Web Server will be issued to check if the endpoint is active. Then the provided API url will be sent to the supported Cloud providers and each one will run a HEAD request against it. (i.e. a body-less GET request)

Depending on the API return code a success or failure marker will appear next to each Cloud provider."""),
          _faqExpansionPanel(2, "What can I fetch?",
              """This page was built with API end-points in mind, albeit you can target any HTTP endpoint. It is recommended to use the API healthcheck endpoint."""),
          _faqExpansionPanel(3, "Will more providers be supported?",
              """The number of supported providers will increase over time.

Keep in mind that this page uses the free-tier to reduce costs, so if a Cloud provider do not have a free-tier then it will not be added in the near future."""),
          _faqExpansionPanel(4, "Are endpoints and results cached?",
              "No, but they will be soon.")
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

class APISearchBarWidget extends StatefulWidget {
  const APISearchBarWidget({Key? key}) : super(key: key);

  @override
  State<APISearchBarWidget> createState() => _APISearchBarWidgetState();
}

class _APISearchBarWidgetState extends State<APISearchBarWidget> {
  // Global key for the url input
  final _formKey = GlobalKey<FormState>();
  String? _fetchString;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Text(
              'Paste the API url and we will retrieve which providers can fetch from it.',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(
            height: 10,
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 600,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            "https://www.mycooldomain.com/api/healthcheck"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the API url to check';
                      }
                      String pattern =
                          r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
                      final regExp = RegExp(pattern);
                      if (!regExp.hasMatch(value)) {
                        return "Please enter a valid URL. Example: https://www.mycooldomain.com/api/healthcheck";
                      }

                      _fetchString = value;
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Provider.of<FetchStateNotifier>(context, listen: false)
                          .startLocalFetch(_fetchString!);
                    }
                  },
                  child: const Text('Check'),
                )
              ],
            ),
          ),
        ],
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

class APIFetchWidget extends StatefulWidget {
  const APIFetchWidget({super.key});

  @override
  State<APIFetchWidget> createState() => _APIFetchWidgetState();
}

class _APIFetchWidgetState extends State<APIFetchWidget> {
  APIWidgetsController? apisController;
  APIProvider? pp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    apisController ??=
        APIWidgetsController(Provider.of<FetchStateNotifier>(context));
  }

  @override
  void dispose() {
    apisController!.dispose();

    super.dispose();
  }

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            APIWidget(
              apiProvider: apisController!.getLocalAPIProvider(),
            ),
            if (currentSearchState.currentState ==
                FetchState.fetchingCloud) ...[
              Container(
                width: 100,
                height: 1,
                color: Colors.white,
              ),
              Column(
                children: apisController!
                    .getCloudAPIProviders()
                    .map((provider) => APIWidget(
                          apiProvider: provider,
                        ))
                    .toList(),
              )
            ]
          ],
        ),
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
