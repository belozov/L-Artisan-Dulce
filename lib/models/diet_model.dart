import 'package:flutter/material.dart';

class DietModel {
  String name;
  String iconPath;
  String level;
  String time;
  String calorie;
  Color boxColor;
  bool viewIsSelected;

  DietModel({
    required this.name,
    required this.iconPath,
    required this.level,
    required this.time,
    required this.calorie,
    required this.boxColor,
    required this.viewIsSelected,
  });

  static List<DietModel> getDiets() {
    List<DietModel> diets = [];

    diets.add(DietModel(
        name: 'Honey Pancake',
        iconPath: 'assets/icons/honey-pancakes.svg',
        level: 'Easy',
        time: '30mins',
        calorie: '180kCal',
        boxColor: const Color(0xff9DCEFF),
        viewIsSelected: true));

    diets.add(DietModel(
        name: 'Canapa Bread',
        iconPath: 'assets/icons/canapa-bread.svg',
        level: 'Easy',
        time: '20mins',
        calorie: '230kCal',
        boxColor: const Color(0xffEEA4CE),
        viewIsSelected: false));

    return diets;
  }
}
