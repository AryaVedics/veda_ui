// Copy of Véda's template (flutter_app/lib/data/learn_content.dart). Keep in step.
// The Learn section's content: short, general notes about everyday skin habits
// and good-to-know facts, grouped by theme.
//
// Rules this content keeps (see test/learn_test.dart, which enforces them):
//   - Descriptive, never a prescription. The app measures; it does not treat,
//     diagnose or tell anyone what to do with their skin. Notes say what is
//     commonly known or commonly done ("many people", "many dermatologists
//     suggest"), never "you should".
//   - No brands, doses or supplements. Ingredients appear only as plain
//     definitions in their own theme, each with the KIND of product that
//     carries it ("found in many acne cleansers"), never a brand, a claim or
//     a recommendation.
//   - A source is named only where one clearly applies.
//   - Warm in tone, like the rest of the app.
//
// DRAFT: to be read by a clinician and by the lawyer before a store release.

import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum LearnCategory {
  sleep('Sleep and rest', PhosphorIconsThin.moon),
  sun('Sun and weather', PhosphorIconsThin.sun),
  water('Water and food', PhosphorIconsThin.drop),
  stress('Stress and mood', PhosphorIconsThin.heart),
  habits('Everyday habits', PhosphorIconsThin.hand),
  ingredients('Skin-care ingredients', PhosphorIconsThin.flask);

  const LearnCategory(this.title, this.icon);

  final String title;
  final IconData icon;
}

class LearnEntry {
  const LearnEntry({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    this.sources = const [],
  });

  /// Stable, never reused: a card or a link can point at it.
  final String id;
  final LearnCategory category;
  final String title;
  final String body;

  /// Where this comes from, when one source clearly stands behind it.
  final List<String> sources;
}

const _aad = 'American Academy of Dermatology Association';
const _who = 'World Health Organization, Global Solar UV Index';

