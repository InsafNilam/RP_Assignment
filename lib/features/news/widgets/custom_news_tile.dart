import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/features/news/widgets/article_page.dart';
import 'package:chat_application/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget customNewsTile(Article article, BuildContext context) {
  return InkWell(
    onTap: () {
      Get.to(
        () => ArticlePage(article: article),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    },
    child: Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          color: const Color(0xFFc29c4d),
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3.0,
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: CachedNetworkImage(
              fit: BoxFit.fill,
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
          const SizedBox(
            height: 8.0,
          ),
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              article.name!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              article.title!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
