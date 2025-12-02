import 'package:flutter/material.dart';

/// 행운 아이템 카테고리 모델
class CategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final String description;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}
