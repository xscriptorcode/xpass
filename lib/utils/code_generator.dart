// /utils/code_generator.dart
import 'dart:math';

class CodeGenerator {
  static final _random = Random();

  // Lista de sílabas para generar la palabra
  static const syllables = [
    'ba', 'be', 'bi', 'bo', 'bu', 'ca', 'ce', 'ci', 'co', 'cu',
    'da', 'de', 'di', 'do', 'du', 'fa', 'fe', 'fi', 'fo', 'fu',
    'ga', 'ge', 'gi', 'go', 'gu', 'ha', 'he', 'hi', 'ho', 'hu',
    'ja', 'je', 'ji', 'jo', 'ju', 'ka', 'ke', 'ki', 'ko', 'ku',
    'la', 'le', 'li', 'lo', 'lu', 'ma', 'me', 'mi', 'mo', 'mu',
    'na', 'ne', 'ni', 'no', 'nu', 'pa', 'pe', 'pi', 'po', 'pu',
    'ra', 're', 'ri', 'ro', 'ru', 'sa', 'se', 'si', 'so', 'su',
    'ta', 'te', 'ti', 'to', 'tu', 'va', 've', 'vi', 'vo', 'vu',
    'wa', 'we', 'wi', 'wo', 'wu', 'xa', 'xe', 'xi', 'xo', 'xu',
    'ya', 'ye', 'yi', 'yo', 'yu', 'za', 'ze', 'zi', 'zo', 'zu'
  ];

  // Método para generar una palabra de tres sílabas
  static String _generateWord() {
    return syllables[_random.nextInt(syllables.length)] +
           syllables[_random.nextInt(syllables.length)] +
           syllables[_random.nextInt(syllables.length)];
  }

  // Método para generar el código de acceso
  static String generateAccessCode() {
    // Generar una palabra de tres sílabas
    String word = _generateWord();

    // Generar un número aleatorio entre 1000 y 9999
    final number = _random.nextInt(9000) + 1000;

    // Concatenar la palabra y el número
    return '$word$number';
  }
}
