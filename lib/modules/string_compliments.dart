import 'dart:math';

import 'package:pigpen_iot/modules/string_extensions.dart';

// ignore: unused_element
const List<String> _emojis = [
  '🌱',
  '🌿',
  '🍃',
  '🌵',
  '🌴',
  '🎋',
  '🍀',
  '🌺',
  '🌸',
  '🌼',
  '🌳',
  '🌹',
  '🍂',
  '🌾',
  '🌻',
  '🌷',
  '🌲',
  '🌳',
  '🌴',
];

const List<String> _greetings = [
  'Great job!',
  'Excellent!',
  'Well done!',
  'Fantastic!',
  'Amazing!',
  'Keep it up!',
  'Nice work!',
  'Good going!',
  'Awesome!',
  'Superb!',
  'Green thumbs!',
  'Blooming success!',
  'Rooted victory!',
  'Sprouting joy!',
  'Growing triumph!',
  'Flourishing win!',
  'Leafy accomplishment!',
  'Blossoming achievement!',
  'Plantastic job!',
  'That\'s photosynthesis!',
  'Cultivated success!',
  'Thriving achievement!',
  'Planted perfection!',
  'Garden glory!',
  'Seedling sensation!',
  'Foliage fortune!',
  'Botanical brilliance!',
  'Floral flourish!',
  'Verdant victory!',
  'Nature\'s nurture!'
];

const List<String> _lines = [
  'Keep an eye on your new device!',
  'Stay up-to-date with your plant watering device!',
  'Your new device is ready for monitoring!',
  'Keep track of your plan\'s hydration with your new device!',
  'Watch your plants thrive with your new device!',
  'Your new device is all set for tracking!',
  'Stay in the know with your new plant watering device!',
  'Keep tabs on your plant\'s health with your new device!',
  'Your new device is ready to help you monitor your plants!',
  'Stay connected to your plants with your new device!',
  'Keep your plants happy with your new device!',
  'Stay on top of your plant\'s needs with your new device!',
  'Your new device is ready to help you care for your plants!',
  'Keep your plants thriving with your new device!',
  'Your new device is all set to help you monitor your plant\'s hydration!',
  'Stay in control with your new plant watering device!',
  'Keep your plants healthy with your new device!',
  'Your new device is ready to assist you in caring for your plants!',
  'Stay connected to your plant\'s needs with your new device!'
];

class Compliments {
  final _random = Random();

  String getGreeting() {
    return _greetings[_random.nextInt(_greetings.length)].toTitleCase();
  }

  // String getEmoji() {
  //   return _emojis[_random.nextInt(_emojis.length)];
  // }

  // String getGreetingWithEmoji() {
  //   return getGreeting() + getEmoji();
  // }

  String getLine() {
    return _lines[_random.nextInt(_lines.length)];
  }
}
