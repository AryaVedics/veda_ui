// Copy of Véda's template (flutter_app/lib/data/learn_quiz.dart). Keep in step.
//
// Both games are gentle on purpose: no score to lose, no timer, no streak. A
// wrong answer only shows the answer and a warm explanation, with a link to the
// note it came from. Every question is about a fact that one note already
// states, and keeps the same rules as the notes (see learn_content.dart and
// test/learn_quiz_test.dart): descriptive, never a prescription.

import 'learn_content.dart';

/// One "Which is it?" question: [options] are shown in a shuffled order, and
/// [correct] is the index of the right one in this list.
class QuizQuestion {
  const QuizQuestion(
    this.noteId,
    this.prompt,
    this.options,
    this.correct,
    this.explanation, {
    this.snippet,
  });

  /// For Label Detective: the bit of a pack the question is about, shown in a
  /// little label above the question.
  final String? snippet;

  /// The note this question comes from, shown as "Read the note".
  final String noteId;
  final String prompt;
  final List<String> options;
  final int correct;
  final String explanation;

  LearnCategory get category => learnEntry(noteId)!.category;
}

/// A statement for Myth or fact: [isFact] says which, and [explanation] says
/// why, in the note's own words.
class MythCard {
  const MythCard(this.noteId, this.statement, this.isFact, this.explanation);

  final String noteId;
  final String statement;
  final bool isFact;
  final String explanation;
}

/// One pair for Ingredient Match: an ingredient and the kind of product it is
/// best known for. Within one round every kind of product is different, so a
/// pairing is never ambiguous.
class MatchPair {
  const MatchPair(this.noteId, this.ingredient, this.kind);

  final String noteId;
  final String ingredient;
  final String kind;
}

