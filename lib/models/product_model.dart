class Product {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final double price;
  final String priceUnit;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String category;
  final List<String> moods;
  final List<Ingredient> ingredients;
  final Map<String, String> nutrition;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    this.subtitle = '',
    this.description = '',
    required this.price,
    this.priceUnit = 'per piece',
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.category = '',
    this.moods = const [],
    this.ingredients = const [],
    this.nutrition = const {},
    this.isFavorite = false,
  });
}

class Ingredient {
  final String name;
  final String quality;
  const Ingredient({required this.name, required this.quality});
}

class ProductCategory {
  final String name;
  final String imageUrl;
  const ProductCategory({required this.name, required this.imageUrl});
}

class MoodOption {
  final String label;
  final String emoji;
  const MoodOption({required this.label, required this.emoji});
}

// ── Sample Data ──

const kMoods = [
  MoodOption(label: 'Feeling Fancy', emoji: '✨'),
  MoodOption(label: 'Need a Boost', emoji: '⚡'),
];

const kCategories = [
  ProductCategory(
    name: 'Chocolates',
    imageUrl: 'https://images.unsplash.com/photo-1481391319762-47dff72954d9?w=400&h=400&fit=crop',
  ),
  ProductCategory(
    name: 'Pastries',
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
  ),
  ProductCategory(
    name: 'Tarts',
    imageUrl: 'https://images.unsplash.com/photo-1519915028121-7d3463d20b13?w=400&h=400&fit=crop',
  ),
  ProductCategory(
    name: 'Macarons',
    imageUrl: 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=400&h=400&fit=crop',
  ),
];

final kPopularDesserts = [
  Product(
    id: 'p1',
    name: 'Raspberry Velvet',
    subtitle: 'Soft sponge with fresh...',
    description: 'Crafted with French almond flour and house-made raspberry jam, our signature macaron offers a delicate crunch followed by a velvety, tart center.',
    price: 12.50,
    imageUrl: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&h=400&fit=crop',
    rating: 4.9,
    reviewCount: 128,
    category: 'Pastries',
    moods: ['Feeling Fancy'],
    ingredients: [
      Ingredient(name: 'Almond Flour', quality: 'Extra Fine'),
      Ingredient(name: 'Fresh Raspberries', quality: 'Organic'),
      Ingredient(name: 'Egg Whites', quality: 'Free Range'),
      Ingredient(name: 'Pure Cane Sugar', quality: 'Refined'),
    ],
    nutrition: {'CALORIES': '95', 'NET FAT': '4g', 'SUGARS': '12g', 'PROTEIN': '2g'},
  ),
  Product(
    id: 'p2',
    name: 'Midnight Ganache',
    subtitle: '70% single-origin dark...',
    description: 'A rich, decadent dark chocolate ganache cake made with 70% single-origin cacao from Ecuador.',
    price: 14.00,
    imageUrl: 'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?w=400&h=400&fit=crop',
    rating: 4.8,
    reviewCount: 96,
    category: 'Chocolates',
    moods: ['Need a Boost'],
    ingredients: [
      Ingredient(name: 'Dark Chocolate', quality: '70% Cacao'),
      Ingredient(name: 'Heavy Cream', quality: 'Organic'),
      Ingredient(name: 'Butter', quality: 'French'),
      Ingredient(name: 'Vanilla', quality: 'Madagascar'),
    ],
    nutrition: {'CALORIES': '180', 'NET FAT': '12g', 'SUGARS': '18g', 'PROTEIN': '3g'},
  ),
  Product(
    id: 'p3',
    name: 'Emerald Éclair',
    subtitle: 'Light pastry filled with...',
    description: 'A delicate choux pastry filled with pistachio cream and topped with a glossy green glaze.',
    price: 9.50,
    imageUrl: 'https://thumbs.dreamstime.com/b/none-428115293.jpg',
    rating: 4.7,
    reviewCount: 74,
    category: 'Eclairs',
    moods: ['Feeling Fancy'],
    ingredients: [
      Ingredient(name: 'Pistachio Paste', quality: 'Sicilian'),
      Ingredient(name: 'Choux Pastry', quality: 'House-made'),
      Ingredient(name: 'White Chocolate', quality: 'Belgian'),
    ],
    nutrition: {'CALORIES': '145', 'NET FAT': '8g', 'SUGARS': '14g', 'PROTEIN': '4g'},
  ),
];

