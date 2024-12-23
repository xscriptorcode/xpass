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

   static const specialChars = ['#', '*', '&', '@', '%', '!', '^', '+', '_', '-'];
  // Método para generar una palabra de cinco sílabas
  static String _generateWord(int syllableCount) {
    return List.generate(syllableCount, (_) => syllables[_random.nextInt(syllables.length)])
        .join();
  }

  // Método para generar el código de acceso
  static String generateAccessCode() {
    // Generar dos palabras de cinco sílabas cada una
    String word1 = _generateWord(5);
    String word2 = _generateWord(5);

    // Concatenar las palabras
    String combined = '$word1$word2';

    // Elegir uno o dos caracteres especiales
    int specialCharCount = _random.nextBool() ? 1 : 2;
    List<String> specialCharsList = List.generate(specialCharCount, (_) => specialChars[_random.nextInt(specialChars.length)]);

    // Insertar caracteres especiales en posiciones completamente aleatorias
    List<String> characters = combined.split(''); // Dividir la cadena en caracteres individuales
    for (String specialChar in specialCharsList) {
      int randomIndex = _random.nextInt(characters.length + 1); // Elegir índice aleatorio
      characters.insert(randomIndex, specialChar); // Insertar el carácter especial
    }

    // Reconstruir la cadena final
    return characters.join();
  }
}