const List<QuizQuestion> kQuizQuestions = [
  // ---- food and nutrition
  QuizQuestion(
    'food-label-serving',
    'On a nutrition label, the numbers are for what amount?',
    ['One serving', 'The whole pack', 'Exactly 100 grams'],
    0,
    'The numbers are for one serving. A pack can hold more than one, so eating '
        'the whole pack means more than the label shows.',
  ),
  QuizQuestion(
    'food-label-order',
    'In many countries, which ingredient is listed first on a pack?',
    [
      'The one there is most of',
      'The one there is least of',
      'The one added last',
    ],
    0,
    'Ingredients are often listed by weight, largest first, so the first few '
        'names tell most of the story.',
  ),
  QuizQuestion(
    'food-label-sugars',
    'What does an added sugars line count?',
    [
      'Only sugars put in while the food was made',
      'All sugars, including those in fruit and milk',
      'Only sugars from sweet drinks',
    ],
    0,
    'Total sugars include natural ones in fruit and milk. Added sugars count '
        'only what went in during making.',
  ),
  QuizQuestion(
    'portion-dry-cooked',
    'Why does cooked rice weigh more than dry rice?',
    ['It soaks up water', 'It gains energy', 'It loses fibre'],
    0,
    'Rice soaks up water as it cooks, which adds weight but no energy.',
  ),
  QuizQuestion(
    'portion-vs-serving',
    'What is a serving?',
    [
      'The amount a label uses for its numbers',
      'Whatever ends up on the plate',
      'Always one cup',
    ],
    0,
    'A serving is the label\'s own amount. A portion is what a person actually '
        'serves, which may be smaller or larger.',
  ),
  QuizQuestion(
    'portion-measures',
    'Which gives the steadier answer for flour?',
    ['A kitchen scale', 'A scooped cup', 'A heaped spoon'],
    0,
    'A cup of flour can weigh quite different amounts depending on how it is '
        'scooped. A scale gives the same answer each time.',
  ),
  QuizQuestion(
    'nutrient-fat',
    'Which holds the most energy per gram?',
    ['Fat', 'Protein', 'Carbohydrate'],
    0,
    'Fat gives about 9 calories per gram. Protein and carbohydrate give about '
        '4 each.',
  ),
  QuizQuestion(
    'nutrient-fibre',
    'What is fibre?',
    [
      'The part of plant foods the body does not break down for energy',
      'A kind of fat',
      'A sugar found in milk',
    ],
    0,
    'Fibre is the part of plant foods that is not broken down for energy. '
        'Whole grains, beans, fruit and vegetables are common sources.',
  ),
  QuizQuestion(
    'nutrient-water',
    'Why is soup heavy but low in energy for its weight?',
    ['Much of its weight is water', 'It contains no food', 'It is cooked'],
    0,
    'Water adds weight but no energy, so watery foods are low in energy for '
        'their weight.',
  ),
  // ---- skin basics
  QuizQuestion(
    'skin-layers',
    'What is the outer layer of skin called?',
    ['The epidermis', 'The dermis', 'The hypodermis'],
    0,
    'The outer layer is the epidermis. The dermis is the middle layer, and '
        'below them sits a layer of fat.',
  ),
  QuizQuestion(
    'skin-renewal',
    'About how long does skin take to renew itself in young adults?',
    ['About a day', 'About a week', 'About a month'],
    2,
    'Cells made at the base of the epidermis slowly move to the surface and '
        'are shed. In young adults that takes roughly a month, and it slows '
        'down with age.',
  ),
  QuizQuestion(
    'skin-collagen',
    'Which two proteins give skin its firmness and its spring?',
    ['Collagen and elastin', 'Sebum and melanin', 'Keratin and sweat'],
    0,
    'Collagen and elastin live in the dermis. The body makes less of them '
        'with age, and years of sun can break them down faster.',
  ),
  QuizQuestion(
    'skin-sebum',
    'What is sebum?',
    ['The skin\'s own oil', 'A kind of sweat', 'A skin pigment'],
    0,
    'Glands attached to hair follicles make sebum, mostly on the face, scalp '
        'and upper body.',
  ),
  QuizQuestion(
    'skin-melanin',
    'What is melanin?',
    [
      'A pigment that gives skin its colour',
      'The skin\'s own oil',
      'A protein that gives skin its spring',
    ],
    0,
    'Melanin is made by cells in the epidermis. Skin makes more of it after '
        'time in the sun, which is what a tan is.',
  ),

  // ---- your readings
  QuizQuestion(
    'readings-light',
    'What helps readings stay comparable from one day to the next?',
    [
      'Similar light each time',
      'A different spot every day',
      'Taking them as fast as possible',
    ],
    0,
    'Colour, shine and shadow all change with the light, so readings are '
        'most comparable when the light is the same each time.',
  ),
  QuizQuestion(
    'readings-phone',
    'Two different phones read the same face. What is likely?',
    [
      'Slightly different numbers',
      'Exactly the same numbers',
      'The second phone will refuse',
    ],
    0,
    'Every phone camera sees skin a little differently, and a few of the '
        'seven measurements can differ quite a lot. The key is consistency: '
        'your own phone, in similar light.',
  ),
  QuizQuestion(
    'readings-trend',
    'What can several readings over weeks show that one reading cannot?',
    [
      'Which direction the numbers are moving',
      'Your exact age',
      'What the weather will be',
    ],
    0,
    'A single reading is one moment in one light. Several readings smooth '
        'out the light, the sleep and the time of day.',
  ),
  QuizQuestion(
    'readings-makeup',
    'Which of these can change shine and colour in a photo?',
    [
      'Makeup, a fresh cream or damp skin',
      'The phone\'s battery level',
      'The language of the app',
    ],
    0,
    'Makeup, sunscreen, a freshly applied cream or damp skin after washing '
        'can all change shine and colour.',
  ),
  QuizQuestion(
    'readings-seven',
    'How many measurements does the skin score look at?',
    ['Three', 'Seven', 'Twelve'],
    1,
    'Redness, texture, pores, spots, acne, evenness and wrinkles: seven '
        'measurements of how skin looks in a photo.',
  ),

  // ---- sleep and rest
  QuizQuestion(
    'sleep-repair',
    'When does skin renew itself most actively?',
    ['While you sleep', 'At midday', 'While you eat'],
    0,
    'Skin renews itself most actively during sleep, and blood flow to the '
        'skin tends to rise at night.',
  ),
  QuizQuestion(
    'sleep-rhythm',
    'What counts as much as the number of hours of sleep?',
    ['A steady bedtime', 'A loud alarm', 'A bright room'],
    0,
    'Going to sleep and waking at similar times helps the body keep its daily '
        'rhythm, and skin follows the same rhythm.',
  ),
  QuizQuestion(
    'sleep-pillowcase',
    'How often do many people change their pillowcase?',
    ['About once a week', 'Every day', 'Once a year'],
    0,
    'Pillowcases pick up oil, sweat and hair products. Many people change '
        'them about once a week.',
  ),
  QuizQuestion(
    'sleep-one-night',
    'A reading dips after one poor night. What is that?',
    ['A normal thing to see', 'A lasting change', 'A sign of something wrong'],
    0,
    'A single short night rarely shows for long. The trend over weeks is the '
        'better guide.',
  ),

  // ---- sun and weather
  QuizQuestion(
    'sun-cloud',
    'Does UV reach you on a cloudy day?',
    [
      'Yes, a good share passes through cloud',
      'No, cloud blocks all of it',
      'Only in winter',
    ],
    0,
    'A good share of ultraviolet light passes through cloud, which is why '
        'many dermatologists describe sun care as a year-round habit.',
  ),
  QuizQuestion(
    'sun-index',
    'At what UV index do health agencies such as the WHO advise sun '
        'protection?',
    ['3 or more', '8 or more', '11 only'],
    0,
    'The UV index runs from 0 up past 11, and sun protection is advised '
        'whenever it reaches 3 or more.',
  ),
  QuizQuestion(
    'sun-glass',
    'Ordinary window glass blocks most of which rays?',
    ['UVB', 'UVA', 'Both equally'],
    0,
    'Window glass blocks most UVB but lets a good part of UVA through, so a '
        'long drive still adds up over the years.',
  ),
  QuizQuestion(
    'sun-tone',
    'Which skin tones can burn?',
    ['Every skin tone', 'Only the palest', 'Only people with freckles'],
    0,
    'More melanin gives some natural protection, but people of every skin '
        'tone can burn.',
  ),
  QuizQuestion(
    'sun-shade',
    'Besides sunscreen, what lowers how much UV reaches skin?',
    ['Shade, hats and clothing', 'Drinking more water', 'Washing twice'],
    0,
    'Shade, a wide-brimmed hat, sunglasses and covering clothes all lower '
        'how much UV reaches the skin.',
  ),

  // ---- water and food
  QuizQuestion(
    'food-slow',
    'A change in how you eat or drink is best watched over...',
    ['Weeks', 'A single day', 'An hour'],
    0,
    'Skin renews itself over weeks, so changes are something to watch over '
        'weeks too, not days.',
  ),
  QuizQuestion(
    'water-elasticity',
    'What does being well hydrated support?',
    ['Skin\'s elasticity', 'Eye colour', 'Faster hair growth'],
    0,
    'Skin holds a lot of water, and being well hydrated supports its '
        'elasticity.',
  ),
  QuizQuestion(
    'water-hard',
    'What is hard water?',
    [
      'Water with a lot of dissolved minerals',
      'Frozen water',
      'Very hot water',
    ],
    0,
    'Water with a lot of dissolved minerals is called hard. Some people find '
        'it leaves skin feeling tight after washing.',
  ),
  QuizQuestion(
    'water-loss',
    'Research on drinking extra water for skin in particular is...',
    ['Still modest', 'Settled', 'Non-existent'],
    0,
    'Drinking enough keeps the body topped up, although research on extra '
        'water for skin in particular is still modest.',
  ),

  // ---- stress and mood
  QuizQuestion(
    'stress-delay',
    'When can stress show on skin?',
    ['A few days afterwards', 'Only in the same minute', 'It cannot'],
    0,
    'Stress does not always show in the moment. It can turn up on skin a few '
        'days afterwards.',
  ),
  QuizQuestion(
    'stress-quiet',
    'Which is an everyday way people ease stress?',
    [
      'Slow breathing or a short walk',
      'Checking the phone every minute',
      'Skipping sleep',
    ],
    0,
    'Slow breathing, a short walk or time outdoors are everyday ways people '
        'ease stress.',
  ),
  QuizQuestion(
    'stress-talk',
    'Stress hormones can affect...',
    [
      'Skin oil and irritation in some people',
      'Eye colour',
      'How tall someone grows',
    ],
    0,
    'Research suggests stress hormones can affect skin oil and irritation in '
        'some people.',
  ),

  // ---- exercise and sweat
  QuizQuestion(
    'move-sweat',
    'What is sweat mostly made of?',
    ['Water with a little salt', 'Oil', 'Sugar'],
    0,
    'Sweat is mostly water with a little salt, and it cools the body down.',
  ),
  QuizQuestion(
    'move-flush',
    'Why do faces often look redder after exercise?',
    [
      'Blood vessels near the skin widen as the body warms up',
      'The skin changes colour for good',
      'The camera adds red',
    ],
    0,
    'Blood vessels near the skin widen as the body warms up, so a reading '
        'taken right after exercise may show more redness.',
  ),
  QuizQuestion(
    'move-sweat',
    'Where does the smell people notice come from?',
    [
      'Sweat mixing with bacteria on skin',
      'Sweat itself',
      'The water they drink',
    ],
    0,
    'The smell comes later, when sweat mixes with the bacteria that live on '
        'skin.',
  ),
  QuizQuestion(
    'move-things',
    'What touches skin during a workout and collects sweat?',
    ['Towels, helmets and headbands', 'Only the air', 'Only shoes'],
    0,
    'Towels, helmets, masks, headbands and gym equipment all sit against '
        'skin. Many people wipe their face and rinse afterwards.',
  ),

  // ---- everyday habits
  QuizQuestion(
    'habit-gentle',
    'Many dermatologists suggest washing skin with...',
    ['Lukewarm water', 'Very hot water', 'Ice-cold water'],
    0,
    'Lukewarm water and patting dry, since very hot water and hard scrubbing '
        'can irritate.',
  ),
  QuizQuestion(
    'habit-hands',
    'Dermatologists generally advise against...',
    ['Picking or squeezing spots', 'Washing your hands', 'Drinking water'],
    0,
    'Picking can spread oil and bacteria and may leave a mark that outlasts '
        'the spot itself.',
  ),
  QuizQuestion(
    'habit-one-change',
    'When trying something new on skin, many dermatologists suggest '
        'changing...',
    ['One thing at a time', 'Everything at once', 'Three things a week'],
    0,
    'Changing one thing at a time makes it clear what agreed with you and '
        'what did not.',
  ),
  QuizQuestion(
    'habit-evening',
    'Many dermatologists suggest taking makeup off...',
    ['Before going to sleep', 'Only at weekends', 'Once a month'],
    0,
    'So it does not sit on the skin overnight.',
  ),

  // ---- product types
  QuizQuestion(
    'prod-serum',
    'Which product is a light, concentrated liquid that sits under a '
        'moisturiser?',
    ['A serum', 'A cleanser', 'An exfoliant'],
    0,
    'Serums often carry one or two featured ingredients in a thin texture '
        'that soaks in quickly.',
  ),
  QuizQuestion(
    'prod-cleanser',
    'What does a cleanser do?',
    [
      'Lifts away oil, sweat, sunscreen and makeup, then rinses off',
      'Stays on skin all day',
      'Replaces sunscreen',
    ],
    0,
    'A cleanser comes as a gel, foam, cream, oil or balm, and rinses off.',
  ),
  QuizQuestion(
    'prod-exfoliant',
    'What is an exfoliant?',
    [
      'A product that loosens or removes dead cells from the surface',
      'A kind of sunscreen',
      'A thin liquid used before cleansing',
    ],
    0,
    'It works either by rubbing (a scrub) or with acids or enzymes (a '
        'chemical exfoliant).',
  ),
  QuizQuestion(
    'prod-sunscreen',
    'Which product\'s label carries an SPF number?',
    ['Sunscreen', 'Toner', 'Face mask'],
    0,
    'A sunscreen has filters that absorb or reflect ultraviolet light, and '
        'its label carries an SPF number.',
  ),
  QuizQuestion(
    'prod-essence',
    'Which product has a blurry line between it, toner and serum?',
    ['Essence', 'Cleanser', 'Sunscreen'],
    0,
    'An essence is a watery, lightweight layer, and makers use the words '
        'essence, toner and serum differently.',
  ),

  // ---- reading a label
  QuizQuestion(
    'label-fragrance',
    'What does fragrance-free mean?',
    [
      'No fragrance ingredients were added',
      'The product has no smell at all',
      'The scent is from nature',
    ],
    0,
    'Unscented is different: it can mean other ingredients cover or soften '
        'the smell.',
  ),
  QuizQuestion(
    'label-pao',
    'What does the open-jar symbol with a number and an M, such as 12M, show?',
    [
      'How many months a product is usually kept after opening',
      'The month it was made',
      'Where it was made',
    ],
    0,
    'It is separate from the date printed on the pack.',
  ),
  QuizQuestion(
    'label-spf',
    'SPF is a number about protection from which rays?',
    ['UVB, the rays that cause sunburn', 'X-rays', 'Infrared'],
    0,
    'PA, shown with plus signs, is a rating for UVA, and broad spectrum means '
        'protection against both.',
  ),
  QuizQuestion(
    'label-order',
    'On an ingredient list, ingredients are usually listed...',
    ['From the most to the least by amount', 'Alphabetically', 'By price'],
    0,
    'Anything below about one percent can come in any order.',
  ),
  QuizQuestion(
    'label-noncomedogenic',
    'Is non-comedogenic backed by one standard test?',
    [
      'No, it is a maker\'s description',
      'Yes, a legal test',
      'Yes, an international test',
    ],
    0,
    'There is no single standard test behind the word, so it is a '
        'description rather than a promise.',
  ),

  // ---- skin-care ingredients
  QuizQuestion(
    'ingredient-salicylic-acid',
    'Which ingredient is a beta hydroxy acid, often shortened to BHA?',
    ['Salicylic acid', 'Glycerin', 'Urea'],
    0,
    'It is found in many acne products, such as cleansers, toners and spot '
        'products.',
  ),
  QuizQuestion(
    'ingredient-niacinamide',
    'Another name for vitamin B3 is...',
    ['Niacinamide', 'Ceramide', 'Panthenol'],
    0,
    'Niacinamide is a nutrient that is also used in many serums, '
        'moisturisers and toners.',
  ),
  QuizQuestion(
    'ingredient-panthenol',
    'Which ingredient is a form of vitamin B5?',
    ['Panthenol', 'Squalane', 'Bakuchiol'],
    0,
    'Panthenol is found in many moisturisers, lip balms and hair products.',
  ),
  QuizQuestion(
    'ingredient-mineral-filters',
    'Which two minerals are the mineral sunscreen filters?',
    [
      'Zinc oxide and titanium dioxide',
      'Avobenzone and oxybenzone',
      'Clay and sulfur',
    ],
    0,
    'Avobenzone and oxybenzone belong to the other group, the chemical '
        'filters.',
  ),
  QuizQuestion(
    'ingredient-dimethicone',
    'What is dimethicone?',
    [
      'A silicone that leaves skin feeling soft',
      'A kind of vitamin',
      'A plant oil',
    ],
    0,
    'It is found in many primers, moisturisers and sunscreens.',
  ),
  QuizQuestion(
    'ingredient-retinol',
    'Retinoids are known to carry risks in...',
    ['Pregnancy', 'Swimming', 'Winter'],
    0,
    'Many guidelines advise speaking with a doctor before using them while '
        'pregnant or trying to conceive.',
  ),
  QuizQuestion(
    'ingredient-squalane',
    'What is squalane?',
    [
      'A light oil, often made from olives or sugar cane',
      'A mineral',
      'A preservative',
    ],
    0,
    'It is found in some moisturisers and facial oils.',
  ),
];

