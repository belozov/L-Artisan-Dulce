import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple/models/category_model.dart';
import 'package:simple/models/diet_model.dart';
import '../models/popular_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<CategoryModel> categories;
  late final List<DietModel> diets;
  late final List<PopularDietModel> popularDiets;

  @override
  void initState() {
    super.initState();
    categories = CategoryModel.getCategory();
    diets = DietModel.getDiets();
    popularDiets = PopularDietModel.getPopularDiets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SearchField()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          SliverToBoxAdapter(
            child: CategoriesSection(categories: categories),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          SliverToBoxAdapter(
            child: DietSection(diets: diets),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          PopularDietSection(popularDiets: popularDiets),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Breakfast',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffF7F8F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: () {},
          icon: SvgPicture.asset('assets/icons/Arrow - Left 2.svg'),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(10),
          width: 37,
          decoration: BoxDecoration(
            color: const Color(0xffF7F8F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('assets/icons/dots.svg'),
          ),
        ),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 40,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
          hintText: 'Search Pancake',
          hintStyle: const TextStyle(
            color: Color(0xffDDDADA),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset('assets/icons/Search.svg'),
          ),
          suffixIcon: SizedBox(
            width: 100,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const VerticalDivider(
                    color: Colors.black,
                    indent: 10,
                    endIndent: 10,
                    thickness: 0.1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset('assets/icons/Filter.svg'),
                  ),
                ],
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({
    super.key,
    required this.categories,
  });

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Category',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.separated(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            separatorBuilder: (_, __) => const SizedBox(width: 25),
            itemBuilder: (context, index) {
              final category = categories[index];

              return CategoryCard(category: category);
            },
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: category.boxColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 50,
            width: 50,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(category.iconPath),
          ),
          Text(
            category.name,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class DietSection extends StatelessWidget {
  const DietSection({
    super.key,
    required this.diets,
  });

  final List<DietModel> diets;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Recommendation \nfor Diet',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 240,
          child: ListView.separated(
            itemCount: diets.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            separatorBuilder: (_, __) => const SizedBox(width: 25),
            itemBuilder: (context, index) {
              final diet = diets[index];

              return DietCard(diet: diet);
            },
          ),
        ),
      ],
    );
  }
}

class DietCard extends StatelessWidget {
  const DietCard({
    super.key,
    required this.diet,
  });

  final DietModel diet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 240,
      decoration: BoxDecoration(
        color: diet.boxColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SvgPicture.asset(diet.iconPath),
          Column(
            children: [
              Text(
                diet.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Text(
                '${diet.level} | ${diet.time} | ${diet.calorie}',
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color(0xff7B6F72),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {},
            child: Ink(
              height: 45,
              width: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    diet.viewIsSelected
                        ? const Color(0xff9DCEFF)
                        : Colors.transparent,
                    diet.viewIsSelected
                        ? const Color(0xff92A3FD)
                        : Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  'View',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: diet.viewIsSelected
                        ? Colors.white
                        : const Color(0xffC58BF2),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PopularDietSection extends StatelessWidget {
  const PopularDietSection({
    super.key,
    required this.popularDiets,
  });

  final List<PopularDietModel> popularDiets;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Popular',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 15)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: popularDiets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 25),
            itemBuilder: (context, index) {
              final popularDiet = popularDiets[index];

              return PopularDietCard(popularDiet: popularDiet);
            },
          ),
        ),
      ],
    );
  }
}

class PopularDietCard extends StatelessWidget {
  const PopularDietCard({
    super.key,
    required this.popularDiet,
  });

  final PopularDietModel popularDiet;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: popularDiet.boxIsSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: popularDiet.boxIsSelected
            ? [
          BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.07),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ]
            : const [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SvgPicture.asset(
            popularDiet.iconPath,
            height: 65,
            width: 65,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                popularDiet.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Text(
                '${popularDiet.level} | ${popularDiet.duration}',
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color(0xff7B6F72),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/Button.svg',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}