import 'dart:ui';

class DietModel{
  String name;
  String iconPath;
  String level;
  String time;
  String calorie;
  bool viewIsSelected;
  Color boxColor;
  DietModel(
      {
        required this.name,
        required this.iconPath,
        required this.level,
        required this.time,
        required this.calorie,
        required this.viewIsSelected,
        required this.boxColor
      });


 static List<DietModel> getDiets() {
  List <DietModel> diets = [];

  diets.add(
    DietModel(
    name: "Honey Pancake",
    iconPath: "assets/icons/honey-pancakes.svg",
    level: "Easy",
    time: "30 min",
    calorie: "180 kCal",
    viewIsSelected: true,
        boxColor: Color(0xffC58BF2)
  )
  );
  diets.add(
      DietModel(
        name: "Canai Breads",
        iconPath: "assets/icons/canai-bread.svg",
        level: "Easy",
        time: "20 min",
        calorie: "240 kCal",
        viewIsSelected: false,
          boxColor: Color(0xff92A3FD)
      )
  );
  return diets;

}
}