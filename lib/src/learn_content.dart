// Copy of Véda's template (flutter_app/lib/data/learn_content.dart). Keep in step.
//
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
//   - Eleven themes in three groups; a theme needs at least three notes.
//
// DRAFT: to be read by a clinician and by the lawyer before a store release.

import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// The three parts of the portal: what themes sit together on its front page.
enum LearnGroup {
  skin('Your skin'),
  everyday('Everyday life'),
  products('Products and labels'),
  food('Food and nutrition');

  const LearnGroup(this.title);

  final String title;
}

/// A theme: a page of its own in the portal. Themes show in the order they are
/// written here, under their group.
enum LearnCategory {
  skinBasics(
    'Skin basics',
    'What skin is made of and how it works.',
    LearnGroup.skin,
    PhosphorIconsThin.fingerprint,
  ),
  readings(
    'Your readings',
    'Why readings move, and how to keep them comparable.',
    LearnGroup.skin,
    PhosphorIconsThin.camera,
  ),
  lifeStages(
    'Through the years',
    'How skin changes from the teens to later life.',
    LearnGroup.skin,
    PhosphorIconsThin.hourglass,
  ),
  sleep(
    'Sleep and rest',
    'Rest, rhythm and how skin renews overnight.',
    LearnGroup.everyday,
    PhosphorIconsThin.moon,
  ),
  sun(
    'Sun and weather',
    'UV, the seasons and the air around you.',
    LearnGroup.everyday,
    PhosphorIconsThin.sun,
  ),
  water(
    'Water and food',
    'Water, food and how slowly skin changes.',
    LearnGroup.everyday,
    PhosphorIconsThin.drop,
  ),
  stress(
    'Stress and mood',
    'How mood and skin talk to each other.',
    LearnGroup.everyday,
    PhosphorIconsThin.heart,
  ),
  movement(
    'Exercise and sweat',
    'Sweat, flushing and what touches skin.',
    LearnGroup.everyday,
    PhosphorIconsThin.personSimpleRun,
  ),
  habits(
    'Everyday habits',
    'Small daily things, kept gentle.',
    LearnGroup.everyday,
    PhosphorIconsThin.hand,
  ),
  productTypes(
    'Product types',
    'What a cleanser, a serum and a toner are.',
    LearnGroup.products,
    PhosphorIconsThin.sprayBottle,
  ),
  labels(
    'Reading a label',
    'What the words and symbols on a pack mean.',
    LearnGroup.products,
    PhosphorIconsThin.tag,
  ),
  ingredients(
    'Skin-care ingredients',
    'What common ingredients are, and where they turn up.',
    LearnGroup.products,
    PhosphorIconsThin.flask,
  ),
  foodLabels(
    'Food labels',
    'What the words and numbers on a food pack mean.',
    LearnGroup.food,
    PhosphorIconsThin.tag,
  ),
  portions(
    'Portions and serving sizes',
    'Servings, portions and why weights differ.',
    LearnGroup.food,
    PhosphorIconsThin.scales,
  ),
  nutrients(
    'Protein, fibre and fats',
    'What the main parts of food are.',
    LearnGroup.food,
    PhosphorIconsThin.bowlFood,
  ),
  cookingWords(
    'Cooking words',
    'What simmer, blanch, temper and fold mean.',
    LearnGroup.food,
    PhosphorIconsThin.cookingPot,
  ),
  spicesStaples(
    'Spices and staples',
    'What common spices and kitchen staples are.',
    LearnGroup.food,
    PhosphorIconsThin.leaf,
  );

  const LearnCategory(this.title, this.blurb, this.group, this.icon);

  final String title;

  /// One line under the theme's name on the portal's front page.
  final String blurb;
  final LearnGroup group;
  final IconData icon;
}

class LearnEntry {
  const LearnEntry({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    this.sources = const [],
    this.why,
    this.aka = const [],
  });

  /// Stable, never reused: a card or a link can point at it.
  final String id;
  final LearnCategory category;
  final String title;
  final String body;

  /// Where this comes from, when one source clearly stands behind it.
  final List<String> sources;

  /// For an ingredient: why makers add it to a product, in one sentence. What
  /// the ingredient is used for, never whether it works.
  final String? why;

  /// For an ingredient: the other names it goes by on a label ("Ascorbic acid").
  /// Search finds the note under each of them.
  final List<String> aka;
}