const List<LearnEntry> kLearnEntries = [
  // ---- skin-care ingredients: definitions only, no product names
  LearnEntry(
    id: 'ingredient-retinol',
    category: LearnCategory.ingredients,
    title: 'Retinol',
    body:
        'A form of vitamin A used in skin-care products. Its strength and form '
        'vary from product to product. It is found in some night creams, serums '
        'and moisturisers. Retinoids are known to carry risks in '
        'pregnancy, and many guidelines advise speaking with a doctor before '
        'using them while pregnant or trying to conceive.',
  ),
  LearnEntry(
    id: 'ingredient-niacinamide',
    category: LearnCategory.ingredients,
    title: 'Niacinamide',
    body:
        'Another name for vitamin B3, a nutrient that is also used in some '
        'skin-care products. It is found in many serums, moisturisers and '
        'toners.',
  ),
  LearnEntry(
    id: 'ingredient-vitamin-c',
    category: LearnCategory.ingredients,
    title: 'Vitamin C (in skin care)',
    body:
        'Also called ascorbic acid. An ingredient used in some skin-care '
        'products, often in the form of L-ascorbic acid. It is found in many '
        'serums and some moisturisers.',
  ),
  LearnEntry(
    id: 'ingredient-hyaluronic-acid',
    category: LearnCategory.ingredients,
    title: 'Hyaluronic acid',
    body:
        'A molecule the body makes itself that holds a great deal of '
        'water. It is found in many serums, moisturisers and masks.',
  ),
  LearnEntry(
    id: 'ingredient-salicylic-acid',
    category: LearnCategory.ingredients,
    title: 'Salicylic acid',
    body:
        'A beta hydroxy acid, often shortened to BHA. It is found in many '
        'acne products, such as cleansers, toners and spot products, and '
        'in some exfoliating products.',
  ),
  LearnEntry(
    id: 'ingredient-alpha-hydroxy-acids',
    category: LearnCategory.ingredients,
    title: 'Glycolic acid and lactic acid',
    body:
        'Two of the alpha hydroxy acids, often shortened to AHAs. They are '
        'found in many exfoliating toners, serums and peels.',
  ),
  LearnEntry(
    id: 'ingredient-benzoyl-peroxide',
    category: LearnCategory.ingredients,
    title: 'Benzoyl peroxide',
    body:
        'A compound used in many acne products, such as washes, gels and '
        'spot products.',
  ),
  LearnEntry(
    id: 'ingredient-azelaic-acid',
    category: LearnCategory.ingredients,
    title: 'Azelaic acid',
    body:
        'An acid that occurs naturally in grains such as barley and wheat, '
        'and is also made in laboratories. It is found in some creams and '
        'gels made for blemish-prone skin.',
  ),
  LearnEntry(
    id: 'ingredient-tretinoin',
    category: LearnCategory.ingredients,
    title: 'Tretinoin',
    body:
        'A retinoid, a form of vitamin A, that is available on '
        'prescription. It is found in prescription creams and gels. Retinoids are known to '
        'carry risks in pregnancy, and many guidelines advise speaking '
        'with a doctor before using them while pregnant or trying to '
        'conceive.',
  ),
  LearnEntry(
    id: 'ingredient-bakuchiol',
    category: LearnCategory.ingredients,
    title: 'Bakuchiol',
    body:
        'An ingredient taken from the seeds of a plant, used in some '
        'serums and moisturisers.',
  ),
  LearnEntry(
    id: 'ingredient-ceramides',
    category: LearnCategory.ingredients,
    title: 'Ceramides',
    body:
        'Fats that occur naturally in the outer layer of skin. They are '
        'found in many moisturisers and cleansers.',
  ),
  LearnEntry(
    id: 'ingredient-peptides',
    category: LearnCategory.ingredients,
    title: 'Peptides',
    body:
        'Short chains of amino acids, the building blocks of proteins. '
        'They are found in some serums and moisturisers.',
  ),
  LearnEntry(
    id: 'ingredient-glycerin',
    category: LearnCategory.ingredients,
    title: 'Glycerin',
    body:
        'A common ingredient that attracts water. It is found in a very '
        'wide range of products, including cleansers, moisturisers and lip '
        'balms.',
  ),
  LearnEntry(
    id: 'ingredient-panthenol',
    category: LearnCategory.ingredients,
    title: 'Panthenol',
    body:
        'A form of vitamin B5. It is found in many moisturisers, lip balms '
        'and hair products.',
  ),
  LearnEntry(
    id: 'ingredient-squalane',
    category: LearnCategory.ingredients,
    title: 'Squalane',
    body:
        'A light oil, often made from olives or sugar cane. It is found in '
        'some moisturisers and facial oils.',
  ),
  LearnEntry(
    id: 'ingredient-petrolatum',
    category: LearnCategory.ingredients,
    title: 'Petrolatum',
    body:
        'A soft, jelly-like substance made from petroleum. It is found in '
        'many ointments, lip balms and moisturisers.',
  ),
  LearnEntry(
    id: 'ingredient-mineral-filters',
    category: LearnCategory.ingredients,
    title: 'Zinc oxide and titanium dioxide',
    body:
        'Two minerals used as sunscreen filters, often called the mineral '
        'filters. They are found in many sunscreens, and in some tinted '
        'moisturisers and makeup that list an SPF.',
  ),
  LearnEntry(
    id: 'ingredient-chemical-filters',
    category: LearnCategory.ingredients,
    title: 'Chemical sunscreen filters',
    body:
        'A group of ingredients, such as avobenzone and oxybenzone, that '
        'are used as filters in sunscreens. They are found in many '
        'sunscreens, and in some moisturisers and makeup that list an SPF.',
  ),
  LearnEntry(
    id: 'ingredient-fragrance',
    category: LearnCategory.ingredients,
    title: 'Fragrance',
    body:
        'On an ingredient list, fragrance (or parfum) is a general word '
        'for the scented parts of a product, and it can stand for many '
        'different ingredients. It is found in many cleansers, '
        'moisturisers and body products.',
  ),
  // ---- sleep and rest
  LearnEntry(
    id: 'sleep-repair',
    category: LearnCategory.sleep,
    title: 'Skin does a lot of its repair at night',
    body:
        'Skin renews itself most actively while you sleep, and blood flow to '
        'the skin tends to rise at night. That is one reason a run of short '
        'nights can leave skin looking tired.',
  ),
  LearnEntry(
    id: 'sleep-rhythm',
    category: LearnCategory.sleep,
    title: 'A steady bedtime counts as much as the hours',
    body:
        'Going to sleep and waking at similar times helps the body keep its '
        'daily rhythm, and skin follows the same rhythm: it loses a little more '
        'water overnight and restores itself on a schedule.',
  ),
  LearnEntry(
    id: 'sleep-pillowcase',
    category: LearnCategory.sleep,
    title: 'Pillowcases collect more than you might think',
    body:
        'Pillowcases pick up oil, sweat and hair products. Many people change '
        'them about once a week, and some find their skin feels fresher for it.',
  ),
  LearnEntry(
    id: 'sleep-one-night',
    category: LearnCategory.sleep,
    title: 'One rough night is just one data point',
    body:
        'A single short night rarely shows for long. If a reading dips after a '
        'poor night, that is a normal thing to see, and the trend over weeks '
        'is the better guide.',
  ),

  // ---- sun and weather
  LearnEntry(
    id: 'sun-cloud',
    category: LearnCategory.sun,
    title: 'UV reaches you on cloudy days',
    body:
        'A good share of ultraviolet light passes through cloud, which is why '
        'many dermatologists describe sun care as a year-round habit, not only '
        'a summer one. The UV index is a better guide than the temperature.',
    sources: [_aad],
  ),
  LearnEntry(
    id: 'sun-index',
    category: LearnCategory.sun,
    title: 'The UV index is a number worth knowing',
    body:
        'The UV index measures how strong the sun\'s ultraviolet light is, '
        'from 0 up past 11. Health agencies such as the World Health '
        'Organization advise sun protection whenever it reaches 3 or more.',
    sources: [_who],
  ),
  LearnEntry(
    id: 'sun-glass',
    category: LearnCategory.sun,
    title: 'Windows let some UV through',
    body:
        'Ordinary window glass blocks most UVB but lets a good part of UVA '
        'through, so a long drive or a seat by a sunny window still adds up '
        'over the years.',
    sources: [_aad],
  ),
  LearnEntry(
    id: 'sun-amount',
    category: LearnCategory.sun,
    title: 'Sun protection only works in the amount that is used',
    body:
        'Studies find that most people use much less sunscreen than it is '
        'tested at, so the number on the label is not what the skin actually '
        'gets. Many people also reapply every couple of hours when they are '
        'outdoors.',
    sources: [_aad],
  ),
  LearnEntry(
    id: 'sun-shade',
    category: LearnCategory.sun,
    title: 'Shade, hats and clothing count too',
    body:
        'Sun protection is not only sunscreen. Shade, a wide-brimmed hat, '
        'sunglasses and covering clothes all lower how much UV reaches the '
        'skin.',
    sources: [_aad],
  ),
  LearnEntry(
    id: 'sun-dry-air',
    category: LearnCategory.sun,
    title: 'Cold and dry air can leave skin feeling tight',
    body:
        'In cold or dry weather, and in heated rooms, skin tends to lose water '
        'faster and can feel tighter. Many people find a gentler touch with '
        'washing helps it feel comfortable.',
  ),
  LearnEntry(
    id: 'sun-humid',
    category: LearnCategory.sun,
    title: 'Warm, humid days change how skin looks',
    body:
        'Heat and humidity make skin oilier and sweatier for many people. That '
        'can change how texture and shine read in a photo, and it is one reason '
        'readings move with the seasons.',
  ),

  // ---- water and food
  LearnEntry(
    id: 'water-elasticity',
    category: LearnCategory.water,
    title: 'Hydration supports skin\'s elasticity',
    body:
        'Skin holds a lot of water, and being well hydrated supports its '
        'elasticity. It will not change texture overnight, though.',
  ),
  LearnEntry(
    id: 'water-loss',
    category: LearnCategory.water,
    title: 'Skin loses water to the air all day',
    body:
        'A little water escapes from skin all the time. Drinking enough keeps '
        'the body topped up, although research on drinking extra water for '
        'skin in particular is still modest.',
  ),
  LearnEntry(
    id: 'food-variety',
    category: LearnCategory.water,
    title: 'Variety on the plate',
    body:
        'Fruit and vegetables of many colours, whole grains and healthy fats '
        'are part of eating well in general, and researchers keep studying how '
        'diet and skin are linked.',
  ),
  LearnEntry(
    id: 'food-slow',
    category: LearnCategory.water,
    title: 'Skin changes slowly',
    body:
        'Skin renews itself over weeks, so a change in how you eat or drink is '
        'something to watch over weeks too, not days.',
  ),

  // ---- stress and mood
  LearnEntry(
    id: 'stress-delay',
    category: LearnCategory.stress,
    title: 'Stress can show on skin days later',
    body:
        'Stress does not always show in the moment. It can turn up on skin a '
        'few days afterwards, so patience with a rough patch is fair.',
  ),
  LearnEntry(
    id: 'stress-quiet',
    category: LearnCategory.stress,
    title: 'A few quiet minutes count',
    body:
        'Slow breathing, a short walk or time outdoors are everyday ways '
        'people ease stress, and many notice calmer days feel better all '
        'round.',
  ),
  LearnEntry(
    id: 'stress-talk',
    category: LearnCategory.stress,
    title: 'Mood and skin talk to each other',
    body:
        'Research suggests stress hormones can affect skin oil and irritation '
        'in some people. It is not about blame: some seasons are simply '
        'harder than others.',
  ),

  // ---- everyday habits
  LearnEntry(
    id: 'habit-gentle',
    category: LearnCategory.habits,
    title: 'Gentle beats scrubbing',
    body:
        'Many dermatologists suggest washing skin with lukewarm water and '
        'patting it dry, since very hot water and hard scrubbing can irritate.',
    sources: [_aad],
  ),
  LearnEntry(
    id: 'habit-hands',
    category: LearnCategory.habits,
    title: 'Hands off',
    body:
        'Dermatologists generally advise against picking or squeezing spots: '
        'it can spread oil and bacteria and may leave a mark that outlasts the '
        'spot itself.',
    sources: [_aad],
  ),
  LearnEntry(
    id: 'habit-things',
    category: LearnCategory.habits,
    title: 'What touches your face every day',
    body:
        'Phones, glasses, makeup brushes and towels all touch skin daily. Many '
        'people wipe or wash them regularly.',
  ),
  LearnEntry(
    id: 'habit-evening',
    category: LearnCategory.habits,
    title: 'Makeup off before sleep',
    body:
        'Many dermatologists suggest taking makeup off before going to sleep, '
        'so it does not sit on the skin overnight.',
    sources: [_aad],
  ),
  LearnEntry(
    id: 'habit-one-change',
    category: LearnCategory.habits,
    title: 'One new thing at a time',
    body:
        'When people try something new on their skin, many dermatologists '
        'suggest changing one thing at a time, so it is clear what agreed '
        'with them and what did not.',
    sources: [_aad],
  ),
];

/// The entries of one theme, in the order written.
List<LearnEntry> learnEntriesIn(LearnCategory category) => [
  for (final e in kLearnEntries)
    if (e.category == category) e,
];

/// The entry with this id, or null.
LearnEntry? learnEntry(String id) {
  for (final e in kLearnEntries) {
    if (e.id == id) return e;
  }
  return null;
}
