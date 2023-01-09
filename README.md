# Substitute like sed

## Features
This library is used to apply substitution patterns to strings. You can create a substitution by either specifying the find pattern (a regular expression) and the replacement or by using a sed expression which uses the 's' (substitute) command. The *apply* method is used to perform the substitution in a string (the resulting string will be returned).

## Getting started

For using this library you need to understand regular expressions or the syntax of the *s* command in *sed*.

## Usage
You just need to create a *Substitute* object and then call the *apply* method:

```dart
final s = Substitute(find: r'\d\d\d', replacement: r'1234');
expect(s.apply('hello'), 'hello');
expect(s.apply('hello from 2022'), 'hello from 12342');
expect(s.apply('hello 123 123'), 'hello 1234 123');
```
Using a *sed* expression:
```dart
final s = Substitute.fromSedExpr(r's/\d\d\d/1234/');
expect(s.apply('hello'), 'hello');
expect(s.apply('hello from 2022'), 'hello from 12342');
expect(s.apply('hello 123 123'), 'hello 1234 123');
```

By default the substitution is made non-globally (only for the first occurence in the string).
By means of the *global* parameter (or the 'g' flag when using a sed expression)
you can apply a substitution to all matches:
 
```dart
final s = Substitute(find: r'hello', replacement: r'XYZ', global: true);
expect(s.apply('hello hello'), 'XYZ XYZ');
```

```dart
final s = Substitute.fromSedExpr(r's/\d\d\d/1234/g');
expect(s.apply('hello 123 123'), 'hello 1234 1234');
```

By default the pattern matching is case sensitive. To work with case-insensitive matching
either set the *caseInsensitive* parameter to *true*, or add the 'I' flag to the sed expression.
 
```dart
final s = Substitute(find: r'hello', replacement: r'XYZ', caseInsensitive: true);
expect(s.apply('hello'), 'XYZ');
expect(s.apply('Hello'), 'XYZ');
``` 

```dart
final s = Substitute.fromSedExpr(r's/hello/XYZ/I');
expect(s.apply('hello'), 'XYZ');
expect(s.apply('Hello'), 'XYZ');
``` 

You can also specify back-references to the whole match with *&* or to a particular group with \N
(where N is an integer between 1 and 9).
 
```dart
final s = Substitute(find: r'\b(\w{2})(\w{2})\b', replacement: r'X\2\1&X', global: true);
expect(s.apply('hello world, hello mars, hello moon!'), 'hello world, hello XrsmamarsX, hello XonmomoonX!');
``` 
  
```dart
final s = Substitute.fromSedExpr(r's/\b(\w{2})(\w{2})\b/X\2\1&X/g');
expect(s.apply('hello world, hello mars, hello moon!'), 'hello world, hello XrsmamarsX, hello XonmomoonX!');
```

## Additional information

Only the basic options/flags of the *s* commands are supported (namely *g*, *I*).