final kExploreProducts = [
  Product(
    id: 'e1',
    name: 'Pistachio Royale',
    subtitle: 'Artisanal Macaron',
    price: 4.50,
    imageUrl: 'https://images.unsplash.com/photo-1558326567-98ae2405596b?w=400&h=400&fit=crop',
    rating: 4.9,
    reviewCount: 128,
    category: 'Macarons',
    moods: ['Feeling Fancy'],
    description: 'Crafted with French almond flour and house-made raspberry jam, our signature macaron offers a delicate crunch followed by a velvety, tart center.',
    ingredients: [
      Ingredient(name: 'Almond Flour', quality: 'Extra Fine'),
      Ingredient(name: 'Fresh Raspberries', quality: 'Organic'),
      Ingredient(name: 'Egg Whites', quality: 'Free Range'),
      Ingredient(name: 'Pure Cane Sugar', quality: 'Refined'),
    ],
    nutrition: {'CALORIES': '95', 'NET FAT': '4g', 'SUGARS': '12g', 'PROTEIN': '2g'},
  ),
  Product(
    id: 'e2',
    name: 'Signature Croissant',
    subtitle: 'Twice-Baked Almond',
    price: 6.75,
    imageUrl: 'https://images.unsplash.com/photo-1530610476181-d83430b64dcd?w=400&h=400&fit=crop',
    rating: 4.8,
    reviewCount: 203,
    category: 'Croissants',
    moods: ['Need a Boost'],
    description: 'Our signature twice-baked almond croissant is filled with frangipane cream and topped with sliced almonds.',
    ingredients: [
      Ingredient(name: 'French Butter', quality: 'AOP Certified'),
      Ingredient(name: 'Almond Cream', quality: 'House-made'),
      Ingredient(name: 'Flour', quality: 'Type 55'),
    ],
    nutrition: {'CALORIES': '320', 'NET FAT': '18g', 'SUGARS': '15g', 'PROTEIN': '7g'},
  ),
  Product(
    id: 'e3',
    name: 'Jeweled Berry Tart',
    subtitle: 'Fresh Seasonal Berries',
    price: 8.25,
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=400&fit=crop',
    rating: 4.7,
    reviewCount: 89,
    category: 'Tarts',
    moods: ['Feeling Fancy'],
    description: 'A buttery tart shell filled with vanilla pastry cream and crowned with seasonal berries.',
    ingredients: [
      Ingredient(name: 'Mixed Berries', quality: 'Seasonal'),
      Ingredient(name: 'Vanilla Bean', quality: 'Tahitian'),
      Ingredient(name: 'Butter', quality: 'European Style'),
    ],
    nutrition: {'CALORIES': '210', 'NET FAT': '10g', 'SUGARS': '16g', 'PROTEIN': '3g'},
  ),
  Product(
    id: 'e4',
    name: 'Valrhona Eclair',
    subtitle: '70% Dark Chocolate',
    price: 5.50,
    imageUrl: 'https://res.cloudinary.com/valrhona/image/upload/c_limit,f_auto,fl_progressive,h_850,q_auto,w_850/dam/696526b563cb244',
    rating: 4.6,
    reviewCount: 112,
    category: 'Eclairs',
    moods: ['Need a Boost'],
    description: 'Filled with Valrhona dark chocolate pastry cream, glazed with a mirror-finish chocolate ganache.',
    ingredients: [
      Ingredient(name: 'Valrhona Chocolate', quality: '70% Cacao'),
      Ingredient(name: 'Choux Pastry', quality: 'House-made'),
      Ingredient(name: 'Heavy Cream', quality: 'Organic'),
    ],
    nutrition: {'CALORIES': '195', 'NET FAT': '11g', 'SUGARS': '17g', 'PROTEIN': '4g'},
  ),
  Product(
    id: 'e5',
    name: 'Velvet Truffles',
    subtitle: 'Belgian Chocolate Box',
    price: 18.00,
    priceUnit: 'box of 6',
    imageUrl: 'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=400&h=400&fit=crop',
    rating: 4.9,
    reviewCount: 156,
    category: 'Chocolates',
    moods: ['Feeling Fancy', 'Need a Boost'],
    description: 'Six handcrafted truffles made with premium Belgian couverture chocolate.',
    ingredients: [
      Ingredient(name: 'Belgian Chocolate', quality: 'Couverture'),
      Ingredient(name: 'Heavy Cream', quality: 'Organic'),
      Ingredient(name: 'Cocoa Powder', quality: 'Dutch Process'),
    ],
    nutrition: {'CALORIES': '120', 'NET FAT': '9g', 'SUGARS': '10g', 'PROTEIN': '2g'},
  ),
  Product(
    id: 'e6',
    name: 'Rose Petal Macaron',
    subtitle: 'Delicate Floral Notes',
    price: 4.75,
    imageUrl: 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=400&h=400&fit=crop',
    rating: 4.8,
    reviewCount: 95,
    category: 'Macarons',
    moods: ['Feeling Fancy'],
    description: 'A rose-infused ganache macaron with delicate floral notes and a smooth finish.',
    ingredients: [
      Ingredient(name: 'Almond Flour', quality: 'Extra Fine'),
      Ingredient(name: 'Rose Water', quality: 'Persian'),
      Ingredient(name: 'White Chocolate', quality: 'Belgian'),
    ],
    nutrition: {'CALORIES': '90', 'NET FAT': '4g', 'SUGARS': '11g', 'PROTEIN': '2g'},
  ),
  Product(
    id: 'e7',
    name: 'Butter Croissant',
    subtitle: 'Classic French Style',
    price: 4.25,
    imageUrl: 'https://www.cookwithkushi.com/wp-content/uploads/2021/09/IMG_0243l.jpg ',
    rating: 4.7,
    reviewCount: 310,
    category: 'Croissants',
    moods: ['Need a Boost'],
    description: 'Our classic butter croissant — 48-hour fermented dough with 82% fat AOP butter.',
    ingredients: [
      Ingredient(name: 'French Butter', quality: '82% AOP'),
      Ingredient(name: 'Flour', quality: 'Type 55'),
      Ingredient(name: 'Salt', quality: 'Guérande'),
    ],
    nutrition: {'CALORIES': '260', 'NET FAT': '14g', 'SUGARS': '6g', 'PROTEIN': '5g'},
  ),
  Product(
    id: 'e8',
    name: 'Lemon Tart',
    subtitle: 'Tangy Citrus Curd',
    price: 7.50,
    imageUrl: 'https://images.unsplash.com/photo-1519915028121-7d3463d20b13?w=400&h=400&fit=crop',
    rating: 4.6,
    reviewCount: 78,
    category: 'Tarts',
    moods: ['Need a Boost'],
    description: 'A crisp pâte sucrée shell filled with silky lemon curd and torched Italian meringue.',
    ingredients: [
      Ingredient(name: 'Meyer Lemons', quality: 'Organic'),
      Ingredient(name: 'Butter', quality: 'French'),
      Ingredient(name: 'Eggs', quality: 'Free Range'),
    ],
    nutrition: {'CALORIES': '240', 'NET FAT': '12g', 'SUGARS': '20g', 'PROTEIN': '3g'},
  ),
];

/// Filter chip labels — index 0 is always "Show All"
const kFilterChips = ['All', 'Macarons', 'Croissants', 'Tarts', 'Eclairs', 'Chocolates'];
