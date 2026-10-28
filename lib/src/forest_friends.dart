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
    'Leo',
    'The gentle roarer',
    'Leo practises his big roar every single morning. It always comes out as '
        'a yawn, which makes everyone smile, Leo most of all. His mane is full of '
        'leaves he has stopped bothering to pick out, and he says they make him '
        'look wise.',
    means: 'Leo means "lion" in Latin.',
  ),
  ForestFriend(
    ForestAnimal.bear,
    'Bela',
    'The professional napper',
    'Dancing is Bela’s way of having fun: when the music starts, she is up and '
        'swaying. The rest of the time she is only ever "resting her eyes". '
        'She has the slowest routine in the forest and she does not apologise '
        'for it: a long stretch, a little honey, a nap in the sun, and a good '
        'think about nothing at all. The others secretly envy her.',
  ),
  ForestFriend(
    ForestAnimal.monkey,
    'Milo',
    'The giggler',
    'Milo swings from vine to vine and is always the first to spot a new '
        'butterfly. He is hopeless at hide and seek, because he cannot stop '
        'giggling the moment anyone gets close. He peeks in at the clearing more '
        'than anyone, just to check that everything is lovely.',
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
];

/// The friend for an animal that peeks out; Mei is the panda with her bamboo.
ForestFriend? forestFriendFor(ForestAnimal animal, {bool special = false}) {
  for (final f in kForestFriends) {
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
