import 'package:flutter/widgets.dart';

class AppTexts {
  AppTexts(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('fr'),
  ];

  static AppTexts of(BuildContext context) {
    final texts = Localizations.of<AppTexts>(context, AppTexts);
    if (texts == null) {
      return AppTexts(const Locale('en'));
    }
    return texts;
  }

  static const LocalizationsDelegate<AppTexts> delegate = _AppTextsDelegate();

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appName': 'GlobalCalc',
      'tips': 'Tips',
      'currency': 'Currency',
      'discount': 'Discount',
      'percentages': 'Percentages',
      'billAmount': 'Bill amount',
      'tip': 'Tip',
      'splitByPeople': 'Split by people',
      'tipAmount': 'Tip amount',
      'totalWithTip': 'Total with tip',
      'perPerson': 'Per person',
      'amount': 'Amount',
      'from': 'From',
      'to': 'To',
      'convertNow': 'Convert now',
      'offlineRateNotice': 'Offline mode: using cached exchange rate.',
      'noBackendNotice': 'No backend needed: rates fetched from public API.',
      'exchangeError': 'Could not fetch exchange rate. Check connection and try again.',
      'youSave': 'You save',
      'finalPrice': 'Final price',
      'originalPrice': 'Original price',
      'discountValue': 'Discount',
      'whatIsPercentOf': 'A) What is X% of N?',
      'partOfWhole': 'B) Part is what % of whole?',
      'numberN': 'N (number)',
      'percentX': 'X (percent)',
      'part': 'Part',
      'whole': 'Whole',
      'result': 'Result',
      'language': 'Language',
      'rateLabel': 'Rate',
      'liveRate': 'Live rate',
      'cachedRate': 'Cached rate',
      'adLabel': 'Ad'
    },
    'es': {
      'appName': 'GlobalCalc',
      'tips': 'Propinas',
      'currency': 'Divisas',
      'discount': 'Descuentos',
      'percentages': 'Porcentajes',
      'billAmount': 'Importe de la cuenta',
      'tip': 'Propina',
      'splitByPeople': 'Dividir entre personas',
      'tipAmount': 'Monto de propina',
      'totalWithTip': 'Total con propina',
      'perPerson': 'Por persona',
      'amount': 'Cantidad',
      'from': 'De',
      'to': 'A',
      'convertNow': 'Convertir ahora',
      'offlineRateNotice': 'Modo sin conexion: usando tasa en cache.',
      'noBackendNotice': 'Sin backend propio: tasas desde API publica.',
      'exchangeError': 'No se pudo obtener la tasa. Revisa la conexion e intenta de nuevo.',
      'youSave': 'Ahorras',
      'finalPrice': 'Precio final',
      'originalPrice': 'Precio original',
      'discountValue': 'Descuento',
      'whatIsPercentOf': 'A) Cuanto es X% de N?',
      'partOfWhole': 'B) Parte representa que % del total?',
      'numberN': 'N (numero)',
      'percentX': 'X (porcentaje)',
      'part': 'Parte',
      'whole': 'Total',
      'result': 'Resultado',
      'language': 'Idioma',
      'rateLabel': 'Tasa',
      'liveRate': 'Tasa en vivo',
      'cachedRate': 'Tasa en cache',
      'adLabel': 'Anuncio'
    },
    'pt': {
      'appName': 'GlobalCalc',
      'tips': 'Gorjetas',
      'currency': 'Cambio',
      'discount': 'Desconto',
      'percentages': 'Percentuais',
      'billAmount': 'Valor da conta',
      'tip': 'Gorjeta',
      'splitByPeople': 'Dividir por pessoas',
      'tipAmount': 'Valor da gorjeta',
      'totalWithTip': 'Total com gorjeta',
      'perPerson': 'Por pessoa',
      'amount': 'Valor',
      'from': 'De',
      'to': 'Para',
      'convertNow': 'Converter agora',
      'offlineRateNotice': 'Modo offline: usando taxa em cache.',
      'noBackendNotice': 'Sem backend proprio: taxas de API publica.',
      'exchangeError': 'Nao foi possivel obter a taxa. Verifique a conexao e tente novamente.',
      'youSave': 'Voce economiza',
      'finalPrice': 'Preco final',
      'originalPrice': 'Preco original',
      'discountValue': 'Desconto',
      'whatIsPercentOf': 'A) Quanto e X% de N?',
      'partOfWhole': 'B) A parte representa qual % do total?',
      'numberN': 'N (numero)',
      'percentX': 'X (percentual)',
      'part': 'Parte',
      'whole': 'Total',
      'result': 'Resultado',
      'language': 'Idioma',
      'rateLabel': 'Taxa',
      'liveRate': 'Taxa ao vivo',
      'cachedRate': 'Taxa em cache',
      'adLabel': 'Anuncio'
    },
    'fr': {
      'appName': 'GlobalCalc',
      'tips': 'Pourboires',
      'currency': 'Devise',
      'discount': 'Remise',
      'percentages': 'Pourcentages',
      'billAmount': 'Montant de la note',
      'tip': 'Pourboire',
      'splitByPeople': 'Partager entre personnes',
      'tipAmount': 'Montant du pourboire',
      'totalWithTip': 'Total avec pourboire',
      'perPerson': 'Par personne',
      'amount': 'Montant',
      'from': 'De',
      'to': 'Vers',
      'convertNow': 'Convertir',
      'offlineRateNotice': 'Mode hors ligne: taux en cache utilise.',
      'noBackendNotice': 'Sans backend: taux depuis API publique.',
      'exchangeError': 'Impossible de recuperer le taux. Verifiez la connexion.',
      'youSave': 'Vous economisez',
      'finalPrice': 'Prix final',
      'originalPrice': 'Prix d origine',
      'discountValue': 'Remise',
      'whatIsPercentOf': 'A) Combien vaut X% de N?',
      'partOfWhole': 'B) La partie represente quel % du total?',
      'numberN': 'N (nombre)',
      'percentX': 'X (pourcentage)',
      'part': 'Partie',
      'whole': 'Total',
      'result': 'Resultat',
      'language': 'Langue',
      'rateLabel': 'Taux',
      'liveRate': 'Taux en direct',
      'cachedRate': 'Taux en cache',
      'adLabel': 'Publicite'
    },
  };

  String get _lang => _values.containsKey(locale.languageCode) ? locale.languageCode : 'en';

  String t(String key) => _values[_lang]?[key] ?? _values['en']![key] ?? key;
}

class _AppTextsDelegate extends LocalizationsDelegate<AppTexts> {
  const _AppTextsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppTexts.supportedLocales.any((supported) => supported.languageCode == locale.languageCode);

  @override
  Future<AppTexts> load(Locale locale) async => AppTexts(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppTexts> old) => false;
}
