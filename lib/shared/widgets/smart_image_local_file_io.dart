import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture buildLocalSvgPicture({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  WidgetBuilder? placeholderBuilder,
  SvgErrorWidgetBuilder? errorBuilder,
  ColorFilter? colorFilter,
}) {
  return SvgPicture.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    colorFilter: colorFilter,
    placeholderBuilder: placeholderBuilder,
    errorBuilder: errorBuilder,
  );
}

Widget buildLocalRasterImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Color? color,
  BlendMode? colorBlendMode,
  int? cacheWidth,
  int? cacheHeight,
  required ImageErrorWidgetBuilder errorBuilder,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    color: color,
    colorBlendMode: colorBlendMode,
    cacheWidth: cacheWidth,
    cacheHeight: cacheHeight,
    errorBuilder: errorBuilder,
  );
}