/// Label Detective: what the words and symbols on a pack mean.
const List<QuizQuestion> kLabelQuestions = [
  QuizQuestion(
    'label-noncomedogenic',
    'What does this mean?',
    [
      'Made not to clog pores, in the maker\'s own words',
      'Passed a government test',
      'Safe for every skin type',
    ],
    0,
    'There is no single standard test behind the word, so it is a '
        'description rather than a promise.',
    snippet: 'Non-comedogenic',
  ),
  QuizQuestion(
    'label-fragrance',
    'What does this mean?',
    [
      'No fragrance ingredients were added',
      'The product has no smell at all',
      'It holds no plant ingredients',
    ],
    0,
    'The product can still have a smell of its own from its other '
        'ingredients.',
    snippet: 'Fragrance-free',
  ),
  QuizQuestion(
    'label-fragrance',
    'What can this mean?',
    [
      'Other ingredients may cover or soften the smell',
      'A mild perfume was added on purpose',
      'The product holds nothing with a scent',
    ],
    0,
    'Unscented is not the same as fragrance-free: it can mean ingredients '
        'that cover or soften a smell.',
    snippet: 'Unscented',
  ),
  QuizQuestion(
    'label-hypoallergenic',
    'What does this mean?',
    [
      'Made to cause fewer allergic reactions, in the maker\'s words',
      'It cannot cause an allergic reaction',
      'A doctor approved it for everyone',
    ],
    0,
    'In many countries the word has no strict legal meaning, so it describes '
        'what the maker intended.',
    snippet: 'Hypoallergenic',
  ),
  QuizQuestion(
    'label-derm-tested',
    'What does this mean?',
    [
      'A dermatologist took part in testing, in some way',
      'Every dermatologist agrees with it',
      'It is only sold in clinics',
    ],
    0,
    'The phrase does not say how much testing was done or what kind.',
    snippet: 'Dermatologist-tested',
  ),
  QuizQuestion(
    'label-pao',
    'What does this symbol show?',
    [
      'It is usually kept 12 months after opening',
      'It was made 12 months ago',
      'It stays on skin for 12 minutes',
    ],
    0,
    'The open jar with a number and an M shows the months a product is '
        'usually kept once opened. It is separate from the date on the pack.',
    snippet: 'Open jar  12M',
  ),
  QuizQuestion(
    'label-spf',
    'What do these two ratings tell you?',
    [
      'SPF is about UVB, PA is about UVA',
      'SPF is about UVA, PA is about UVB',
      'Both are the strength of the scent',
    ],
    0,
    'SPF is a number for UVB, the rays that cause sunburn. PA, shown with plus '
        'signs, is a rating for UVA.',
    snippet: 'SPF 50  PA+++',
  ),
  QuizQuestion(
    'label-spf',
    'What does this mean?',
    [
      'Protection against both UVA and UVB',
      'Protection against heat',
      'Made for the whole body only',
    ],
    0,
    'Broad spectrum means protection against both kinds of ultraviolet light.',
    snippet: 'Broad spectrum',
  ),
];

