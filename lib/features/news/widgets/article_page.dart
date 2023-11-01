import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlePage extends StatelessWidget {
  final Article article;
  const ArticlePage({Key? key, required this.article}) : super(key: key);

  Future<void> _launchURL(String url) async {
    Uri websiteURI = Uri.parse(url);
    if (await canLaunchUrl(websiteURI)) {
      await launchUrl(
        websiteURI,
        mode: LaunchMode.inAppWebView,
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title!),
        titleSpacing: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ZoomIn(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: article.urlToImage ??
                        'https://i.ibb.co/w43qJxs/360-F-473254957-bx-G9yf4ly7-OBO5-I0-O5-KABl-N930-Gwa-MQz.jpg',
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              SlideInLeft(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    article.name!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              BounceInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 15.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: article.description != ""
                      ? RichText(
                          text: TextSpan(
                            children: [
                              // Title
                              TextSpan(
                                text: '${article.title}\n\n',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              // Description
                              TextSpan(
                                text: article.description!,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.justify,
                        )
                      : RichText(
                          text: TextSpan(
                            children: [
                              // Title
                              TextSpan(
                                text: '${article.title}\n\n',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              // Description
                              const TextSpan(
                                text: 'Description: None',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              SlideInRight(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => _launchURL(article.url!),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Text(
                          'More >>',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
