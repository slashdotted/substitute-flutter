// A simple example for the substitute package
import 'package:substitute/substitute.dart';

void main() {
  final s1 = Substitute(
      find: r'\d\d\d',
      replacement: r'1234',
      global: true,
      caseInsensitive: true);
  print(s1.apply('hello'));
  print(s1.apply('hello from 2022'));
  print(s1.apply('hello 1'));
  print(s1.apply('hello 123'));
  print(s1.apply('hello 123 123'));
  print(s1.apply('hello 123 123 123'));

  // We can also setup a substitution using a sed 's' expression
  final s2 = Substitute.fromSedExpr(r's/\b(\w{2})(\w{2})\b/X\2\1&X/g');
  print(s2.apply('hello world, hello mars, hello moon!'));
}