/// The note about each of the seven measurements, by the measurement's key
/// (see metric_info.dart). The score page links to these.
const Map<String, String> kMetricNoteIds = {
  'redness': 'readings-m-redness',
  'texture': 'readings-m-texture',
  'pores': 'readings-m-pores',
  'spots': 'readings-m-spots',
  'acne': 'readings-m-acne',
  'evenness': 'readings-m-evenness',
  'wrinkles': 'readings-m-wrinkles',
};

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
    why:
        'Makers add it to products aimed at the look of fine lines, '
        'uneven tone and rough texture.',
    aka: ['Retinyl palmitate', 'Retinyl acetate', 'Retinaldehyde', 'Vitamin A'],
  ),
  LearnEntry(
    id: 'ingredient-niacinamide',
    category: LearnCategory.ingredients,
    title: 'Niacinamide',
    body:
        'Another name for vitamin B3, a nutrient that is also used in some '
        'skin-care products. It is found in many serums, moisturisers and '
        'toners.',
    why:
        'Makers add it to products aimed at the look of uneven tone, '
        'oiliness and large-looking pores.',
    aka: ['Nicotinamide', 'Vitamin B3'],
  ),
  LearnEntry(
    id: 'ingredient-vitamin-c',
    category: LearnCategory.ingredients,
    title: 'Vitamin C (in skin care)',
    body:
        'Also called ascorbic acid. An ingredient used in some skin-care '
        'products, often in the form of L-ascorbic acid. It is found in many '
        'serums and some moisturisers.',
    why:
        'Makers add it to products aimed at the look of dull or uneven '
        'skin, and as an antioxidant ingredient.',
    aka: [
      'Ascorbic acid',
      'L-ascorbic acid',
      'Sodium ascorbyl phosphate',
      'Magnesium ascorbyl phosphate',
      'Ascorbyl glucoside',
    ],
  ),
  LearnEntry(
    id: 'ingredient-hyaluronic-acid',
    category: LearnCategory.ingredients,
    title: 'Hyaluronic acid',
    body:
        'A molecule the body makes itself that holds a great deal of '
        'water. It is found in many serums, moisturisers and masks.',
    why:
        'Makers add it to products aimed at skin that feels dry, '
        'because it holds a great deal of water.',
    aka: ['Sodium hyaluronate', 'Hyaluronan'],
  ),
  LearnEntry(
    id: 'ingredient-salicylic-acid',
    category: LearnCategory.ingredients,
    title: 'Salicylic acid',
    body:
        'A beta hydroxy acid, often shortened to BHA. It is found in many '
        'acne products, such as cleansers, toners and spot products, and '
        'in some exfoliating products.',
    why:
        'Makers add it to products aimed at oily, blemish-prone skin, '
        'because it dissolves oil and loosens dead cells at the '
        'surface.',
    aka: ['BHA', 'Beta hydroxy acid', '2-hydroxybenzoic acid'],
  ),
  LearnEntry(
    id: 'ingredient-alpha-hydroxy-acids',
    category: LearnCategory.ingredients,
    title: 'Glycolic acid and lactic acid',
    body:
        'Two of the alpha hydroxy acids, often shortened to AHAs. They are '
        'found in many exfoliating toners, serums and peels.',
    why:
        'Makers add them to products meant to loosen dead cells on the '
        'surface, for skin that looks dull or rough.',
    aka: [
      'Glycolic acid',
      'Lactic acid',
      'Mandelic acid',
      'AHA',
      'Alpha hydroxy acid',
    ],
  ),
  LearnEntry(
    id: 'ingredient-benzoyl-peroxide',
    category: LearnCategory.ingredients,
    title: 'Benzoyl peroxide',
    body:
        'A compound used in many acne products, such as washes, gels and '
        'spot products.',
    why:
        'Makers add it to products aimed at acne-prone skin, because it '
        'is active against the bacteria linked to breakouts.',
    aka: ['BPO'],
  ),
  LearnEntry(
    id: 'ingredient-azelaic-acid',
    category: LearnCategory.ingredients,
    title: 'Azelaic acid',
    body:
        'An acid that occurs naturally in grains such as barley and wheat, '
        'and is also made in laboratories. It is found in some creams and '
        'gels made for blemish-prone skin.',
    why:
        'Makers add it to products aimed at blemish-prone skin, and at '
        'the look of redness and uneven tone.',
    aka: ['Nonanedioic acid'],
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
    why:
        'Makers add it to prescription products meant for acne and for '
        'the look of fine lines. Whether it is used is a decision for a '
        'doctor.',
    aka: ['Retinoic acid', 'All-trans retinoic acid'],
  ),
  LearnEntry(
    id: 'ingredient-bakuchiol',
    category: LearnCategory.ingredients,
    title: 'Bakuchiol',
    body:
        'An ingredient taken from the seeds of a plant, used in some '
        'serums and moisturisers.',
    why:
        'Makers add it to products offered as a plant-based alternative '
        'to retinol, aimed at the same concerns: fine lines and uneven '
        'tone.',
    aka: ['Babchi', 'Psoralea corylifolia seed extract'],
  ),
  LearnEntry(
    id: 'ingredient-ceramides',
    category: LearnCategory.ingredients,
    title: 'Ceramides',
    body:
        'Fats that occur naturally in the outer layer of skin. They are '
        'found in many moisturisers and cleansers.',
    why:
        'Makers add them to moisturisers meant to support the skin '
        'barrier and keep skin from feeling dry.',
    aka: ['Ceramide NP', 'Ceramide AP', 'Ceramide EOP'],
  ),
  LearnEntry(
    id: 'ingredient-peptides',
    category: LearnCategory.ingredients,
    title: 'Peptides',
    body:
        'Short chains of amino acids, the building blocks of proteins. '
        'They are found in some serums and moisturisers.',
    why:
        'Makers add them to products aimed at the look of fine lines '
        'and firmness.',
    aka: [
      'Palmitoyl tripeptide-1',
      'Palmitoyl pentapeptide-4',
      'Copper tripeptide-1',
    ],
  ),
  LearnEntry(
    id: 'ingredient-glycerin',
    category: LearnCategory.ingredients,
    title: 'Glycerin',
    body:
        'A common ingredient that attracts water. It is found in a very '
        'wide range of products, including cleansers, moisturisers and lip '
        'balms.',
    why:
        'Makers add it as a humectant: it draws water to the surface of '
        'skin, so a product feels moisturising and soft.',
    aka: ['Glycerol', 'Glycerine'],
  ),
  LearnEntry(
    id: 'ingredient-panthenol',
    category: LearnCategory.ingredients,
    title: 'Panthenol',
    body:
        'A form of vitamin B5. It is found in many moisturisers, lip balms '
        'and hair products.',
    why:
        'Makers add it to products meant to soothe skin and lips that '
        'feel dry or rough.',
    aka: ['Dexpanthenol', 'Provitamin B5', 'Vitamin B5'],
  ),
  LearnEntry(
    id: 'ingredient-squalane',
    category: LearnCategory.ingredients,
    title: 'Squalane',
    body:
        'A light oil, often made from olives or sugar cane. It is found in '
        'some moisturisers and facial oils.',
    why:
        'Makers add it as a light oil that gives a soft, non-greasy '
        'feel and helps keep moisture in.',
    aka: ['Squalene'],
  ),
  LearnEntry(
    id: 'ingredient-petrolatum',
    category: LearnCategory.ingredients,
    title: 'Petrolatum',
    body:
        'A soft, jelly-like substance made from petroleum. It is found in '
        'many ointments, lip balms and moisturisers.',
    why:
        'Makers add it to form a seal on the skin that slows water '
        'loss, in products for dry or chapped skin.',
    aka: ['Petroleum jelly', 'Soft paraffin', 'Paraffinum molle'],
  ),
  LearnEntry(
    id: 'ingredient-mineral-filters',
    category: LearnCategory.ingredients,
    title: 'Zinc oxide and titanium dioxide',
    body:
        'Two minerals used as sunscreen filters, often called the mineral '
        'filters. They are found in many sunscreens, and in some tinted '
        'moisturisers and makeup that list an SPF.',
    why:
        'Makers add them to block and scatter UV light, so that a '
        'product can carry an SPF rating.',
    aka: ['Zinc oxide', 'Titanium dioxide'],
  ),
  LearnEntry(
    id: 'ingredient-chemical-filters',
    category: LearnCategory.ingredients,
    title: 'Chemical sunscreen filters',
    body:
        'A group of ingredients, such as avobenzone and oxybenzone, that '
        'are used as filters in sunscreens. They are found in many '
        'sunscreens, and in some moisturisers and makeup that list an SPF.',
    why:
        'Makers add them to absorb UV light, so that a product can '
        'carry an SPF rating.',
    aka: [
      'Avobenzone',
      'Oxybenzone',
      'Octinoxate',
      'Octocrylene',
      'Homosalate',
      'Octisalate',
    ],
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
    why:
        'Makers add it to give a product a scent, or to cover the smell '
        'of other ingredients.',
    aka: ['Parfum', 'Perfume', 'Aroma'],
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
  LearnEntry(
    id: 'skin-layers',
    category: LearnCategory.skinBasics,
    title: 'Skin has three main layers',
    body:
        'The outer layer is the epidermis, the middle layer is the '
        'dermis, and below them sits a layer of fat. Most of what a '
        'camera picks up is the epidermis and what shows through it.',
  ),
  LearnEntry(
    id: 'skin-renewal',
    category: LearnCategory.skinBasics,
    title: 'Skin renews itself about every month',
    body:
        'Cells made at the base of the epidermis slowly move to the '
        'surface and are shed. In young adults this takes roughly a '
        'month, and it tends to slow down with age.',
  ),
  LearnEntry(
    id: 'skin-barrier',
    category: LearnCategory.skinBasics,
    title: 'The skin barrier',
    body:
        'The outermost layer works a little like a wall of cells held '
        'together by fats. It keeps water in and many irritants out. '
        'When people say their barrier is off, they usually mean skin '
        'that feels tight, dry or stings easily.',
  ),
  LearnEntry(
    id: 'skin-sebum',
    category: LearnCategory.skinBasics,
    title: 'Sebum is the skin\'s own oil',
    body:
        'Glands attached to hair follicles make sebum, mostly on the '
        'face, scalp and upper body. How much people make varies, and '
        'for many it rises with heat and humidity.',
  ),
  LearnEntry(
    id: 'skin-pores',
    category: LearnCategory.skinBasics,
    title: 'What pores are',
    body:
        'Pores are the small openings of hair follicles and sweat '
        'glands. Their size is largely set by genetics, and they can '
        'look larger when they hold oil and dead cells, or as skin loses '
        'firmness with age.',
  ),
  LearnEntry(
    id: 'skin-collagen',
    category: LearnCategory.skinBasics,
    title: 'Collagen and elastin',
    body:
        'Two proteins in the dermis that give skin its firmness and its '
        'spring. The body makes less of them with age, and years of sun '
        'exposure can break them down faster.',
  ),
  LearnEntry(
    id: 'skin-melanin',
    category: LearnCategory.skinBasics,
    title: 'Melanin',
    body:
        'A pigment made by cells in the epidermis that gives skin, hair '
        'and eyes their colour. Skin makes more of it after time in the '
        'sun, which is what a tan is. People of every skin tone can '
        'burn, though more melanin means a slower burn.',
  ),
  LearnEntry(
    id: 'skin-types',
    category: LearnCategory.skinBasics,
    title: 'Skin types are everyday words',
    body:
        'People describe their skin as dry, oily, combination or normal, '
        'and as sensitive. These are everyday descriptions, not medical '
        'categories, and skin can change with the season, the climate '
        'and age.',
  ),
  LearnEntry(
    id: 'readings-light',
    category: LearnCategory.readings,
    title: 'Light changes what the camera sees',
    body:
        'Colour, shine and shadow all change with the light, so the same '
        'face can read a little differently by a window, under a lamp or '
        'outdoors. Readings are most comparable when the light is the '
        'same each time.',
  ),
  LearnEntry(
    id: 'readings-time',
    category: LearnCategory.readings,
    title: 'Skin looks different through the day',
    body:
        'Skin is often puffier or more flushed soon after waking, oilier '
        'by the afternoon and tired by evening. Taking readings at about '
        'the same time of day keeps those swings out of the trend.',
  ),
  LearnEntry(
    id: 'readings-phone',
    category: LearnCategory.readings,
    title: 'Phones read differently',
    body:
        'Every phone camera sees skin a little differently, so the same '
        'face can score differently on two phones, and a few of the '
        'seven measurements can differ quite a lot. The key is '
        'consistency: take your readings on your own phone, in similar '
        'light, and watch the long-term trend there.',
  ),
  LearnEntry(
    id: 'readings-angle',
    category: LearnCategory.readings,
    title: 'Distance and angle matter',
    body:
        'A face held closer or further away, tilted or turned, shows '
        'different amounts of skin and different shadows. The guided '
        'camera helps line the face up, and keeping the same pose each '
        'time keeps readings alike.',
  ),
  LearnEntry(
    id: 'readings-makeup',
    category: LearnCategory.readings,
    title: 'Makeup, creams and damp skin',
    body:
        'Makeup, sunscreen, a freshly applied cream or damp skin after '
        'washing can all change shine and colour in a photo. Many people '
        'take readings on clean, dry skin at the same point in their '
        'day, so those effects stay the same.',
  ),
  LearnEntry(
    id: 'readings-trend',
    category: LearnCategory.readings,
    title: 'The trend matters more than the number',
    body:
        'A single reading is one moment in one light. Several readings '
        'over weeks smooth out the light, the sleep and the time of day, '
        'and show which direction the numbers are moving.',
  ),
  LearnEntry(
    id: 'readings-seven',
    category: LearnCategory.readings,
    title: 'What the seven measurements look at',
    body:
        'Redness, texture, pores, spots, acne, evenness and wrinkles '
        'each look at colour and texture patterns in the photo. They '
        'describe how skin looks in a photo, nothing more.',
  ),
  LearnEntry(
    id: 'readings-m-redness',
    category: LearnCategory.readings,
    title: 'What the Redness measurement looks at',
    body:
        'Redness in a photo is the pink or red that sits over skin '
        'tone. Warm rooms, exercise, a hot drink, a flush of feeling '
        'or rubbed skin can all show up as more redness for a while, '
        'and it often settles on its own.',
  ),
  LearnEntry(
    id: 'readings-m-texture',
    category: LearnCategory.readings,
    title: 'What the Texture measurement looks at',
    body:
        'Texture looks at how even the surface of skin appears: small '
        'bumps, dry flaking and rough patches. Light from the side '
        'makes the surface look rougher, and dry air or a recent wash '
        'can change how smooth it looks that day.',
  ),
  LearnEntry(
    id: 'readings-m-pores',
    category: LearnCategory.readings,
    title: 'What the Pores measurement looks at',
    body:
        'The Pores measurement looks at how visible the small '
        'openings in skin are. Pores look larger in close, bright '
        'light and on warm days, and most visible on the nose and '
        'cheeks, where skin makes more oil.',
  ),
  LearnEntry(
    id: 'readings-m-spots',
    category: LearnCategory.readings,
    title: 'What the Spots measurement looks at',
    body:
        'Spots looks for small areas that are darker than the skin '
        'around them. Sun exposure is a common reason skin makes '
        'darker patches, and a spot that looks darker in one photo '
        'may simply be a shadow or a mark of the light.',
  ),
  LearnEntry(
    id: 'readings-m-acne',
    category: LearnCategory.readings,
    title: 'What the Acne measurement looks at',
    body:
        'The Acne measurement looks for inflamed bumps that are '
        'active now. It is separate from marks left behind after a '
        'breakout, which belong to Spots and Evenness. It describes '
        'what a photo shows and is not a medical assessment.',
  ),
  LearnEntry(
    id: 'readings-m-evenness',
    category: LearnCategory.readings,
    title: 'What the Evenness measurement looks at',
    body:
        'Evenness looks at how uniform skin colour is across the '
        'face, apart from spots. Uneven light, a tan line or makeup '
        'at the edge can move it, which is one reason the same '
        'lighting each time makes readings easier to compare.',
  ),
  LearnEntry(
    id: 'readings-m-wrinkles',
    category: LearnCategory.readings,
    title: 'What the Wrinkles measurement looks at',
    body:
        'Wrinkles looks at fine lines and creases, mostly around the '
        'eyes and forehead. Lines look deeper in strong side light '
        'and when skin is dry, and they look softer in even light, so '
        'lighting changes this one a lot.',
  ),
  LearnEntry(
    id: 'sun-monsoon',
    category: LearnCategory.sun,
    title: 'Rainy and humid seasons',
    body:
        'In a rainy season the air is heavy with moisture, and skin '
        'often feels oilier and stickier because sweat stays on it '
        'longer. Cloud still lets a good share of UV through.',
  ),
  LearnEntry(
    id: 'sun-rainy-damp',
    category: LearnCategory.sun,
    title: 'Rainy-season humidity and damp clothes',
    body:
        'When the air stays wet for weeks, damp clothes, towels and '
        'shoes take longer to dry. Skin that stays damp inside them can '
        'feel sticky or irritated, and many people notice it most where '
        'fabric rubs or folds.',
  ),
  LearnEntry(
    id: 'sun-rainy-oil',
    category: LearnCategory.sun,
    title: 'Why skin can look shinier in humid weather',
    body:
        'In very humid air, sweat does not evaporate easily, so a '
        'film of moisture and oil can sit on the surface. A shine at the '
        'forehead and nose is common in humid seasons and says little '
        'about skin type.',
  ),
  LearnEntry(
    id: 'sun-heated-rooms',
    category: LearnCategory.sun,
    title: 'Heated rooms dry the air',
    body:
        'Indoor heating warms the air without adding moisture, so the '
        'air inside can be drier than the cold air outdoors. Many people '
        'find their skin feels tighter in the heating season.',
  ),
  LearnEntry(
    id: 'sun-cooled-rooms',
    category: LearnCategory.sun,
    title: 'Air conditioning dries indoor air too',
    body:
        'Cooling air pulls moisture out of it. After long hours in an '
        'air-conditioned room, many people notice skin and lips feeling '
        'drier than they do in the open air of the same day.',
  ),
  LearnEntry(
    id: 'sun-hot-dry',
    category: LearnCategory.sun,
    title: 'Hot, dry weather and skin feel',
    body:
        'Where heat comes with dry air, sweat dries almost as fast as '
        'it appears, which can feel cooling while skin loses water '
        'quietly. Dust and wind often come with it.',
  ),
  LearnEntry(
    id: 'sun-wind',
    category: LearnCategory.sun,
    title: 'Wind and exposed skin',
    body:
        'Wind carries moisture away from skin faster than still air '
        'does, and it can leave cheeks and lips feeling rough. Skin '
        'that is bare to wind and cold at once often shows it first.',
  ),
  LearnEntry(
    id: 'sun-height',
    category: LearnCategory.sun,
    title: 'Higher places, stronger UV',
    body:
        'The thinner air at height filters less sunlight, so UV rises '
        'the higher a place is. Mountain days can bring more UV than '
        'the same hour at sea level.',
    sources: [_who],
  ),
  LearnEntry(
    id: 'sun-bounce',
    category: LearnCategory.sun,
    title: 'Snow, water and sand reflect UV',
    body:
        'Bright surfaces bounce UV back up toward the face, so skin '
        'can receive it from below as well as from above. Snow reflects '
        'much of it, water and sand somewhat less.',
    sources: [_aad],
  ),
  LearnEntry(
    id: 'sun-turning',
    category: LearnCategory.sun,
    title: 'When the season turns',
    body:
        'Skin takes a little while to settle into a new season. Many '
        'people notice it feeling different for a week or two as the '
        'weather changes, and readings can move a little with it.',
  ),
  LearnEntry(
    id: 'sun-air',
    category: LearnCategory.sun,
    title: 'Air quality and skin',
    body:
        'Air pollution is a mix of tiny particles and gases that settle '
        'on skin as well as being breathed in. Researchers are still '
        'studying what it does to skin, and many people simply wash '
        'their face at the end of a day spent outdoors in a busy city.',
  ),
  LearnEntry(
    id: 'sun-tone',
    category: LearnCategory.sun,
    title: 'Every skin tone can burn',
    body:
        'More melanin gives some natural protection from UV, but people '
        'of every skin tone can burn, and UV adds up over the years for '
        'everyone.',
  ),
  LearnEntry(
    id: 'water-hard',
    category: LearnCategory.water,
    title: 'Hard water',
    body:
        'Water with a lot of dissolved minerals in it is called hard. '
        'Some people find it leaves skin feeling tight after washing, '
        'and researchers are still studying whether it matters for skin.',
  ),
  LearnEntry(
    id: 'move-sweat',
    category: LearnCategory.movement,
    title: 'Sweat is mostly water',
    body:
        'Sweat is mostly water with a little salt, and it cools the body '
        'down. The smell people notice comes later, when sweat mixes '
        'with the bacteria that live on skin.',
  ),
  LearnEntry(
    id: 'move-flush',
    category: LearnCategory.movement,
    title: 'A flushed face after exercise is normal',
    body:
        'Blood vessels near the skin widen as the body warms up, so '
        'faces often look redder for a while after a workout. A reading '
        'taken right after exercise may show more redness than usual.',
  ),
  LearnEntry(
    id: 'move-things',
    category: LearnCategory.movement,
    title: 'What touches skin during a workout',
    body:
        'Towels, helmets, masks, headbands and gym equipment all sit '
        'against skin and collect sweat. Many people wipe their face and '
        'rinse afterwards.',
  ),
  LearnEntry(
    id: 'move-outdoors',
    category: LearnCategory.movement,
    title: 'Time outdoors adds up',
    body:
        'A walk or a run outdoors adds sun and weather to the day as '
        'well as the exercise, which is one reason some people see their '
        'readings shift on active days.',
  ),
  LearnEntry(
    id: 'prod-cleanser',
    category: LearnCategory.productTypes,
    title: 'Cleanser',
    body:
        'A product for washing the face, made as a gel, foam, cream, oil '
        'or balm. It lifts away oil, sweat, sunscreen and makeup, and '
        'then rinses off.',
  ),
  LearnEntry(
    id: 'prod-toner',
    category: LearnCategory.productTypes,
    title: 'Toner',
    body:
        'A thin, watery liquid used after cleansing. Some are made to '
        'feel soothing or hydrating and others carry exfoliating acids, '
        'so the word covers quite different products.',
  ),
  LearnEntry(
    id: 'prod-serum',
    category: LearnCategory.productTypes,
    title: 'Serum',
    body:
        'A light, concentrated liquid that sits under a moisturiser. '
        'Serums often carry one or two featured ingredients in a thin '
        'texture that soaks in quickly.',
  ),
  LearnEntry(
    id: 'prod-essence',
    category: LearnCategory.productTypes,
    title: 'Essence',
    body:
        'A watery, lightweight layer popular in Korean skin care, used '
        'between toner and serum. The line between essence, toner and '
        'serum is blurry, and makers use the words differently.',
  ),
  LearnEntry(
    id: 'prod-moisturiser',
    category: LearnCategory.productTypes,
    title: 'Moisturiser',
    body:
        'A cream, lotion or gel that helps skin hold on to water. Most '
        'combine ingredients that attract water with oils or waxes that '
        'slow water from escaping.',
  ),
  LearnEntry(
    id: 'prod-sunscreen',
    category: LearnCategory.productTypes,
    title: 'Sunscreen',
    body:
        'A product with filters that absorb or reflect ultraviolet '
        'light. It comes as lotions, creams, gels, sticks and sprays, '
        'and its label carries an SPF number.',
  ),
  LearnEntry(
    id: 'prod-exfoliant',
    category: LearnCategory.productTypes,
    title: 'Exfoliant',
    body:
        'A product that loosens or removes dead cells from the surface '
        'of the skin, either by rubbing (a scrub) or with acids or '
        'enzymes (a chemical exfoliant).',
  ),
  LearnEntry(
    id: 'prod-mask',
    category: LearnCategory.productTypes,
    title: 'Face mask',
    body:
        'A product left on the face for a few minutes and then rinsed or '
        'peeled off, or a sheet soaked in liquid. Masks come in clay, '
        'cream, gel and sheet forms.',
  ),
  LearnEntry(
    id: 'label-noncomedogenic',
    category: LearnCategory.labels,
    title: 'Non-comedogenic',
    body:
        'A label word meaning a product was made not to clog pores. '
        'There is no single standard test behind it, so it is a maker\'s '
        'description rather than a promise.',
  ),
  LearnEntry(
    id: 'label-fragrance',
    category: LearnCategory.labels,
    title: 'Fragrance-free and unscented',
    body:
        'Fragrance-free means no fragrance ingredients were added. '
        'Unscented can mean a product holds other ingredients that cover '
        'or soften its smell, so the two words are not always the same.',
  ),
  LearnEntry(
    id: 'label-hypoallergenic',
    category: LearnCategory.labels,
    title: 'Hypoallergenic',
    body:
        'Used on labels for products made to cause fewer allergic '
        'reactions. In many countries the word has no strict legal '
        'meaning, so it describes what the maker intended.',
  ),
  LearnEntry(
    id: 'label-derm-tested',
    category: LearnCategory.labels,
    title: 'Dermatologist-tested',
    body:
        'Means a dermatologist was involved in testing the product in '
        'some way. The phrase does not say how much testing was done or '
        'what kind.',
  ),
  LearnEntry(
    id: 'label-pao',
    category: LearnCategory.labels,
    title: 'The open-jar symbol',
    body:
        'A small picture of an open jar with a number and an M, such as '
        '12M, shows how many months a product is usually kept after it '
        'is first opened. It is separate from the date printed on the '
        'pack.',
  ),
  LearnEntry(
    id: 'label-order',
    category: LearnCategory.labels,
    title: 'Ingredient lists',
    body:
        'Ingredients are usually listed from the most to the least by '
        'amount, though anything below about one percent can come in any '
        'order. Lists use standard names, often in Latin or chemical '
        'form.',
  ),
  LearnEntry(
    id: 'label-spf',
    category: LearnCategory.labels,
    title: 'SPF and PA',
    body:
        'SPF is a number showing how much a sunscreen protects against '
        'UVB, the rays that cause sunburn. PA, shown with plus signs, is '
        'a rating for UVA used on products from East Asia and some other '
        'markets. Broad spectrum means protection against both.',
  ),
  LearnEntry(
    id: 'ingredient-vitamin-e',
    category: LearnCategory.ingredients,
    title: 'Vitamin E',
    body:
        'A group of fat-soluble compounds, the best known being '
        'tocopherol, that also occur naturally in nuts and seed oils. It '
        'is found in many moisturisers and sunscreens.',
    why:
        'Makers add it as an antioxidant that keeps the oils in a '
        'product from going off, and for the soft feel it gives on '
        'skin.',
    aka: ['Tocopherol', 'Tocopheryl acetate', 'Alpha-tocopherol'],
  ),
  LearnEntry(
    id: 'ingredient-urea',
    category: LearnCategory.ingredients,
    title: 'Urea',
    body:
        'A substance the body makes naturally, also made in '
        'laboratories, that attracts water. It is found in many '
        'moisturisers, especially creams for hands and feet.',
    why:
        'Makers add it to products for very dry or rough skin, because '
        'it holds water and softens thick, rough patches.',
    aka: ['Carbamide'],
  ),
  LearnEntry(
    id: 'ingredient-sulfur',
    category: LearnCategory.ingredients,
    title: 'Sulfur',
    body:
        'A natural element that has been used in skin products for a '
        'very long time. It is found in some acne masks and spot '
        'products, and in some shampoos.',
    why:
        'Makers add it to products aimed at oily, blemish-prone skin '
        'and at flaking on the scalp.',
    aka: ['Sulphur'],
  ),
  LearnEntry(
    id: 'ingredient-clay',
    category: LearnCategory.ingredients,
    title: 'Clay (kaolin and bentonite)',
    body:
        'Fine mineral powders that soak up oil and water. They are found '
        'in many face masks and in some cleansers.',
    why:
        'Makers add them to masks and cleansers meant to soak up extra '
        'oil.',
    aka: ['Kaolin', 'Bentonite', 'Montmorillonite'],
  ),
  LearnEntry(
    id: 'ingredient-aloe-vera',
    category: LearnCategory.ingredients,
    title: 'Aloe vera',
    body:
        'A gel taken from the leaves of the aloe plant, and mostly '
        'water. It is found in many gels, lotions and after-sun '
        'products.',
    why:
        'Makers add it for its cool, watery feel, in products meant to '
        'soothe skin after sun and to give light moisture.',
    aka: ['Aloe barbadensis leaf juice', 'Aloe barbadensis leaf extract'],
  ),
  LearnEntry(
    id: 'ingredient-tea-tree-oil',
    category: LearnCategory.ingredients,
    title: 'Tea tree oil',
    body:
        'A strong oil taken from the leaves of an Australian plant. It '
        'is found in some acne spot products, washes and shampoos. As an '
        'essential oil it can irritate some people\'s skin, so it is '
        'usually diluted.',
    why:
        'Makers add it to products aimed at blemish-prone skin and an '
        'oily scalp, for its long use as an antiseptic.',
    aka: ['Melaleuca alternifolia leaf oil'],
  ),
  LearnEntry(
    id: 'ingredient-dimethicone',
    category: LearnCategory.ingredients,
    title: 'Dimethicone',
    body:
        'A silicone: a smooth, slippery liquid that sits on top of skin '
        'and leaves it feeling soft. It is found in many primers, '
        'moisturisers and sunscreens.',
    why:
        'Makers add it to give a smooth, silky feel, to fill in a '
        'rough-looking surface and to form a light barrier on skin.',
    aka: ['Polydimethylsiloxane', 'Silicone'],
  ),
  LearnEntry(
    id: 'ingredient-caffeine',
    category: LearnCategory.ingredients,
    title: 'Caffeine',
    body:
        'The same compound that is in coffee and tea, also made in '
        'laboratories. It is found in some eye creams and serums.',
    why:
        'Makers add it to eye products aimed at the look of puffiness '
        'and tired-looking skin.',
  ),
  LearnEntry(
    id: 'ingredient-surfactants',
    category: LearnCategory.ingredients,
    title: 'Surfactants (such as sodium lauryl sulfate)',
    body:
        'Ingredients that let oil and water mix, so that dirt and oil '
        'can be rinsed away. They are found in cleansers, body washes '
        'and shampoos, where they do the cleaning, and some are gentler '
        'than others.',
    why:
        'Makers add them to do the cleaning: they lift oil and dirt so '
        'they rinse away, and they make the lather.',
    aka: [
      'Sodium lauryl sulfate',
      'Sodium laureth sulfate',
      'Cocamidopropyl betaine',
      'SLS',
      'SLES',
    ],
  ),
  LearnEntry(
    id: 'ingredient-preservatives',
    category: LearnCategory.ingredients,
    title: 'Preservatives (such as parabens and phenoxyethanol)',
    body:
        'Ingredients that keep a product from growing mould and bacteria '
        'once water is in it. They are found in most creams, lotions and '
        'cleansers that contain water. Different preservatives are '
        'allowed in different countries.',
    why:
        'Makers add them so that a product stays safe to use for months '
        'once water is in it.',
    aka: [
      'Phenoxyethanol',
      'Methylparaben',
      'Propylparaben',
      'Sodium benzoate',
      'Potassium sorbate',
    ],
  ),
  LearnEntry(
    id: 'ingredient-alcohol',
    category: LearnCategory.ingredients,
    title: 'Alcohol on a label',
    body:
        'The word covers very different things. Ethanol, or denatured '
        'alcohol, is the thin, quick-drying kind found in some toners '
        'and gel sunscreens. Fatty alcohols such as cetyl alcohol are '
        'waxy and are found in many creams as thickeners.',
    why:
        'Makers add ethanol to make a product thin and quick-drying or '
        'to carry other ingredients, and fatty alcohols to thicken and '
        'soften creams.',
    aka: [
      'Alcohol denat.',
      'Ethanol',
      'SD alcohol',
      'Cetyl alcohol',
      'Cetearyl alcohol',
    ],
  ),
  LearnEntry(
    id: 'ingredient-centella',
    category: LearnCategory.ingredients,
    title: 'Centella asiatica (cica)',
    body:
        'A herb that grows in wet places across Asia and is often called '
        'cica or tiger grass. It is found in many serums, creams and '
        'masks, especially ones from Korea.',
    why:
        'Makers add it to products aimed at skin that looks red, '
        'irritated or sensitive.',
    aka: [
      'Centella asiatica extract',
      'Madecassoside',
      'Asiaticoside',
      'Cica',
      'Tiger grass',
      'Gotu kola',
    ],
  ),
  LearnEntry(
    id: 'ingredient-colloidal-oatmeal',
    category: LearnCategory.ingredients,
    title: 'Colloidal oatmeal',
    body:
        'Oats ground so finely that they stay suspended in liquid. It is '
        'found in many creams, lotions and bath products.',
    why:
        'Makers add it to products meant to soothe skin that feels dry '
        'or itchy.',
    aka: ['Avena sativa kernel flour', 'Oat flour'],
  ),
  LearnEntry(
    id: 'ingredient-adapalene',
    category: LearnCategory.ingredients,
    title: 'Adapalene',
    body:
        'A retinoid, a relative of vitamin A, sold over the counter in '
        'some countries and on prescription in others. It is found in '
        'some gels and creams made for acne. Retinoids are known to '
        'carry risks in pregnancy, and many guidelines advise speaking '
        'with a doctor before using them while pregnant or trying to '
        'conceive.',
    why: 'Makers add it to gels and creams aimed at acne-prone skin.',
  ),
  LearnEntry(
    id: 'food-label-serving',
    category: LearnCategory.foodLabels,
    title: 'The serving size sets every other number',
    body:
        'The numbers on a nutrition label are for one serving, not '
        'for the whole pack. A pack often holds more than one '
        'serving, so eating all of it means more than the label '
        'shows.',
  ),
  LearnEntry(
    id: 'food-label-order',
    category: LearnCategory.foodLabels,
    title: 'Ingredients are listed from most to least',
    body:
        'In many countries the ingredients on a pack are listed by '
        'weight, with the largest amount first. The first few names '
        'tell most of the story of what a food is made of.',
  ),
  LearnEntry(
    id: 'food-label-sugars',
    category: LearnCategory.foodLabels,
    title: 'Total sugars and added sugars are different lines',
    body:
        'Total sugars include those found naturally in fruit and '
        'milk. Where a label also shows added sugars, that line '
        'counts only the sugars put in while the food was made.',
  ),
  LearnEntry(
    id: 'food-label-front',
    category: LearnCategory.foodLabels,
    title: 'The front of a pack is not the nutrition label',
    body:
        'Words on the front, such as light, natural or wholesome, can '
        'mean different things in different places. The numbers and '
        'the ingredient list on the back are where the details are.',
  ),
  LearnEntry(
    id: 'food-label-per100',
    category: LearnCategory.foodLabels,
    title: 'Per 100 grams lets two foods be compared',
    body:
        'Many labels give amounts per 100 grams as well as per '
        'serving. Because the amount is the same for every pack, two '
        'foods of different sizes can be compared side by side.',
  ),
  LearnEntry(
    id: 'portion-vs-serving',
    category: LearnCategory.portions,
    title: 'A portion and a serving are not always the same',
    body:
        'A serving is the amount a label uses for its numbers. A '
        'portion is the amount a person actually puts on the plate, '
        'which may be smaller or larger.',
  ),
  LearnEntry(
    id: 'portion-dish-size',
    category: LearnCategory.portions,
    title: 'Bigger plates and bowls tend to hold more',
    body:
        'Many people serve more food onto a larger plate or bowl '
        'without noticing. The same meal can look small on a big '
        'plate and generous on a small one.',
  ),
  LearnEntry(
    id: 'portion-dry-cooked',
    category: LearnCategory.portions,
    title: 'Dry and cooked weights are not the same',
    body:
        'Rice, pasta and lentils soak up water as they cook, so '
        'cooked food weighs more than dry food for the same amount of '
        'energy. That is why a recipe says whether it weighs things '
        'raw or cooked.',
  ),
  LearnEntry(
    id: 'portion-measures',
    category: LearnCategory.portions,
    title: 'Cups and spoons are rough, scales are steadier',
    body:
        'A cup of flour can weigh quite different amounts depending '
        'on how it is scooped. A kitchen scale gives the same answer '
        'each time, which is why many recipes give grams.',
  ),
  LearnEntry(
    id: 'nutrient-protein',
    category: LearnCategory.nutrients,
    title: 'What protein is',
    body:
        'Protein is made of building blocks called amino acids. It '
        'turns up in beans, lentils, eggs, dairy, fish, meat and '
        'nuts, and gives about 4 calories per gram.',
  ),
  LearnEntry(
    id: 'nutrient-fibre',
    category: LearnCategory.nutrients,
    title: 'What fibre is',
    body:
        'Fibre is the part of plant foods that the body does not '
        'break down for energy. Whole grains, beans, fruit and '
        'vegetables are common sources.',
  ),
  LearnEntry(
    id: 'nutrient-fat',
    category: LearnCategory.nutrients,
    title: 'Fat holds the most energy per gram',
    body:
        'Fat gives about 9 calories per gram, more than twice the 4 '
        'calories in a gram of protein or of carbohydrate. That is '
        'why oils and nuts are small in weight but large in energy.',
  ),
  LearnEntry(
    id: 'nutrient-carbs',
    category: LearnCategory.nutrients,
    title: 'Carbohydrates include sugars, starches and fibre',
    body:
        'Carbohydrate is a family: sugars, starches and fibre. Bread, '
        'rice, fruit and potatoes all contain it in different mixes.',
  ),
  LearnEntry(
    id: 'nutrient-water',
    category: LearnCategory.nutrients,
    title: 'Water adds weight but not energy',
    body:
        'Soup, fruit and cooked greens are heavy because of the water '
        'in them, and low in energy for their weight. Dry or oily '
        'foods hold far more energy in the same weight.',
  ),
  LearnEntry(
    id: 'ingredient-turmeric',
    category: LearnCategory.ingredients,
    title: 'Turmeric',
    body:
        'A yellow-orange root, dried and ground, with a long place in '
        'South Asian cooking and in traditional home remedies. Its '
        'colour comes from curcumin, which can stain skin, cloth and '
        'surfaces. It is found in some face masks, soaps and creams, '
        'and in nearly every kitchen.',
    why:
        'Makers add it to face masks and creams for its traditional '
        'link with a glowing complexion, and for its colour.',
    aka: ['Curcuma longa root extract', 'Curcumin', 'Haldi'],
  ),
  LearnEntry(
    id: 'ingredient-neem',
    category: LearnCategory.ingredients,
    title: 'Neem',
    body:
        'The leaves, bark and oil of the neem tree, which grows across '
        'South Asia and has a long place in traditional Indian '
        'practice. The oil has a strong smell. It is found in some '
        'soaps, face washes and scalp products.',
    why:
        'Makers add it to soaps, face washes and scalp products for its '
        'long traditional use on skin and hair.',
    aka: [
      'Azadirachta indica leaf extract',
      'Azadirachta indica seed oil',
      'Neem oil',
    ],
  ),
  LearnEntry(
    id: 'ingredient-multani-mitti',
    category: LearnCategory.ingredients,
    title: 'Multani mitti (fuller\'s earth)',
    body:
        'A fine clay that has long been used in South Asia as a face '
        'pack. Mixed with water or rose water, it dries on skin and '
        'soaks up oil. It is found in many face packs and in some '
        'soaps.',
    why:
        'Makers add it to face packs and cleansers meant to soak up '
        'extra oil.',
    aka: ['Fuller\'s earth', 'Multani mitti', 'Calcium bentonite'],
  ),
  LearnEntry(
    id: 'ingredient-rose-water',
    category: LearnCategory.ingredients,
    title: 'Rose water',
    body:
        'Water scented with rose petals, made by steaming or soaking '
        'them. It has been used for centuries in South Asia, the Middle '
        'East and Europe, in cooking as well as on skin. It is found in '
        'many toners, face mists and some creams.',
    why:
        'Makers add it to toners and mists for its light scent and '
        'cool, fresh feel.',
    aka: ['Rosa damascena flower water', 'Gulab jal', 'Rosewater'],
  ),
  LearnEntry(
    id: 'ingredient-sandalwood',
    category: LearnCategory.ingredients,
    title: 'Sandalwood',
    body:
        'A fragrant wood, and the oil or powder taken from it, with a '
        'long place in Indian ritual and traditional skin care. Real '
        'sandalwood oil is costly, and many products use a scent made '
        'to resemble it. It is found in some soaps, face packs, creams '
        'and perfumes.',
    why:
        'Makers add it for a warm, woody scent and for its traditional '
        'place in skin-care rituals.',
    aka: ['Santalum album oil', 'Santalum album wood extract', 'Chandan'],
  ),
  LearnEntry(
    id: 'ingredient-coconut-oil',
    category: LearnCategory.ingredients,
    title: 'Coconut oil',
    body:
        'An oil pressed from coconut kernels, solid in a cool room and '
        'liquid in a warm one. It has been used on skin and hair for '
        'generations across South Asia, Southeast Asia and the Pacific. '
        'It is found in many soaps, moisturisers, hair oils and lip '
        'balms.',
    why:
        'Makers add it as a rich, plant-based oil that makes products '
        'feel soft and moisturising.',
    aka: ['Cocos nucifera oil', 'Cocos nucifera fruit extract', 'Coconut'],
  ),
  LearnEntry(
    id: 'ingredient-honey',
    category: LearnCategory.ingredients,
    title: 'Honey',
    body:
        'A thick, sweet liquid that bees make from nectar, long used in '
        'food and in home skin care. It attracts water. It is found in '
        'some face masks, lip balms and cleansers.',
    why:
        'Makers add it to masks and balms because it draws water and '
        'feels smooth.',
    aka: ['Mel', 'Honey extract'],
  ),
  LearnEntry(
    id: 'ingredient-almond-oil',
    category: LearnCategory.ingredients,
    title: 'Almond oil',
    body:
        'A light oil pressed from almonds, used on skin and hair for '
        'centuries and a common oil for massage. People with a nut '
        'allergy are often advised to look for it on labels. It is '
        'found in some body oils, moisturisers and massage products.',
    why:
        'Makers add it as a light oil that spreads easily and softens '
        'skin.',
    aka: ['Prunus amygdalus dulcis oil', 'Sweet almond oil'],
  ),
  LearnEntry(
    id: 'prod-aha-bha',
    category: LearnCategory.productTypes,
    title: 'AHA or BHA: how they differ',
    body:
        'Both are acids used in exfoliating products. AHAs, such as '
        'glycolic and lactic acid, dissolve in water and stay mostly on '
        'the surface of skin. BHA, usually salicylic acid, dissolves in '
        'oil, so it can reach into pores, which is why it is common in '
        'products for oily skin.',
  ),
  LearnEntry(
    id: 'prod-chem-mineral',
    category: LearnCategory.productTypes,
    title: 'Chemical or mineral sunscreen',
    body:
        'A mineral sunscreen uses zinc oxide or titanium dioxide, which '
        'sit on skin and reflect and scatter UV. A chemical sunscreen '
        'uses filters that absorb UV and give it off as a little heat. '
        'Many products mix both, and either kind can carry the same SPF '
        'number.',
  ),
  LearnEntry(
    id: 'prod-serum-moisturiser',
    category: LearnCategory.productTypes,
    title: 'Serum or moisturiser',
    body:
        'A serum is a thin, light liquid made to carry a small amount '
        'of an ingredient. A moisturiser is thicker and meant to hold '
        'water in skin. Many routines put a serum on first and a '
        'moisturiser after, because thin goes before thick.',
  ),
  LearnEntry(
    id: 'prod-texture-names',
    category: LearnCategory.productTypes,
    title: 'Cream, lotion, gel or ointment',
    body:
        'The names describe how much oil and water a product holds. A '
        'gel is mostly water and feels light. A lotion is thin and '
        'spreads easily. A cream is thicker. An ointment is mostly oil '
        'or jelly and feels heavy and greasy.',
  ),
  LearnEntry(
    id: 'prod-cleanser-kinds',
    category: LearnCategory.productTypes,
    title: 'Gel, cream or oil cleanser',
    body:
        'A gel cleanser is clear and foams easily. A cream cleanser is '
        'milky, makes little foam and leaves skin feeling softer. An '
        'oil cleanser is made to dissolve oil, makeup and sunscreen, '
        'and is rinsed or wiped away.',
  ),
  LearnEntry(
    id: 'prod-toner-essence',
    category: LearnCategory.productTypes,
    title: 'Toner or essence',
    body:
        'Both are thin, watery products used after cleansing. A toner '
        'is the step that follows a cleanser. An essence is a light, '
        'watery layer between cleanser and serum, popular in Korean '
        'routines. The line between them is blurry, and the label is '
        'the only guide.',
  ),
  LearnEntry(
    id: 'label-claims',
    category: LearnCategory.labels,
    title: 'Results words on a pack',
    body:
        'Lines such as erases wrinkles or instantly younger-looking '
        'describe a result the maker hopes for. They are the maker\'s '
        'own words, usually on the front. The ingredient list and the '
        'symbols on the back hold the facts.',
  ),
  LearnEntry(
    id: 'life-teens',
    category: LearnCategory.lifeStages,
    title: 'Skin in the teen years',
    body:
        'Hormones rise at puberty and make the oil glands larger and '
        'busier, so many teenagers notice shinier skin and breakouts. '
        'It is very common, and it often eases through the late teens '
        'and twenties, though not for everyone.',
  ),
  LearnEntry(
    id: 'life-twenties-thirties',
    category: LearnCategory.lifeStages,
    title: 'Skin in the twenties and thirties',
    body:
        'Skin renews itself a little more slowly with each decade. Many '
        'people in these years see the first fine lines around the '
        'eyes, and sun from earlier years begins to show as uneven '
        'tone. Breakouts can still come and go, often with stress and '
        'with monthly cycles.',
  ),
  LearnEntry(
    id: 'life-pregnancy',
    category: LearnCategory.lifeStages,
    title: 'Skin during pregnancy',
    body:
        'Hormone changes in pregnancy alter skin for many people. Some '
        'notice darker patches on the face, a dark line down the belly, '
        'stretch marks, or a change in oiliness. Some products are not '
        'used in pregnancy, and for those questions a doctor is the '
        'right person to ask.',
  ),
  LearnEntry(
    id: 'life-midlife',
    category: LearnCategory.lifeStages,
    title: 'Skin around menopause',
    body:
        'When oestrogen falls around menopause, skin tends to become '
        'drier and thinner and holds less collagen. Many people notice '
        'more dryness and more visible lines in these years, and for '
        'some, breakouts return.',
  ),
  LearnEntry(
    id: 'life-later',
    category: LearnCategory.lifeStages,
    title: 'Skin in later life',
    body:
        'With age the outer layer renews more slowly, and skin holds '
        'less fat and water. It can bruise more easily and recovers '
        'more slowly after a cut or scrape. Dry, itchy skin is common, '
        'and often worse in winter.',
  ),
  LearnEntry(
    id: 'life-tone-ageing',
    category: LearnCategory.lifeStages,
    title: 'Skin tone and how skin ages',
    body:
        'Skin with more melanin tends to show fine lines later, but '
        'dark marks can show up more easily after a breakout or an '
        'injury. Every skin tone ages, and every skin tone can burn in '
        'the sun.',
  ),
  LearnEntry(
    id: 'cook-simmer',
    category: LearnCategory.cookingWords,
    title: 'Simmer, boil and poach',
    body:
        'Boiling is bubbles breaking hard across the surface. Simmering '
        'is gentler, with small bubbles now and then. Poaching cooks '
        'food in liquid just below a simmer, as for eggs and fish.',
  ),
  LearnEntry(
    id: 'cook-blanch',
    category: LearnCategory.cookingWords,
    title: 'Blanch',
    body:
        'To drop food briefly into boiling water and then into cold '
        'water. It cooks the outside a little, loosens the skins of '
        'tomatoes and almonds, and keeps green vegetables bright.',
  ),
  LearnEntry(
    id: 'cook-fry',
    category: LearnCategory.cookingWords,
    title: 'Saute, shallow fry and deep fry',
    body:
        'Saute means cooking in a little fat over fairly high heat, '
        'stirring often. Shallow frying uses fat to about halfway up '
        'the food. Deep frying covers the food completely.',
  ),
  LearnEntry(
    id: 'cook-temper',
    category: LearnCategory.cookingWords,
    title: 'Tempering (tadka, chhaunk)',
    body:
        'Hot oil or ghee with whole spices such as cumin and mustard '
        'seeds, poured over a dish or cooked at the start of it. The '
        'hot fat lets the spices give up their flavour. It goes by '
        'tadka, chhaunk or baghar in different places.',
  ),
  LearnEntry(
    id: 'cook-bhuna',
    category: LearnCategory.cookingWords,
    title: 'Bhuna',
    body:
        'To fry onion, ginger, garlic and spices slowly, stirring, '
        'until the oil separates from the paste. Many Indian curries '
        'begin this way, and it is the step that takes the longest.',
  ),
  LearnEntry(
    id: 'cook-fold-whisk',
    category: LearnCategory.cookingWords,
    title: 'Fold, whisk and cream',
    body:
        'Folding turns a light mixture over gently so the air stays in, '
        'as with whipped egg whites. Whisking beats air in. Creaming '
        'beats butter and sugar together until pale and soft.',
  ),
  LearnEntry(
    id: 'cook-knead-prove',
    category: LearnCategory.cookingWords,
    title: 'Knead, prove and rest',
    body:
        'Kneading works dough so that it stretches. Proving leaves '
        'yeast dough to rise. Resting lets a dough relax, or lets '
        'cooked meat settle before it is cut.',
  ),
  LearnEntry(
    id: 'cook-reduce',
    category: LearnCategory.cookingWords,
    title: 'Reduce',
    body:
        'To boil or simmer a liquid, uncovered, until some of the water '
        'has gone and what is left is thicker and stronger in flavour.',
  ),
  LearnEntry(
    id: 'spice-garam-masala',
    category: LearnCategory.spicesStaples,
    title: 'Garam masala',
    body:
        'A blend of ground spices, often cumin, coriander, cardamom, '
        'cinnamon, cloves and black pepper. The mix differs from home '
        'to home and region to region. It is usually added near the end '
        'of cooking, so that its smell stays bright.',
  ),
  LearnEntry(
    id: 'spice-hing',
    category: LearnCategory.spicesStaples,
    title: 'Hing (asafoetida)',
    body:
        'A resin from the roots of a giant fennel plant, sold as a '
        'powder and often mixed with flour. It smells strong when raw '
        'and mellows in hot oil into something like cooked onion and '
        'garlic. A pinch is enough.',
  ),
  LearnEntry(
    id: 'spice-ghee',
    category: LearnCategory.spicesStaples,
    title: 'Ghee',
    body:
        'Butter cooked until the water has boiled off and the milk '
        'solids have browned and been strained out, leaving a golden '
        'fat. It keeps well, smells nutty, and can be heated higher '
        'than butter.',
  ),
  LearnEntry(
    id: 'spice-tamarind',
    category: LearnCategory.spicesStaples,
    title: 'Tamarind',
    body:
        'The sticky, sour pulp from the pods of the tamarind tree. It '
        'is soaked and strained, or bought as a paste, and used in '
        'chutneys, sambar, curries and drinks.',
  ),
  LearnEntry(
    id: 'spice-turmeric-food',
    category: LearnCategory.spicesStaples,
    title: 'Turmeric in cooking',
    body:
        'A yellow root, dried and ground, used for its colour and its '
        'warm, earthy, slightly bitter taste. It stains cloth, plastic '
        'and chopping boards.',
  ),
  LearnEntry(
    id: 'spice-cumin-coriander',
    category: LearnCategory.spicesStaples,
    title: 'Cumin and coriander seeds',
    body:
        'Two of the most common seeds in Indian, Middle Eastern and '
        'Mexican food. Cumin is earthy and warm. Coriander seed is '
        'lemony and mild, and comes from the same plant as the fresh '
        'leaves called cilantro.',
  ),
  LearnEntry(
    id: 'spice-mustard-seeds',
    category: LearnCategory.spicesStaples,
    title: 'Mustard seeds',
    body:
        'Small black, brown or yellow seeds. In hot oil they pop and '
        'turn nutty. They are used whole in tempering, and ground into '
        'mustard.',
  ),
  LearnEntry(
    id: 'spice-chilli-heat',
    category: LearnCategory.spicesStaples,
    title: 'How chillies carry heat',
    body:
        'Chillies get their heat from capsaicin, which sits mostly in '
        'the white ribs and the seeds. Dried and ground chillies vary '
        'widely in heat, and Kashmiri chilli is mild and mostly adds '
        'colour.',
  ),
  LearnEntry(
    id: 'spice-paneer',
    category: LearnCategory.spicesStaples,
    title: 'Paneer',
    body:
        'A fresh cheese made by curdling hot milk with lemon juice or '
        'vinegar and pressing the curds. It does not melt, so it holds '
        'its shape in curries and on skewers.',
  ),
  LearnEntry(
    id: 'staple-dal',
    category: LearnCategory.spicesStaples,
    title: 'Dal',
    body:
        'The word means both split dried pulses and the dish made from '
        'them. Toor, moong, masoor and chana are common kinds. Washed '
        'and simmered until soft, they are the base of many everyday '
        'meals.',
  ),
  LearnEntry(
    id: 'staple-atta',
    category: LearnCategory.spicesStaples,
    title: 'Atta',
    body:
        'Wholewheat flour ground finely, used for roti, chapati and '
        'paratha. It takes up more water than plain white flour, so the '
        'dough is softer and is rested before rolling.',
  ),
  LearnEntry(
    id: 'readings-facial-hair',
    category: LearnCategory.readings,
    title: 'Facial hair and your readings',
    body:
        'A beard, stubble or a moustache covers part of the skin the '
        'measurements look at, so the photo shows hair as well as skin. '
        'Hair can read as texture, as larger pores or as uneven tone, '
        'and it hides the skin under it. A clean-shaven face and a '
        'bearded one are not like for like.',
  ),
  LearnEntry(
    id: 'readings-shave',
    category: LearnCategory.readings,
    title: 'Shaving, trimming and the day after',
    body:
        'A fresh shave can leave skin pink or rough for a few hours, '
        'which can show as more redness or texture. A day or two of '
        'stubble looks different again, and so does a beard that has '
        'just been trimmed. Many people who follow a trend take their '
        'readings at the same point relative to shaving.',
  ),
  LearnEntry(
    id: 'readings-makeup-detail',
    category: LearnCategory.readings,
    title: 'What makeup does to each measurement',
    body:
        'Foundation and concealer cover redness, spots and uneven tone, '
        'so those can read clearer than bare skin does. Powder and '
        'primer soften shine and can make pores look smaller. Blush and '
        'bronzer add colour that can read as redness or uneven tone, '
        'and shimmer catches the light as shine.',
  ),
  LearnEntry(
    id: 'readings-bare-vs-made-up',
    category: LearnCategory.readings,
    title: 'A made-up face and a bare one are different readings',
    body:
        'A reading with makeup on describes the makeup as much as the '
        'skin, and the app cannot tell which is which. A bare-faced '
        'reading and a made-up one are two different measurements. Many '
        'people keep them apart, for example by taking readings only '
        'bare-faced, or only before makeup.',
  ),
  LearnEntry(
    id: 'readings-skin-tone',
    category: LearnCategory.readings,
    title: 'Skin tone and readings',
    body:
        'Cameras see different skin tones differently, most of all in '
        'dim light, and phones process photos in their own ways. Two '
        'people with different skin tones can read differently for '
        'reasons that have more to do with light and camera than with '
        'skin. Readings compare best with your own earlier ones, taken '
        'in the same light.',
  ),
  LearnEntry(
    id: 'habit-heavy-makeup-days',
    category: LearnCategory.habits,
    title: 'Heavy makeup days and the days after',
    body:
        'Long days in heavy makeup, hot lights and late nights are '
        'common at weddings and festivals. Skin can look and feel '
        'different the next day, and a reading then may describe the '
        'occasion as much as the skin. Readings taken a few days later '
        'often settle back to the usual range.',
  ),
  LearnEntry(
    id: 'sun-flight-air',
    category: LearnCategory.sun,
    title: 'Long flights and dry cabin air',
    body:
        'The air inside an aeroplane cabin is very dry, and skin can '
        'feel tight after a long flight. Time zones also change when '
        'people sleep and eat. Readings in the days after travel may '
        'differ from the usual range for those reasons.',
  ),
  LearnEntry(
    id: 'label-clean-natural',
    category: LearnCategory.labels,
    title: 'Clean, natural and organic on a label',
    body:
        'These words are used on many packs, and in many countries none '
        'of them has one strict legal meaning for skin-care products. '
        'They describe what a maker chose to emphasise. The ingredient '
        'list on the back says what is actually in the product.',
  ),
  LearnEntry(
    id: 'label-patch-test',
    category: LearnCategory.labels,
    title: 'What a patch test is',
    body:
        'A patch test means putting a small amount of a product on a '
        'small patch of skin, such as the inner forearm, and watching '
        'it for a day or two to see whether the skin reacts. Makers and '
        'many dermatologists describe it as a way to check for a '
        'reaction before a product is used more widely.',
  ),
  LearnEntry(
    id: 'label-ph',
    category: LearnCategory.labels,
    title: 'What pH-balanced means',
    body:
        'pH is a measure of how acidic or alkaline something is. '
        'Skin\'s surface is slightly acidic, and pH-balanced on a label '
        'means the maker aimed for a product close to that. There is no '
        'single standard behind the words, so they describe what the '
        'maker intended.',
  ),
  LearnEntry(
    id: 'food-label-datemarks',
    category: LearnCategory.foodLabels,
    title: 'Use-by and best-before',
    body:
        'A use-by date is about safety: after it, the food is not meant '
        'to be eaten. A best-before date is about quality: after it, '
        'the food may be less good but is usually still safe if it has '
        'been kept properly. Many packs carry one or the other, not '
        'both.',
  ),
  LearnEntry(
    id: 'food-label-sugarnames',
    category: LearnCategory.foodLabels,
    title: 'Sugar by other names',
    body:
        'Sugar can appear on an ingredient list under many names, such '
        'as syrup, honey, jaggery, glucose, fructose, dextrose or fruit '
        'juice concentrate. Each is a form of sugar. Listing them '
        'separately can spread sugar across several lines of the list.',
  ),
  LearnEntry(
    id: 'food-label-salt',
    category: LearnCategory.foodLabels,
    title: 'Salt and sodium on a label',
    body:
        'Many labels show sodium, not salt. Sodium is one part of salt, '
        'about 40 percent of it by weight, so 1 gram of sodium is about '
        '2.5 grams of salt. Some labels give both numbers and some give '
        'only one, so it helps to know which is shown.',
  ),
];

