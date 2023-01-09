/// There is only one class in this library: *Substitute*.
/// You can create a substitution by either specifying the find pattern and the replacement or by
/// using a sed expression which uses the 's' (substitute) command. The *apply* method is used to
/// perform the substitution in a string (the resulting string will be returned). Please refer to
/// the top level package documentation for some usage examples.
library substitute;

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

import 'package:flutter/foundation.dart';

enum _TokenType { backRef, text }

class _Token {
  _TokenType type = _TokenType.text;
  String? text;
  int? n;
  _Token({required this.type, this.text, this.n});
}

/// This is the base class of the library.
class Substitute {
  static bool debug = false;
  late final RegExp _find;
  late final List<_Token> _replacement;
  late final bool global;
  late final bool caseInsensitive;

  Substitute.fromSedExpr(String expr) {
    if (!expr.startsWith("s") || expr.length < 4) {
      throw 'Invalid sed substitute expression';
    }
    var sep = expr[1];
    expr = expr.substring(2);
    var params = expr.split(sep);
    if (params.length < 2) {
      throw 'Invalid sed substitute expression';
    } else if (params.length == 3) {
      // There are options
      caseInsensitive = params[2].contains('I');
      global = params[2].contains('g');
    } else {
      global = false;
      caseInsensitive = false;
    }
    _find = RegExp(params[0], caseSensitive: !caseInsensitive, unicode: true);
    _replacement = _parseReplacement(params[1]);
  }

  Substitute(
      {required String find,
      required String replacement,
      this.global = false,
      this.caseInsensitive = false}) {
    _find = RegExp(find, caseSensitive: !caseInsensitive, unicode: true);
    _replacement = _parseReplacement(replacement);
  }

  String apply(String input) {
    replacer(Match match) {
      var result = '';
      for (var t in _replacement) {
        switch (t.type) {
          case _TokenType.backRef:
            if (t.n! > match.groupCount) {
              throw "Error matching group ${t.n!} in ${_find.pattern} using $input";
            }
            result += match[t.n!]!;
            break;
          case _TokenType.text:
            result += t.text!;
            break;
        }
      }
      return result;
    }

    var output = global
        ? input.replaceAllMapped(_find, replacer)
        : input.replaceFirstMapped(_find, replacer);

    if (debug) {
      if (kDebugMode) {
        print("After $_find.pattern => $output");
      }
    }

    return output;
  }

  List<_Token> _parseReplacement(String replacement) {
    List<_Token> tokens = [];
    bool escape = false;
    var backSlash = '\\'.codeUnits.first;
    var amp = '&'.codeUnits.first;
    var one = '1'.codeUnits.first;
    var nine = '9'.codeUnits.first;
    var text = '';
    for (var c in replacement.runes) {
      if (c == backSlash) {
        if (escape) {
          text += r'\';
        }
        escape = !escape;
      } else if (c == amp) {
        if (!escape) {
          if (text.isNotEmpty) {
            tokens.add(_Token(type: _TokenType.text, text: text));
            text = '';
          }
          tokens.add(_Token(type: _TokenType.backRef, n: 0));
        } else {
          text += r'&';
          escape = false;
        }
      } else if (one <= c && c <= nine) {
        if (escape) {
          if (text.isNotEmpty) {
            tokens.add(_Token(type: _TokenType.text, text: text));
            text = '';
          }
          tokens.add(_Token(type: _TokenType.backRef, n: c - one + 1));
          escape = false;
        } else {
          text += String.fromCharCode(c);
        }
      } else {
        escape = false;
        text += String.fromCharCode(c);
      }
    }
    if (text.isNotEmpty) {
      tokens.add(_Token(type: _TokenType.text, text: text));
      text = '';
    }
    return tokens;
  }
}
