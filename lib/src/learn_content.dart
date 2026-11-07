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
//   - Eleven themes in three groups; a theme needs at least three notes.
//
// DRAFT: to be read by a clinician and by the lawyer before a store release.

import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// The three parts of the portal: what themes sit together on its front page.
enum LearnGroup {
  skin('Your skin'),
  everyday('Everyday life'),
  products('Products and labels');

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
    id: 'sun-monsoon',
    category: LearnCategory.sun,
    title: 'Rainy and humid seasons',
    body:
        'In a rainy season the air is heavy with moisture, and skin '
        'often feels oilier and stickier because sweat stays on it '
        'longer. Cloud still lets a good share of UV through.',
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
  ),
  LearnEntry(
    id: 'ingredient-urea',
    category: LearnCategory.ingredients,
    title: 'Urea',
    body:
        'A substance the body makes naturally, also made in '
        'laboratories, that attracts water. It is found in many '
        'moisturisers, especially creams for hands and feet.',
  ),
  LearnEntry(
    id: 'ingredient-sulfur',
    category: LearnCategory.ingredients,
    title: 'Sulfur',
    body:
        'A natural element that has been used in skin products for a '
        'very long time. It is found in some acne masks and spot '
        'products, and in some shampoos.',
  ),
  LearnEntry(
    id: 'ingredient-clay',
    category: LearnCategory.ingredients,
    title: 'Clay (kaolin and bentonite)',
    body:
        'Fine mineral powders that soak up oil and water. They are found '
        'in many face masks and in some cleansers.',
  ),
  LearnEntry(
    id: 'ingredient-aloe-vera',
    category: LearnCategory.ingredients,
    title: 'Aloe vera',
    body:
        'A gel taken from the leaves of the aloe plant, and mostly '
        'water. It is found in many gels, lotions and after-sun '
        'products.',
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
  ),
  LearnEntry(
    id: 'ingredient-dimethicone',
    category: LearnCategory.ingredients,
    title: 'Dimethicone',
    body:
        'A silicone: a smooth, slippery liquid that sits on top of skin '
        'and leaves it feeling soft. It is found in many primers, '
        'moisturisers and sunscreens.',
  ),
  LearnEntry(
    id: 'ingredient-caffeine',
    category: LearnCategory.ingredients,
    title: 'Caffeine',
    body:
        'The same compound that is in coffee and tea, also made in '
        'laboratories. It is found in some eye creams and serums.',
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
  ),
  LearnEntry(
    id: 'ingredient-centella',
    category: LearnCategory.ingredients,
    title: 'Centella asiatica (cica)',
    body:
        'A herb that grows in wet places across Asia and is often called '
        'cica or tiger grass. It is found in many serums, creams and '
        'masks, especially ones from Korea.',
  ),
  LearnEntry(
    id: 'ingredient-colloidal-oatmeal',
    category: LearnCategory.ingredients,
    title: 'Colloidal oatmeal',
    body:
        'Oats ground so finely that they stay suspended in liquid. It is '
        'found in many creams, lotions and bath products.',
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
  ['readings-light', 'readings-time', 'readings-makeup', 'readings-angle'],
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
    final title = e.title.toLowerCase();
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
    if (kGlossaryThemes.contains(e.category)) e,
]..sort((a, b) => _sortKey(a.title).compareTo(_sortKey(b.title)));

/// The letter a glossary entry is filed under.
String learnGlossaryLetter(LearnEntry e) {
  final k = _sortKey(e.title);
  return k.isEmpty ? '#' : k[0].toUpperCase();
}

/// Who read the notes, if the owner wants a line saying so on the "Where these
/// notes come from" page: set it only when it is true, for example 'Dr. A.'.
const String? kLearnReviewedBy = null;

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
