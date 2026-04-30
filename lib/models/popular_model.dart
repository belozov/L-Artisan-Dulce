class PopularDietModel {
  String name;
  String iconPath;
  String level;
  String duration;
  String calorie;
  bool boxIsSelected;

  PopularDietModel({
    required this.name,
    required this.iconPath,
    required this.level,
    required this.duration,
    required this.calorie,
    required this.boxIsSelected
});

  static List <PopularDietModel> getPopularDiets(){
    List<PopularDietModel> popularDiets = [];

    popularDiets.add(
      PopularDietModel(
        name: 'Blueberry Pancake',
        iconPath: 'assets/icons/blueberry-pancake.svg',
        level: 'Medium',
        duration: "30 mins",
        calorie: "230 kcal",
        boxIsSelected: true
      )
    );

    popularDiets.add(
        PopularDietModel(
            name: 'Salmon nigiri',
            iconPath: 'assets/icons/Salmon-nigiri.svg',
            level: 'Medium',
            duration: "20 mins",
            calorie: "190 kcal",
            boxIsSelected: true
        )
    );


      return popularDiets;

  }
}