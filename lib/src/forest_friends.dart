// The forest friends: who they are (name, what it means, a line, their story)
// and their round faces. The drawings and the peek-out are in forest_animals.dart.
// Any Véda app can use them where they fit (Routine and Kitchen are their
// homes); they have no place in Véda or Cycle (see UI_RULES.md, "The forest
// friends").

import 'package:flutter/material.dart';

import 'forest_animals.dart';

/// One friend: who they are, what their name means (if it means something),
/// a line about them, and their story. These words are also the seed for the
/// marketing stories, so keep them warm and free of any skincare claims.
class ForestFriend {
  const ForestFriend(
    this.animal,
    this.name,
    this.line,
    this.story, {
    required this.kind,
    this.means,
    this.special = false,
  });

  final ForestAnimal animal;
  final String name;
  final String line;
  final String story;

  /// What kind of animal this is, in a few words, for the ones whose shape is
  /// not obvious at a glance (a stork, a monal, an onager).
  final String kind;
  final String? means;

  /// Draws the panda with her bamboo.
  final bool special;
}

/// The cast, in the order the card shows them.
const kForestFriends = [
  ForestFriend(
    ForestAnimal.tiger,
    'Tara',
    'The stargazer',
    'Every evening Tara climbs up to Starlight Hill to wait for the first star, '
        'right beside Danphe, who dances up there after dark. She is quite sure the stars are watching her back, so she '
        'always sits up very straight. She is the bravest of the friends and the '
        'first to peek out when the sky turns dark.',
    means: 'Tara means "star" in Hindi.',
    kind: 'Tiger',
  ),
  ForestFriend(
    ForestAnimal.elephant,
    'Nuru',
    'The firefly friend',
    'Nuru loves fireflies more than anything. On warm nights she stands very '
        'still at the edge of the clearing, and when one lands on the tip of her '
        'trunk she holds her breath so it will stay. She never forgets a face or '
        'a kindness either, and when the day starts winding down she gives one '
        'very quiet trumpet, so the whole forest knows it is time to ease up.',
    means: 'Nuru means "light" in Swahili.',
    kind: 'Elephant',
  ),
  ForestFriend(
    ForestAnimal.panda,
    'Bao',
    'The noticer',
    'Bao once spent a whole afternoon watching a single ladybird cross a '
        'leaf, and said it was the best afternoon of his life. His love of '
        'nature never lets him miss anything big or small. Ask him what he saw '
        'today and you will hear about something you would have walked right '
        'past.',
    means: 'Bao can mean "treasure" in Mandarin.',
    kind: 'Giant panda',
  ),
  ForestFriend(
    ForestAnimal.panda,
    'Mei',
    'The shy one',
    'Mei carries her bamboo everywhere, in case a friend gets hungry. She is '
        "Bao's girlfriend, and so shy that she only comes out when the forest is very "
        'quiet. Nobody sees her often. When you do, people say it is going to be '
        'a good day.',
    means: 'Mei can mean "beautiful" in Mandarin.',
    special: true,
    kind: 'Giant panda',
  ),
  ForestFriend(
    ForestAnimal.lion,
    'Shumba',
    'The gentle roarer',
    'Shumba practises his big roar every single morning. It always comes out as '
        'a yawn, which makes everyone smile, Shumba most of all. His mane is full of '
        'leaves he has stopped bothering to pick out, and he says they make him '
        'look wise.',
    means: 'Shumba means "lion" in Shona.',
    kind: 'Lion',
  ),
  ForestFriend(
    ForestAnimal.bear,
    'Bela',
    'The professional napper',
    'Bela is only ever "resting her eyes". She has the slowest routine in the '
        'forest and she does not apologise for it: a long stretch, a little '
        'honey, a nap in the sun, and a good think about nothing at all. The '
        'others secretly envy her.',
    kind: 'Brown bear',
  ),
  ForestFriend(
    ForestAnimal.peacock,
    'Nazm',
    'The poet with a soft heart',
    'Nazm believes every rainfall deserves a poem. When the rain stops he is '
        'the first one out, fanning his tail wide so the last drops fall like '
        'glitter, and then he recites a verse that only the fireflies quite '
        'understand. He is the vainest of the friends and the kindest: his fan '
        'is always big enough to share a little shade.',
    means: 'Nazm is Urdu for a poem, a verse. It also means order and harmony.',
    kind: 'Peacock',
  ),
  ForestFriend(
    ForestAnimal.hippo,
    'Nefer',
    'The one who sees the good',
    'Nefer is the biggest of the friends and the quietest. He spends the day '
        'half in the shallows with only his eyes above the water, and he finds '
        'something good in nearly everything he sees: a ripple, a heron, the '
        'light on the river. He moves slowly on purpose and notices '
        'everything. When the others hurry, he simply waits, and somehow '
        'nothing ever rushes him. Ask him what is beautiful today, and he '
        'will smile and say, very slowly, that it is all of it.',
    means: 'Nefer means "good" or "beautiful" in ancient Egyptian.',
    kind: 'Hippopotamus',
  ),
  ForestFriend(
    ForestAnimal.owl,
    'Luna',
    'The night watcher',
    'Luna stays up late so the others can sleep soundly. She sits on the '
        'highest branch, turning her head all the way round to check on '
        'everyone, and hoots only when something is lovely. She loves the night '
        'best, because the moon always seems to be listening.',
    means: 'Luna means "moon" in Spanish.',
    kind: 'Owl',
  ),
  ForestFriend(
    ForestAnimal.fox,
    'Renard',
    'The kind trickster',
    'Renard is a bit of a trickster, but only in the nicest way. He hides '
        'small surprises for the others: a bright leaf on a doorstep, a feather '
        'on a pillow of moss. He grins whenever someone finds one, and always '
        'pretends it was the wind.',
    means: 'Renard means "fox" in French.',
    kind: 'Red fox',
  ),
  ForestFriend(
    ForestAnimal.redPanda,
    'Pema',
    'The one who stays present',
    'Pema lives high in the misty mountain forests and visits when the clouds '
        'hang low. She is very good at doing one thing at a time: nibbling a '
        'bamboo leaf, watching a single raindrop, wrapping her tail round '
        'herself like a warm scarf. Her friends say her calm is catching.',
    means: 'Pema means "lotus" in Tibetan.',
    kind: 'Red panda',
  ),
  ForestFriend(
    ForestAnimal.polarBear,
    'Nanuq',
    'The far traveller',
    'Nanuq travels a very long way from the white north to visit his friends. '
        'He brings a little cold air on his fur and a great many stories about '
        'the northern lights, the only place he has ever seen the sky dance. '
        'He is always happy to sit in a warm patch of sun with everyone.',
    means: 'Nanuq means "polar bear" in Inuktitut.',
    kind: 'Polar bear',
  ),
  ForestFriend(
    ForestAnimal.llama,
    'Illari',
    'The first light',
    'Illari comes down from the high Andes, where the sun is the first thing '
        'to arrive each morning. She wears her bright tassels with pride and '
        'hums as she walks. Wherever she goes, the day seems to begin a little '
        'more gently.',
    means: 'Illari carries the sense of dawn light in Quechua.',
    kind: 'Llama',
  ),
  ForestFriend(
    ForestAnimal.crane,
    'Sora',
    'The wish keeper',
    'Sora is a crane, and in her country cranes are a sign of luck and long '
        'life. She stands very still on one leg while she thinks, and the '
        'others have learned that when she lifts her head, something good is '
        'about to happen. She folds paper cranes from fallen leaves for anyone '
        'who needs a wish.',
    means: 'Sora means "sky" in Japanese.',
    kind: 'Crane, a tall wading bird',
  ),
  ForestFriend(
    ForestAnimal.koala,
    'Jarrah',
    'The sleepy hugger',
    'Jarrah loves a long nap in the crook of a tree and an even longer hug. '
        'He sleeps most of the day, which he says is just the right amount, and '
        'wakes up cheerful for the stories at dusk. Visiting the forest is his '
        'holiday, and he never forgets to bring a leaf from home as a gift.',
    means:
        'Jarrah is named for a eucalyptus tree, from the Noongar language of '
        'western Australia.',
    kind: 'Koala',
  ),
  // Season 2: drafts for the owner to approve, with names to be checked by
  // someone who speaks each language
  ForestFriend(
    ForestAnimal.orangutan,
    'Rimba',
    'The tree-top builder',
    'Rimba lives in the very top branches, where the sun arrives first. Every '
        'evening he builds a new leafy nest, never the same twice, and is quietly '
        'proud of each one. He is slow and thoughtful, and he says the best view '
        'in the forest belongs to anyone willing to climb a little.',
    means:
        'Rimba means "forest" in Malay and Indonesian, where "orang utan" '
        'means "person of the forest".',
    kind: 'Orangutan, a great ape of the rainforest',
  ),
  ForestFriend(
    ForestAnimal.horse,
    'Tulpar',
    'The wind runner',
    'Tulpar comes from the wide grasslands far to the east, where the sky is '
        'very big and the wind has room to run. In the old stories a horse like '
        'her can fly, and when she is happy she trots a little above the ground, '
        'just to be sure. She never rushes, but she always arrives.',
    means: 'Tulpar is the winged horse of the old stories of Central Asia.',
    kind: 'Horse, from the old winged-horse stories',
  ),
  ForestFriend(
    ForestAnimal.gorilla,
    'Mugisha',
    'The gentle giant',
    'Mugisha is the biggest of the friends and the most careful. He walks as '
        'if the ground might be asleep, beats his chest only as a joke, and '
        'shares his leaves with anyone who sits beside him. He says being strong '
        'is mostly a matter of being gentle on purpose.',
    means: 'Mugisha means "luck" or "fortune" in Kinyarwanda.',
    kind: 'Mountain gorilla',
  ),
  ForestFriend(
    ForestAnimal.dolphin,
    'Thalassa',
    'The one who brings the sea',
    'Thalassa arrives from the sea in the west, leaping most of the way. She '
        'loves company and a good splash, and hums a song that only the water '
        'can answer. She tells the others the sea is just a very big lake that '
        'never stopped being curious.',
    means: 'Thalassa means "sea" in Greek.',
    kind: 'Dolphin',
  ),
  // the next round: drafts for the owner to approve, names to be checked by
  // someone who speaks each language
  ForestFriend(
    ForestAnimal.kiwi,
    'Aroha',
    'The shy night walker',
    'Aroha is a kiwi, a small round bird from the islands far to the south-east, '
        'who likes the evening better than the day. She snuffles through the '
        'leaves with her long beak, humming, and finds the best things by smell '
        'rather than sight. She is shy until she knows you, and then she '
        'follows you everywhere, one step behind.',
    means: 'Aroha means "love" in Māori.',
    kind: 'Kiwi, a small flightless bird of New Zealand',
  ),
  ForestFriend(
    ForestAnimal.stork,
    'Vesna',
    'The spring bringer',
    'Vesna arrives every year just as the cold lets go, flying in from far '
        'away with her long legs trailing behind her. She builds her nest on the '
        'highest chimney in the village and stands on one leg, keeping watch '
        'over everything below. When she is back, everyone knows the days are '
        'about to get longer.',
    means: 'Vesna means "spring" in several Slavic languages.',
    kind: 'White stork, a tall bird with long red legs',
  ),
  ForestFriend(
    ForestAnimal.capybara,
    'Dengo',
    'The friend to everyone',
    'Dengo is so calm that other animals sit on him, and he has never once '
        'minded. Birds nap on his back, a small orange sits on his head, and he '
        'floats through the day as if nothing could ever be urgent. He is the '
        'friend you go to when you simply want to sit beside someone.',
    means: 'Dengo is Brazilian Portuguese for tender, cuddly affection.',
    kind: 'Capybara, the largest rodent in the world',
  ),
  ForestFriend(
    ForestAnimal.camel,
    'Bayar',
    'The steady traveller',
    'Bayar is a Bactrian camel, the shaggy, two-humped kind from the steppe '
        'and the cold Gobi desert. He has walked more miles than anyone can count, '
        'one slow, even step at a time. His two humps are his pantry, he says, '
        'and his thick winter coat is the best coat there is. He never hurries, '
        'because he knows how far it is, and never stops.',
    means: 'Bayar means "joy" in Mongolian.',
    kind: 'Bactrian camel, the two-humped kind',
  ),
  ForestFriend(
    ForestAnimal.penguin,
    'Eira',
    'The far visitor',
    'Eira comes from the very bottom of the world, where the ice goes on for '
        'ever and the stars are never shy. She waddles instead of walking and '
        'slides whenever she can, and she brings a little cold air and a great '
        'deal of joy. She thinks the forest is wonderfully warm, and says so, '
        'often.',
    means: 'Eira means "snow" in Welsh.',
    kind: 'Penguin',
  ),
  ForestFriend(
    ForestAnimal.falcon,
    'Saqr',
    'The patient watcher',
    'Saqr watches the world from the highest perch he can find, and sees '
        'everything long before the others do. He is very quick, but he is '
        'also patient: he will sit as still as it takes, and he trusts the '
        'friend who holds out a glove to him. In his part of the world a falcon '
        'and a falconer are old and proud partners, and he says the best '
        'flights begin with waiting.',
    means: 'Saqr means "falcon" in Arabic.',
    kind: 'Falcon, a bird of prey',
  ),
  ForestFriend(
    ForestAnimal.monal,
    'Danphe',
    'The dance master',
    'Danphe is the dance master of the forest. He came down from the mountains '
        'of the high mountains far to the south, wearing every colour he could find, and by day he is quiet and '
        'a little shy about them. But when night falls he climbs to Starlight '
        'Hill and dances under the stars, his crest bobbing and his feathers '
        'catching every bit of light. Tara sits close by and gazes on, never '
        'taking her eyes off him. From far away, all the other friends watch the '
        'dance shimmering on the hill, entranced, until one by one they drift '
        'off into a dream.',
    means:
        'Danphe is the Nepali name for the Himalayan monal, the national bird '
        'of Nepal.',
    kind: 'Himalayan monal, a mountain pheasant',
  ),
  ForestFriend(
    ForestAnimal.onager,
    'Gur',
    'The one who listens first',
    'Gur comes from the high, dry plains far to the west, a wild relative of the horse '
        'who is faster than almost anyone and never in a hurry to prove it. His '
        'big ears catch every sound for miles, and he always stops to listen '
        'before he runs. In the old poems of Persia his family is the swiftest '
        'thing on the plain, and he says the best way to go far is to hear the '
        'road first.',
    means:
        'Gur is the Persian word for the onager, the wild animal of the Iranian '
        'plateau.',
    kind: 'Persian onager, a wild relative of the horse',
  ),
  ForestFriend(
    ForestAnimal.jaguar,
    'Balam',
    'The quiet guardian',
    'Balam comes from the warm green forests far to the south, where the '
        'Maya told stories of the jaguar who walks between the day and the '
        'night. He is a quiet walker and a strong swimmer, and he likes to rest '
        'on a wide branch through the afternoon, watching the light move. He is '
        'gentle with every friend, and says the strongest thing in the forest '
        'is a calm heart.',
    means: 'Balam means "jaguar" in Maya.',
    kind: 'Jaguar, the great cat of the Americas',
  ),
  ForestFriend(
    ForestAnimal.bison,
    'Tatanka',
    'The grassland walker',
    'Tatanka walks the wide grasslands, where the grass moves like water and '
        'the sky goes on for ever. He is one of the biggest of the friends and '
        'one of the gentlest. He travels with his herd, never in a hurry, and '
        'when the weather turns he lowers his great head, faces the wind and '
        'waits for it to pass. For the people of the plains the buffalo has '
        'long been a friend and a teacher, and Tatanka carries that with quiet '
        'pride.',
    means: 'Tatanka means "buffalo" in Lakota.',
    kind: 'American bison, often called a buffalo',
  ),
  ForestFriend(
    ForestAnimal.wolf,
    'Dolce',
    'The one who gathers the table',
    'Dolce looks fierce at first glance, with her pointed ears and her long '
        'grey coat, and then she smiles, and everyone remembers that she is '
        'the sweetest of the friends. She loves a full table more than '
        'anything: a big pot on the fire, a crowd of friends round it, and '
        'someone always asking for more. In her part of the world a wolf is '
        'a family animal, and she says the best meals are the ones where '
        'nobody is left out.',
    means: 'Dolce means "sweet" in Italian.',
    kind: 'Wolf, a wild cousin of the dog',
  ),
];

