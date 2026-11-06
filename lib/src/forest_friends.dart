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
    this.means,
    this.special = false,
  });

  final ForestAnimal animal;
  final String name;
  final String line;
  final String story;
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
    'Every evening Tara climbs the tallest rock in the forest to wait for the '
        'first star. She is quite sure the stars are watching her back, so she '
        'always sits up very straight. She is the bravest of the friends and the '
        'first to peek out when the sky turns dark.',
    means: 'Tara means "star" in Hindi.',
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
  ),
  ForestFriend(
    ForestAnimal.bear,
    'Bela',
    'The professional napper',
    'Bela is only ever "resting her eyes". She has the slowest routine in the '
        'forest and she does not apologise for it: a long stretch, a little '
        'honey, a nap in the sun, and a good think about nothing at all. The '
        'others secretly envy her.',
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
  ),
  ForestFriend(
    ForestAnimal.hippo,
    'Hadi',
    'The calm one',
    'Hadi is the biggest of the friends and the quietest. He spends the day '
        'half in the shallows with only his eyes above the water, watching '
        'clouds go by, and says the secret of a good day is to move slowly and '
        'notice everything. When the others hurry, he simply waits, and '
        'somehow nothing ever rushes him.',
    means: 'Hadi means "calm" in Arabic.',
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
  ),
  ForestFriend(
    ForestAnimal.camel,
    'Karvan',
    'The steady traveller',
    'Karvan is a Bactrian camel, the shaggy, two-humped kind from the steppe '
        'and the cold deserts. He has walked more miles than anyone can count, '
        'one slow, even step at a time. His two humps are his pantry, he says, '
        'and his thick winter coat is the best coat there is. He never hurries, '
        'because he knows how far it is, and never stops.',
    means: 'Karvan means "caravan" in Persian.',
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
  ),
  ForestFriend(
    ForestAnimal.monal,
    'Danphe',
    'The dance master',
    'Danphe is the dance master of the forest. He came down from the mountains '
        'of Nepal wearing every colour he could find, and by day he is quiet and '
        'a little shy about them. But when night falls he climbs to Starlight '
        'Hill and dances under the stars, his crest bobbing and his feathers '
        'catching every bit of light. Tara sits close by and gazes on, never '
        'taking her eyes off him. From far away, all the other friends watch the '
        'dance shimmering on the hill, entranced, until one by one they drift '
        'off into a dream.',
    means:
        'Danphe is the Nepali name for the Himalayan monal, the national bird '
        'of Nepal.',
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