/// Clusters of notes that belong together. Each note's "Also see" links are the
/// other members of the clusters it sits in, so the links run both ways.
const List<List<String>> kLearnLinks = [
  [
    'prod-sunscreen',
    'label-spf',
    'ingredient-mineral-filters',
    'ingredient-chemical-filters',
  ],
  ['sun-cloud', 'sun-index', 'sun-glass', 'sun-tone'],
  ['sun-amount', 'sun-shade', 'prod-sunscreen'],
  [
    'readings-makeup',
    'readings-makeup-detail',
    'readings-bare-vs-made-up',
    'habit-heavy-makeup-days',
  ],
  ['readings-light', 'readings-time', 'readings-makeup', 'readings-angle'],
  [
    'readings-facial-hair',
    'readings-shave',
    'readings-m-texture',
    'readings-m-pores',
  ],
  ['readings-skin-tone', 'readings-light', 'readings-phone', 'sun-tone'],
  [
    'label-clean-natural',
    'label-hypoallergenic',
    'label-patch-test',
    'label-ph',
  ],
  ['food-label-sugarnames', 'food-label-sugars', 'food-label-order'],
  ['food-label-datemarks', 'food-label-front'],
  ['readings-phone', 'readings-trend', 'sleep-one-night'],
  ['readings-seven', 'skin-layers'],
  ['move-flush', 'readings-time', 'move-sweat'],
  [
    'skin-barrier',
    'prod-moisturiser',
    'ingredient-ceramides',
    'ingredient-petrolatum',
    'ingredient-glycerin',
  ],
  ['skin-sebum', 'skin-pores', 'ingredient-salicylic-acid', 'prod-cleanser'],
  ['skin-collagen', 'ingredient-peptides'],
  [
    'ingredient-retinol',
    'ingredient-tretinoin',
    'ingredient-adapalene',
    'ingredient-bakuchiol',
  ],
  [
    'ingredient-salicylic-acid',
    'ingredient-alpha-hydroxy-acids',
    'prod-exfoliant',
    'ingredient-benzoyl-peroxide',
  ],
  ['prod-serum', 'prod-essence', 'prod-toner'],
  [
    'label-fragrance',
    'ingredient-fragrance',
    'label-hypoallergenic',
    'habit-one-change',
  ],
  ['label-noncomedogenic', 'skin-pores', 'label-derm-tested'],
  ['label-pao', 'label-order', 'ingredient-preservatives'],
  ['ingredient-surfactants', 'prod-cleanser', 'habit-gentle'],
  ['skin-melanin', 'sun-tone', 'skin-types'],
  ['skin-renewal', 'food-slow', 'sleep-repair'],
  ['ingredient-hyaluronic-acid', 'prod-serum', 'water-elasticity'],
  ['sleep-rhythm', 'sleep-repair', 'sleep-pillowcase'],
  ['stress-delay', 'stress-talk', 'sleep-one-night'],
  ['ingredient-vitamin-c', 'ingredient-vitamin-e', 'ingredient-niacinamide'],
  ['habit-evening', 'habit-things', 'prod-cleanser'],
  ['sun-humid', 'sun-monsoon', 'sun-dry-air', 'sun-air', 'water-hard'],
];

