import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pigpen_iot/custom/app_circularprogressindicator.dart';
import 'package:unicons/unicons.dart';

class AppCachedNetworkImage extends StatelessWidget {
  final String? graphicUrl;
  final BoxFit boxFit;
  final Duration? fadeOutDuration, fadeInDuration;
  final int? memCacheHeight, memCacheWidth;
  final Widget Function(BuildContext, String?)? placeholder;

  /// Cached network image so that you don't have to.
  ///
  /// * [graphicUrl] is nullable because at it can handle null url at `runtime`,
  ///  but will `assert` you in debug mode just in case you've forgotten
  /// to provide a url.
  /// * [placeholder] is the widget displayed while the image is `loading`,
  /// by default it uses the customed [AppCircularProgressIndicator].
  /// * provide [memCacheHeight] and [memCacheWidth] as much as possible,
  ///  these are the explicit `height` and `width` so that the image and will
  /// use only the memory it needs when rendered.
  const AppCachedNetworkImage(
    this.graphicUrl, {
    super.key,
    this.boxFit = BoxFit.contain,
    this.fadeOutDuration,
    this.fadeInDuration,
    this.memCacheHeight,
    this.memCacheWidth,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: graphicUrl ?? 'Invalid url',
      fit: boxFit,
      placeholder:
          placeholder ?? (context, url) => const AppCircularProgressIndicator(),
      fadeOutDuration: fadeOutDuration ?? const Duration(seconds: 0),
      fadeInDuration: fadeInDuration ?? const Duration(seconds: 0),
      memCacheHeight: memCacheHeight,
      memCacheWidth: memCacheWidth,
      errorWidget: (_, __, ___) =>
          const Icon(UniconsLine.image_question, color: Colors.grey),
    );
  }
}