/// Friends who are resting: not on any card and not out visiting (see
/// kForestRotation), with their stories kept for when they come back.
const kRestingFriends = [
  ForestFriend(
    ForestAnimal.monkey,
    'Milo',
    'The giggler',
    'Milo swings from vine to vine and is always the first to spot a new '
        'butterfly. He is hopeless at hide and seek, because he cannot stop '
        'giggling the moment anyone gets close. He peeks in at the clearing more '
        'than anyone, just to check that everything is lovely.',
    kind: 'Monkey',
  ),
];

/// The friend for an animal that peeks out; Mei is the panda with her bamboo.
ForestFriend? forestFriendFor(ForestAnimal animal, {bool special = false}) {
  for (final f in [...kForestFriends, ...kRestingFriends]) {
    if (f.animal == animal && f.special == special) return f;
  }
  return null;
}

/// A friend's round face, drawn the same way as when they peek out.
class ForestHeadIcon extends StatelessWidget {
  const ForestHeadIcon(
    this.animal, {
    super.key,
    this.special = false,
    this.size = 56,
  });

  final ForestAnimal animal;
  final bool special;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _HeadPainter(animal, special)),
  );
}

class _HeadPainter extends CustomPainter {
  const _HeadPainter(this.animal, this.special);

  final ForestAnimal animal;
  final bool special;

  @override
  void paint(Canvas canvas, Size size) => paintAnimalHead(
    canvas,
    animal,
    size.center(Offset.zero),
    size.shortestSide * 0.42,
    special: special,
  );

  @override
  bool shouldRepaint(_HeadPainter old) =>
      old.animal != animal || old.special != special;
}
