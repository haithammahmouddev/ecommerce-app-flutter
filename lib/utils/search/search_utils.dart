import 'dart:math';

class SearchDoc<T> {
  SearchDoc._(this.item, this.titleTokens, this.allTokens);

  final T item;
  final List<String> titleTokens;
  final List<String> allTokens;

  factory SearchDoc.build(T item, {required String title, String brand = ''}) {
    final t = SearchUtils.tokenize(title);
    return SearchDoc._(item, t, [...t, ...SearchUtils.tokenize(brand)]);
  }
}

class SearchUtils {
  static final _tashkeel = RegExp(r'[\u064B-\u065F\u0670\u0640]');
  static final _nonWord = RegExp(r'[^\u0621-\u064Aa-z0-9\s]');
  static final _spaces = RegExp(r'\s+');
  static final _alef = RegExp('[أإآٱ]');

  static String normalize(String input) {
    var s = input.toLowerCase().replaceAll(_tashkeel, '');
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(arabicDigits[i], '$i');
    }
    return s
        .replaceAll(_alef, 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll(_nonWord, ' ')
        .replaceAll(_spaces, ' ')
        .trim();
  }

  static List<String> tokenize(String input) {
    return normalize(input)
        .split(' ')
        .where((t) => t.isNotEmpty)
        .map((t) => (t.startsWith('ال') && t.length > 4) ? t.substring(2) : t)
        .toList();
  }

  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = min(min(curr[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[b.length];
  }

  static double _tokenScore(String qt, String tt) {
    if (qt == tt) return 1.0;
    if (tt.startsWith(qt)) return 0.9;
    if (qt.length >= 2 && tt.contains(qt)) return 0.7;

    final maxDist = qt.length <= 3 ? 0 : (qt.length <= 6 ? 1 : 2);
    if (maxDist == 0) return 0;

    final full = levenshtein(qt, tt);
    final prefix = tt.length > qt.length ? tt.substring(0, qt.length) : tt;
    final d = min(full, levenshtein(qt, prefix));
    return d <= maxDist ? 0.6 - 0.1 * d : 0;
  }

  static double scoreTokens(List<String> qTokens, List<String> tTokens) {
    if (qTokens.isEmpty || tTokens.isEmpty) return 0;
    final compactText = tTokens.join();

    var total = 0.0;
    for (final qt in qTokens) {
      var best = 0.0;
      for (final tt in tTokens) {
        best = max(best, _tokenScore(qt, tt));
        if (best == 1.0) break;
      }
      if (best == 0 && qt.length >= 3 && compactText.contains(qt)) best = 0.5;
      if (best == 0) return 0;
      total += best;
    }
    return total / qTokens.length;
  }

  static double score(String query, String text) =>
      scoreTokens(tokenize(query), tokenize(text));

  static List<T> searchIndex<T>(
    List<SearchDoc<T>> docs,
    String query, {
    double titleBoost = 0.5,
  }) {
    final q = tokenize(query);
    if (q.isEmpty) return [];

    final scored = <MapEntry<SearchDoc<T>, double>>[];
    for (final d in docs) {
      final all = scoreTokens(q, d.allTokens);
      if (all == 0) continue;
      final title = scoreTokens(q, d.titleTokens);
      scored.add(MapEntry(d, all + title * titleBoost));
    }

    scored.sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0
          ? c
          : a.key.titleTokens.length.compareTo(b.key.titleTokens.length);
    });
    return scored.map((e) => e.key.item).toList();
  }
}