/// The notes that go with [id], at most [limit], in the order the clusters
/// list them.
List<LearnEntry> learnRelated(String id, {int limit = 4}) {
  final seen = <String>{id};
  final out = <LearnEntry>[];
  for (final cluster in kLearnLinks) {
    if (!cluster.contains(id)) continue;
    for (final other in cluster) {
      if (!seen.add(other)) continue;
      final e = learnEntry(other);
      if (e != null) out.add(e);
      if (out.length == limit) return out;
    }
  }
  return out;
}

/// Notes whose title or text hold every word of [query], the ones with the
/// words in the title first. Empty for an empty query.
List<LearnEntry> learnSearch(String query, {int limit = 40}) {
  final words = [
    for (final w in query.toLowerCase().split(RegExp(r'\s+')))
      if (w.isNotEmpty) w,
  ];
  if (words.isEmpty) return const [];
  final inTitle = <LearnEntry>[];
  final inText = <LearnEntry>[];
  for (final e in kLearnEntries) {
    if (!learnGroupsShown.contains(e.category.group)) continue;
    // the other names on a label count as the title
    final title = '${e.title} ${e.aka.join(' ')}'.toLowerCase();
    final rest = '${e.body} ${e.category.title}'.toLowerCase();
    if (words.every(title.contains)) {
      inTitle.add(e);
    } else if (words.every((w) => title.contains(w) || rest.contains(w))) {
      inText.add(e);
    }
  }
  return [...inTitle, ...inText].take(limit).toList();
}