/// Myth or fact: short statements, each tied to a note.
const List<MythCard> kMythCards = [
  MythCard(
    'sun-cloud',
    'You can only burn on a sunny day.',
    false,
    'A good share of ultraviolet light passes through cloud.',
  ),
  MythCard(
    'sun-tone',
    'Only people with pale skin can burn.',
    false,
    'More melanin gives some natural protection, but people of every skin '
        'tone can burn.',
  ),
  MythCard(
    'sun-glass',
    'Window glass blocks all UV.',
    false,
    'Window glass blocks most UVB but lets a good part of UVA through.',
  ),
  MythCard(
    'skin-renewal',
    'In young adults, skin renews itself about every month.',
    true,
    'Cells made at the base of the epidermis slowly move to the surface and '
        'are shed, in roughly a month, and it slows with age.',
  ),
  MythCard(
    'sleep-one-night',
    'One poor night of sleep changes your skin for weeks.',
    false,
    'A single short night rarely shows for long. The trend over weeks is the '
        'better guide.',
  ),
  MythCard(
    'readings-phone',
    'Two phones can give different readings for the same face.',
    true,
    'Every phone camera sees skin a little differently, which is why the key '
        'is to keep to your own phone.',
  ),
  MythCard(
    'move-flush',
    'A flushed face after exercise is normal.',
    true,
    'Blood vessels near the skin widen as the body warms up.',
  ),
  MythCard(
    'label-hypoallergenic',
    'Hypoallergenic has a strict legal meaning everywhere.',
    false,
    'In many countries the word has no strict legal meaning.',
  ),
  MythCard(
    'label-fragrance',
    'Fragrance-free and unscented mean exactly the same thing.',
    false,
    'Unscented can mean other ingredients cover or soften a smell.',
  ),
  MythCard(
    'label-order',
    'Ingredient lists run from the most to the least by amount.',
    true,
    'Mostly: anything below about one percent can come in any order.',
  ),
  MythCard(
    'water-hard',
    'Hard water is water with a lot of dissolved minerals in it.',
    true,
    'Some people find it leaves skin feeling tight after washing.',
  ),
  MythCard(
    'skin-pores',
    'How big pores are is largely set by genetics.',
    true,
    'They can look larger when they hold oil and dead cells, or as skin loses '
        'firmness with age.',
  ),
  MythCard(
    'skin-sebum',
    'Sebum is just another word for sweat.',
    false,
    'Sebum is the skin\'s own oil, made by glands attached to hair follicles.',
  ),
  MythCard(
    'skin-melanin',
    'Skin makes more melanin after time in the sun.',
    true,
    'That is what a tan is.',
  ),
  MythCard(
    'readings-trend',
    'A single reading tells you more than weeks of readings.',
    false,
    'A single reading is one moment in one light. Several readings over weeks '
        'show which way the numbers are moving.',
  ),
  MythCard(
    'habit-gentle',
    'Very hot water is the gentlest way to wash skin.',
    false,
    'Many dermatologists suggest lukewarm water, since very hot water and '
        'hard scrubbing can irritate.',
  ),
];

