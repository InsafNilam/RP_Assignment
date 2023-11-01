import 'package:animate_do/animate_do.dart';
import 'package:chat_application/common/widgets/loader.dart';
import 'package:chat_application/features/auth/controller/auth_controller.dart';
import 'package:chat_application/features/news/services/api_service.dart';
import 'package:chat_application/features/news/widgets/custom_news_tile.dart';
import 'package:chat_application/models/article_model.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:easy_search_bar/easy_search_bar.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  late TextEditingController searchQueryController;
  final List<String> categories = [
    'General',
    'Entertainment',
    'Health',
    'Sports',
    'Business',
    'Technology',
  ];
  String searchValue = 'General';
  String serachQuery = 'General';

  @override
  void initState() {
    super.initState();
    searchQueryController = TextEditingController();
  }

  Future<List<Article>?> info({String query = "General"}) async {
    ApiService client = ApiService();
    List<Article>? data = await client.getArticle(query);
    // Map<String, dynamic> data = {
    //   "status": "ok",
    //   "totalResults": 66,
    //   "articles": [
    //     {
    //       "source": {"id": "bloomberg", "name": "Bloomberg"},
    //       "author": "Iris Ouyang",
    //       "title":
    //           "PBOC Offers Most Cash Support Since 2020 as Debt Sales Surge - Bloomberg",
    //       "description": "",
    //       "url":
    //           "https://www.bloomberg.com/news/articles/2023-10-16/pboc-ramps-up-liquidity-support-to-boost-china-economic-recovery",
    //       "urlToImage":
    //           "https://assets.bwbx.io/images/users/iqjWHBFdfxIU/iEu7aMMk1c2w/v0/1200x774.jpg",
    //       "publishedAt": "2023-10-16T04:30:00Z",
    //       "content":
    //           "Chinas central bank is making the biggest medium-term liquidity injection since 2020, stepping up efforts to support the nations economic recovery and debt sales. \r\nThe Peoples Bank of China added a … [+233 chars]"
    //     },
    //     {
    //       "source": {"id": "reuters", "name": "Reuters"},
    //       "author": "Yuka Obayashi, Emily Chow",
    //       "title":
    //           "Oil prices flat as investors assess risks of Israel-Hamas war - Reuters",
    //       "description":
    //           "Oil traded mostly flat on Monday after surging last week as investors wait to see if the Israel-Hamas conflict draws in other countries - a development that would potentially drive up prices further and deal a fresh blow to the global economy.",
    //       "url":
    //           "https://www.reuters.com/markets/commodities/oil-prices-ease-investors-assess-impact-israel-hamas-war-2023-10-15/",
    //       "urlToImage":
    //           "https://www.reuters.com/resizer/SIP679oL512h2rbEeff_CG9G8SY=/1200x628/smart/filters:quality(80)/cloudfront-us-east-2.images.arcpublishing.com/reuters/B6ZNIOAF5ZP7BG4JTJVX2A237Q.jpg",
    //       "publishedAt": "2023-10-16T04:22:00Z",
    //       "content":
    //           "TOKYO, Oct 16 (Reuters) - Oil traded mostly flat on Monday after surging last week as investors wait to see if the Israel-Hamas conflict draws in other countries - a development that would potentiall… [+3323 chars]"
    //     },
    //   ]
    // };

    // List<dynamic> body = data['articles'];
    // List<Article> articles = await Future.wait(
    //   body.map((dynamic item) async => Article.fromJson(item)).toList(),
    // );
    // return articles;
    return data;
  }

  Future<List<String>> _fetchSuggestions(String searchValue) async {
    final speech = await ref.watch(authControllerProvider).getSpeechDataList();
    // Get the suggestions from the firebase.
    final suggestions = speech.where((element) {
      return element.toLowerCase().contains(searchValue.toLowerCase());
    }).toList();

    // Create a new list to store the suggestions with the new value added to the front.
    final newSuggestions = [
      searchValue,
    ];

    newSuggestions.addAll(suggestions);
    return newSuggestions;
  }

  @override
  void dispose() {
    super.dispose();
    searchQueryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EasySearchBar(
        title: BounceInDown(child: const Text('News')),
        backgroundColor: const Color(0XFF0a9f82),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
        asyncSuggestions: (value) async => await _fetchSuggestions(
          value,
        ),
        searchCursorColor: Colors.grey.shade400,
        searchBackIconTheme: const IconThemeData(color: Colors.white),
        searchClearIconTheme: const IconThemeData(color: Colors.white),
        searchHintStyle: TextStyle(color: Colors.grey.shade400),
        searchHintText: 'Search',
        openOverlayOnSearch: true,
        searchBackgroundColor: const Color(0XFF0A2E36),
        searchTextStyle: const TextStyle(color: Colors.white),
        onSearch: (String value) {},
        suggestionBackgroundColor: Colors.white,
        searchTextKeyboardType: TextInputType.text,
        suggestionBuilder: (data) {
          if (data.isNotEmpty) {
            return Container(
              height: 40,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                      ),
                      child: Text(
                        data,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
        onSuggestionTap: (data) => {
          setState(() {
            serachQuery = data;
          })
        },
      ),
      body: FutureBuilder<List<Article>?>(
        future: info(query: serachQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          } else if (snapshot.hasData) {
            List<Article>? articles = snapshot.data;
            return ZoomIn(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0)
                        .copyWith(left: 15.0, bottom: 0, top: 12.0),
                    child: const Text(
                      "Topics",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0).copyWith(top: 10),
                    child: CustomRadioButton(
                      elevation: 0,
                      absoluteZeroSpacing: false,
                      unSelectedColor: Theme.of(context).canvasColor,
                      buttonLables: categories,
                      buttonValues: categories,
                      buttonTextStyle: const ButtonTextStyle(
                          selectedColor: Colors.white,
                          unSelectedColor: Colors.black,
                          textStyle: TextStyle(fontSize: 16)),
                      radioButtonValue: (value) {
                        searchValue = value;
                        serachQuery = value;
                        setState(() {});
                      },
                      enableShape: true,
                      height: 45,
                      radius: 25,
                      selectedBorderColor: Colors.purple,
                      autoWidth: true,
                      defaultSelected: searchValue,
                      selectedColor: Colors.blue,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0)
                        .copyWith(left: 15.0, top: 0, bottom: 0),
                    child: const Text(
                      "Filter News",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0)
                        .copyWith(left: 13.0, right: 13.0),
                    child: TextFormField(
                      controller: searchQueryController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: false,
                        isDense: true,
                        hintText: 'Search',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.grey.shade400),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (searchQueryController.text.isNotEmpty) {
                              setState(() {
                                searchQueryController.text = '';
                              });
                            }
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.purple,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (String? value) {
                        if (value!.isEmpty) {
                          setState(() {});
                        }
                      },
                      onFieldSubmitted: (value) {
                        if (searchQueryController.text.isNotEmpty) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: articles!.length,
                      itemBuilder: (context, index) {
                        if (searchQueryController.text.isEmpty) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            child: SlideAnimation(
                              child: FadeInAnimation(
                                child: customNewsTile(
                                  articles[index],
                                  context,
                                ),
                              ),
                            ),
                          );
                        } else if (articles[index]
                            .title!
                            .toLowerCase()
                            .contains(
                                searchQueryController.text.toLowerCase())) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            child: SlideAnimation(
                              child: FadeInAnimation(
                                child: customNewsTile(
                                  articles[index],
                                  context,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("No Data"));
        },
      ),
    );
  }
}
