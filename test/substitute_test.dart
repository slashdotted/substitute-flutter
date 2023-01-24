/* 
This file is part of the Substitute package / library
Copyright (c)2022-2023 Amos Brocco <contact@amosbrocco.ch>.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in
       the documentation and/or other materials provided with the distribution.
    3. Neither the name of the copyright holder nor the names of its 
       contributors may be used to endorse or promote products derived
       from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.
*/
import 'package:substitute/substitute.dart';
import 'package:test/test.dart';

void main() {
  test('Test non global substitution', () {
    final s = Substitute(find: r'\d\d\d', replacement: r'1234');
    expect(s.apply('hello'), 'hello');
    expect(s.apply('hello from 2022'), 'hello from 12342');
    expect(s.apply('hello 1'), 'hello 1');
    expect(s.apply('hello 123'), 'hello 1234');
    expect(s.apply('hello 123 123'), 'hello 1234 123');
    expect(s.apply('hello 123 123 123'), 'hello 1234 123 123');
  });
  test('Test global substitution', () {
    final s = Substitute(find: r'\d\d\d', replacement: r'1234', global: true);
    expect(s.apply('hello'), 'hello');
    expect(s.apply('hello from 2022'), 'hello from 12342');
    expect(s.apply('hello 1'), 'hello 1');
    expect(s.apply('hello 123'), 'hello 1234');
    expect(s.apply('hello 123 123'), 'hello 1234 1234');
    expect(s.apply('hello 123 123 123'), 'hello 1234 1234 1234');
  });

  test('Test non global case sensitive substitution', () {
    final s = Substitute(find: r'hello', replacement: r'XYZ');
    expect(s.apply('hello'), 'XYZ');
    expect(s.apply('Hello'), 'Hello');
    expect(s.apply('hello hello'), 'XYZ hello');
  });

  test('Test global case sensitive substitution', () {
    final s = Substitute(find: r'hello', replacement: r'XYZ', global: true);
    expect(s.apply('hello'), 'XYZ');
    expect(s.apply('Hello'), 'Hello');
    expect(s.apply('hello hello'), 'XYZ XYZ');
  });

  test('Test non global case insensitive substitution', () {
    final s =
        Substitute(find: r'hello', replacement: r'XYZ', caseInsensitive: true);
    expect(s.apply('hello'), 'XYZ');
    expect(s.apply('Hello'), 'XYZ');
    expect(s.apply('hello hello'), 'XYZ hello');
  });

  test('Test global case insensitive substitution', () {
    final s = Substitute(
        find: r'hello',
        replacement: r'XYZ',
        global: true,
        caseInsensitive: true);
    expect(s.apply('hello'), 'XYZ');
    expect(s.apply('Hello'), 'XYZ');
    expect(s.apply('hello hello'), 'XYZ XYZ');
  });

  test('Test back-references non-global', () {
    final s = Substitute(find: r'\b\w{4}\b', replacement: r'X&X');
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XmarsX, hello moon!');
  });

  test('Test back-references global', () {
    final s = Substitute(find: r'\b\w{4}\b', replacement: r'X&X', global: true);
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XmarsX, hello XmoonX!');
  });

  test('Test back-references non-global', () {
    final s = Substitute(find: r'\b(\w{2})(\w{2})\b', replacement: r'X\2\1X');
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XrsmaX, hello moon!');
  });

  test('Test back-references global', () {
    final s = Substitute(
        find: r'\b(\w{2})(\w{2})\b', replacement: r'X\2\1X', global: true);
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XrsmaX, hello XonmoX!');
  });

  test('Test mixed back-references non-global', () {
    final s = Substitute(find: r'\b(\w{2})(\w{2})\b', replacement: r'X\2\1&X');
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XrsmamarsX, hello moon!');
  });

  test('Test mixed back-references global', () {
    final s = Substitute(
        find: r'\b(\w{2})(\w{2})\b', replacement: r'X\2\1&X', global: true);
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XrsmamarsX, hello XonmomoonX!');
  });

  test('Test non global substitution', () {
    final s = Substitute.fromSedExpr(r's/\d\d\d/1234/');
    expect(s.apply('hello'), 'hello');
    expect(s.apply('hello from 2022'), 'hello from 12342');
    expect(s.apply('hello 1'), 'hello 1');
    expect(s.apply('hello 123'), 'hello 1234');
    expect(s.apply('hello 123 123'), 'hello 1234 123');
    expect(s.apply('hello 123 123 123'), 'hello 1234 123 123');
  });
  test('Test global substitution', () {
    final s = Substitute.fromSedExpr(r's/\d\d\d/1234/g');
    expect(s.apply('hello'), 'hello');
    expect(s.apply('hello from 2022'), 'hello from 12342');
    expect(s.apply('hello 1'), 'hello 1');
    expect(s.apply('hello 123'), 'hello 1234');
    expect(s.apply('hello 123 123'), 'hello 1234 1234');
    expect(s.apply('hello 123 123 123'), 'hello 1234 1234 1234');
  });

  test('Test non global case sensitive substitution', () {
    final s = Substitute.fromSedExpr(r's/hello/XYZ/');
    expect(s.apply('hello'), 'XYZ');
    expect(s.apply('Hello'), 'Hello');
    expect(s.apply('hello hello'), 'XYZ hello');
  });

  test('Test global case sensitive substitution', () {
    final s = Substitute.fromSedExpr(r's/hello/XYZ/g');
    expect(s.apply('hello'), 'XYZ');
    expect(s.apply('Hello'), 'Hello');
    expect(s.apply('hello hello'), 'XYZ XYZ');
  });

  test('Test non global case insensitive substitution', () {
    final s = Substitute.fromSedExpr(r's/hello/XYZ/I');
    expect(s.apply('hello'), 'XYZ');
    expect(s.apply('Hello'), 'XYZ');
    expect(s.apply('hello hello'), 'XYZ hello');
  });

  test('Test global case insensitive substitution', () {
    final s = Substitute.fromSedExpr(r's/hello/XYZ/gI');
    expect(s.apply('hello'), 'XYZ');
    expect(s.apply('Hello'), 'XYZ');
    expect(s.apply('hello hello'), 'XYZ XYZ');
  });

  test('Test global case insensitive substitution', () {
    final s = Substitute.fromSedExpr(r's/hello/XYZ/Ig');
    expect(s.apply('hello'), 'XYZ');
    expect(s.apply('Hello'), 'XYZ');
    expect(s.apply('hello hello'), 'XYZ XYZ');
  });

  test('Test back-references non-global', () {
    final s = Substitute.fromSedExpr(r's/\b\w{4}\b/X&X/');
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XmarsX, hello moon!');
  });

  test('Test back-references global', () {
    final s = Substitute.fromSedExpr(r's/\b\w{4}\b/X&X/g');
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XmarsX, hello XmoonX!');
  });

  test('Test back-references non-global', () {
    final s = Substitute.fromSedExpr(r's/\b(\w{2})(\w{2})\b/X\2\1X/');
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XrsmaX, hello moon!');
  });

  test('Test back-references global', () {
    final s = Substitute.fromSedExpr(r's/\b(\w{2})(\w{2})\b/X\2\1X/g');
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XrsmaX, hello XonmoX!');
  });

  test('Test mixed back-references non-global', () {
    final s = Substitute.fromSedExpr(r's/\b(\w{2})(\w{2})\b/X\2\1&X/');
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XrsmamarsX, hello moon!');
  });

  test('Test mixed back-references global', () {
    final s = Substitute.fromSedExpr(r's/\b(\w{2})(\w{2})\b/X\2\1&X/g');
    expect(s.apply('hello world, hello mars, hello moon!'),
        'hello world, hello XrsmamarsX, hello XonmomoonX!');
  });
}