/// The themes whose notes are definitions, so the A to Z lists them.
const Set<LearnCategory> kGlossaryThemes = {
  LearnCategory.cookingWords,
  LearnCategory.spicesStaples,
  LearnCategory.nutrients,
  LearnCategory.foodLabels,
  LearnCategory.skinBasics,
  LearnCategory.productTypes,
  LearnCategory.labels,
  LearnCategory.ingredients,
};

String _sortKey(String title) =>
    title.toLowerCase().replaceFirst(RegExp(r'^[^a-z0-9]+'), '');

/// The definitions in alphabetical order, for the A to Z.
List<LearnEntry> learnGlossary() => [
  for (final e in kLearnEntries)
    if (kGlossaryThemes.contains(e.category) &&
        learnGroupsShown.contains(e.category.group))
      e,
]..sort((a, b) => _sortKey(a.title).compareTo(_sortKey(b.title)));

/// The letter a glossary entry is filed under.
String learnGlossaryLetter(LearnEntry e) {
  final k = _sortKey(e.title);
  return k.isEmpty ? '#' : k[0].toUpperCase();
}

/// Who read the notes, if the owner wants a line saying so on the "Where these
/// notes come from" page: set it only when it is true, for example 'Dr. A.'.
const String? kLearnReviewedBy = null;

