// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget imageNetwork(
    {String? imageUrl,
    BoxFit? fit = BoxFit.cover,
    BorderRadius? borderRadius}) {
  return CachedNetworkImage(
    imageUrl: imageUrl ?? "",
    imageBuilder: (context, imageProvider) => Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        image: DecorationImage(image: imageProvider, fit: fit),
      ),
    ),
    placeholder: (context, url) => Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'assets/icons/loading.gif',
        width: 50,
        height: 50,
      ),
    ),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
}
