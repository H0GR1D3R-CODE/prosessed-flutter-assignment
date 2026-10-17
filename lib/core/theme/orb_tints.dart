import 'package:flutter/material.dart';

/// A pair of colours that lights an orb: a pale highlight and a deeper body.
@immutable
class OrbTint {
  const OrbTint({required this.light, required this.deep});

  final Color light;
  final Color deep;

  /// The same tint seen at night: darker and a little muted, so orbs glow instead of glare.
  OrbTint forBrightness(Brightness brightness) {
    if (brightness == Brightness.light) return this;
    return OrbTint(
      light: Color.lerp(deep, Colors.black, 0.18)!,
      deep: Color.lerp(deep, Colors.black, 0.62)!,
    );
  }
}

/// Every product sits on an orb. The orb's colour comes from its category, so a screen of
/// mixed products reads as a set of colour families instead of a wall of white cutouts.
abstract final class OrbTints {
  static const OrbTint peach = OrbTint(
    light: Color(0xFFFFD9C2),
    deep: Color(0xFFFF9D6E),
  );
  static const OrbTint mint = OrbTint(
    light: Color(0xFFC9F4DE),
    deep: Color(0xFF6FD6A4),
  );
  static const OrbTint lilac = OrbTint(
    light: Color(0xFFE3D9FF),
    deep: Color(0xFFA48FFF),
  );
  static const OrbTint butter = OrbTint(
    light: Color(0xFFFFEFB8),
    deep: Color(0xFFFFCF4D),
  );
  static const OrbTint sky = OrbTint(
    light: Color(0xFFCDE9FF),
    deep: Color(0xFF72B9FF),
  );
  static const OrbTint rose = OrbTint(
    light: Color(0xFFFFD0DF),
    deep: Color(0xFFFF8CAD),
  );
  static const OrbTint sage = OrbTint(
    light: Color(0xFFDDEBC6),
    deep: Color(0xFFA3CB72),
  );
  static const OrbTint clay = OrbTint(
    light: Color(0xFFEFDACB),
    deep: Color(0xFFCFA283),
  );

  static const List<OrbTint> _all = [
    peach,
    mint,
    lilac,
    butter,
    sky,
    rose,
    sage,
    clay,
  ];

  static const Map<String, OrbTint> _byCategory = {
    'beauty': rose,
    'fragrances': lilac,
    'furniture': clay,
    'groceries': sage,
    'home-decoration': butter,
    'kitchen-accessories': mint,
    'laptops': sky,
    'mens-shirts': peach,
    'mens-shoes': clay,
    'mens-watches': lilac,
    'mobile-accessories': mint,
    'motorcycle': butter,
    'skin-care': rose,
    'smartphones': sky,
    'sports-accessories': sage,
    'sunglasses': peach,
    'tablets': lilac,
    'tops': rose,
    'vehicle': sky,
    'womens-bags': butter,
    'womens-dresses': peach,
    'womens-jewellery': lilac,
    'womens-shoes': mint,
    'womens-watches': clay,
  };

  /// The tint for a category slug. Unknown slugs get a stable colour from their characters.
  static OrbTint forCategory(String? slug) {
    if (slug == null || slug.isEmpty) return peach;
    final known = _byCategory[slug];
    if (known != null) return known;
    final sum = slug.codeUnits.fold<int>(0, (total, unit) => total + unit);
    return _all[sum % _all.length];
  }
}

/// An icon for each category chip. Anything unknown falls back to a generic bag.
abstract final class CategoryIcons {
  static const Map<String, IconData> _icons = {
    'beauty': Icons.face_retouching_natural_rounded,
    'fragrances': Icons.water_drop_rounded,
    'furniture': Icons.chair_rounded,
    'groceries': Icons.local_grocery_store_rounded,
    'home-decoration': Icons.filter_vintage_rounded,
    'kitchen-accessories': Icons.soup_kitchen_rounded,
    'laptops': Icons.laptop_mac_rounded,
    'mens-shirts': Icons.checkroom_rounded,
    'mens-shoes': Icons.hiking_rounded,
    'mens-watches': Icons.watch_rounded,
    'mobile-accessories': Icons.headphones_rounded,
    'motorcycle': Icons.two_wheeler_rounded,
    'skin-care': Icons.spa_rounded,
    'smartphones': Icons.smartphone_rounded,
    'sports-accessories': Icons.sports_cricket_rounded,
    'sunglasses': Icons.visibility_rounded,
    'tablets': Icons.tablet_mac_rounded,
    'tops': Icons.dry_cleaning_rounded,
    'vehicle': Icons.directions_car_rounded,
    'womens-bags': Icons.shopping_bag_rounded,
    'womens-dresses': Icons.checkroom_rounded,
    'womens-jewellery': Icons.diamond_rounded,
    'womens-shoes': Icons.hiking_rounded,
    'womens-watches': Icons.watch_later_rounded,
  };

  static IconData of(String slug) => _icons[slug] ?? Icons.category_rounded;
}