/// Which groups of themes an app shows. A skin app shows the skin groups, a
/// food app (Kitchen, Lifestyle) sets this to just [LearnGroup.food] in main().
Set<LearnGroup> learnGroupsShown = {
  LearnGroup.skin,
  LearnGroup.everyday,
  LearnGroup.products,
};

/// The themes this app shows, in the order written.
List<LearnCategory> learnCategoriesShown() => [
  for (final c in LearnCategory.values)
    if (learnGroupsShown.contains(c.group)) c,
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

/// The note shown as "Did you know?" on [day]: the same one all day, a different
/// one tomorrow, every note once before any repeats. The skin-care ingredient
/// notes are left out, so a daily note never reads like a product pointer.
LearnEntry learnNoteOfDay(DateTime day) {
  final pool = [
    for (final e in kLearnEntries)
      if (e.category != LearnCategory.ingredients &&
          learnGroupsShown.contains(e.category.group))
        e,
  ];
  final n = pool.length;
  // a step that shares no factor with n, so the walk visits every note
  var step = (n * 0.618).round();
  int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
  while (gcd(step, n) != 1) {
    step++;
  }
  final days = DateTime.utc(
    day.year,
    day.month,
    day.day,
  ).difference(DateTime.utc(2026)).inDays;
  return pool[((days % n) * step) % n];
}

/// The first sentence of a note's text, for a short card.
String learnFirstSentence(LearnEntry e) {
  final m = RegExp(r'^(.+?[.!?])(\s|$)', dotAll: true).firstMatch(e.body);
  return (m?.group(1) ?? e.body).replaceAll(RegExp(r'\s+'), ' ');
}