/// The pairs Ingredient Match deals from. Every kind of product is different
/// from every other, so any four can share a round.
const List<MatchPair> kMatchPairs = [
  MatchPair(
    'ingredient-salicylic-acid',
    'Salicylic acid',
    'Acne spot products',
  ),
  MatchPair('ingredient-mineral-filters', 'Zinc oxide', 'Sunscreens'),
  MatchPair('ingredient-hyaluronic-acid', 'Hyaluronic acid', 'Serums'),
  MatchPair('ingredient-urea', 'Urea', 'Hand and foot creams'),
  MatchPair('ingredient-aloe-vera', 'Aloe vera', 'After-sun gels'),
  MatchPair('ingredient-clay', 'Clay', 'Face masks'),
  MatchPair('ingredient-surfactants', 'Surfactants', 'Cleansers and shampoos'),
  MatchPair('ingredient-caffeine', 'Caffeine', 'Eye creams'),
  MatchPair('ingredient-petrolatum', 'Petrolatum', 'Lip balms'),
  MatchPair('ingredient-dimethicone', 'Dimethicone', 'Primers'),
  MatchPair(
    'ingredient-alpha-hydroxy-acids',
    'Glycolic acid',
    'Exfoliating toners',
  ),
  MatchPair(
    'ingredient-colloidal-oatmeal',
    'Colloidal oatmeal',
    'Bath products',
  ),
  MatchPair('ingredient-squalane', 'Squalane', 'Facial oils'),
  MatchPair('ingredient-tretinoin', 'Tretinoin', 'Prescription gels'),
];

/// The questions that come from one theme.
List<QuizQuestion> quizQuestionsIn(LearnCategory category) => [
  for (final q in kQuizQuestions)
    if (q.category == category) q,
];
