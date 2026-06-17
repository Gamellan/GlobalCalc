import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_texts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(_initializeAdsSafely());
  runApp(const GlobalCalcApp());
}

Future<void> _initializeAdsSafely() async {
  try {
    await MobileAds.instance.initialize();
  } catch (_) {}
}

class GlobalCalcApp extends StatefulWidget {
  const GlobalCalcApp({super.key});

  @override
  State<GlobalCalcApp> createState() => _GlobalCalcAppState();
}

class _GlobalCalcAppState extends State<GlobalCalcApp> {
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlobalCalc',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppTexts.supportedLocales,
      localizationsDelegates: const [
        AppTexts.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A84FF)),
        scaffoldBackgroundColor: const Color(0xFFF4F7FF),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      home: GlobalCalcHomePage(
        locale: _locale,
        onLocaleChanged: (locale) => setState(() => _locale = locale),
      ),
    );
  }
}

class GlobalCalcHomePage extends StatefulWidget {
  const GlobalCalcHomePage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<GlobalCalcHomePage> createState() => _GlobalCalcHomePageState();
}

class _GlobalCalcHomePageState extends State<GlobalCalcHomePage> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final banner = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
      ),
    );

    banner.load();
    _bannerAd = banner;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.t('appName')),
          actions: [
            PopupMenuButton<Locale>(
              tooltip: t.t('language'),
              icon: const Icon(Icons.language),
              onSelected: widget.onLocaleChanged,
              itemBuilder: (context) => const [
                PopupMenuItem(value: Locale('en'), child: Text('English')),
                PopupMenuItem(value: Locale('es'), child: Text('Espanol')),
                PopupMenuItem(value: Locale('pt'), child: Text('Portugues')),
                PopupMenuItem(value: Locale('fr'), child: Text('Francais')),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: const Icon(Icons.restaurant), text: t.t('tips')),
              Tab(icon: const Icon(Icons.currency_exchange), text: t.t('currency')),
              Tab(icon: const Icon(Icons.local_offer), text: t.t('discount')),
              Tab(icon: const Icon(Icons.percent), text: t.t('percentages')),
            ],
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEAF2FF), Color(0xFFF9FBFF)],
            ),
          ),
          child: TabBarView(
            children: [
              const TipCalculatorTab(),
              CurrencyConverterTab(onConversionCompleted: AdController.onConversionCompleted),
              const DiscountCalculatorTab(),
              const PercentageCalculatorTab(),
            ],
          ),
        ),
        bottomNavigationBar: _bannerAd == null
            ? null
            : SafeArea(
                child: SizedBox(
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
      ),
    );
  }
}

double _toDouble(String value) => double.tryParse(value.trim()) ?? 0;

class TipCalculatorTab extends StatefulWidget {
  const TipCalculatorTab({super.key});

  @override
  State<TipCalculatorTab> createState() => _TipCalculatorTabState();
}

class _TipCalculatorTabState extends State<TipCalculatorTab> {
  final TextEditingController _billController = TextEditingController();
  final TextEditingController _splitController = TextEditingController(text: '1');
  double _tipPercent = 15;

  @override
  void dispose() {
    _billController.dispose();
    _splitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final bill = _toDouble(_billController.text);
    final split = _toDouble(_splitController.text).clamp(1, 9999);
    final tipAmount = bill * (_tipPercent / 100);
    final total = bill + tipAmount;
    final perPerson = total / split;

    return _CalculatorContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _billController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.t('billAmount')),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text('${t.t('tip')}: ${_tipPercent.toStringAsFixed(0)}%'),
          Slider(
            value: _tipPercent,
            min: 0,
            max: 40,
            divisions: 40,
            label: _tipPercent.toStringAsFixed(0),
            onChanged: (value) => setState(() => _tipPercent = value),
          ),
          TextField(
            controller: _splitController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(labelText: t.t('splitByPeople')),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          _ResultLine(label: t.t('tipAmount'), value: tipAmount),
          _ResultLine(label: t.t('totalWithTip'), value: total),
          _ResultLine(label: t.t('perPerson'), value: perPerson),
        ],
      ),
    );
  }
}

class CurrencyConverterTab extends StatefulWidget {
  const CurrencyConverterTab({super.key, required this.onConversionCompleted});

  final VoidCallback onConversionCompleted;

  @override
  State<CurrencyConverterTab> createState() => _CurrencyConverterTabState();
}

class _CurrencyConverterTabState extends State<CurrencyConverterTab> {
  static const List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'BRL',
    'MXN',
    'INR',
    'CNY',
  ];

  final TextEditingController _amountController = TextEditingController(text: '1');
  String _from = 'USD';
  String _to = 'EUR';
  bool _loading = false;
  CurrencyConversion? _conversion;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    final amount = _toDouble(_amountController.text);
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await CurrencyService.convert(amount: amount, from: _from, to: _to);
      setState(() {
        _conversion = result;
      });
      widget.onConversionCompleted();
    } catch (_) {
      setState(() {
        _error = AppTexts.of(context).t('exchangeError');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);

    return _CalculatorContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.t('amount')),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _from,
                  decoration: InputDecoration(labelText: t.t('from')),
                  items: _currencies
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _from = value ?? _from),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _to,
                  decoration: InputDecoration(labelText: t.t('to')),
                  items: _currencies
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _to = value ?? _to),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _convert,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.currency_exchange),
            label: Text(t.t('convertNow')),
          ),
          const SizedBox(height: 20),
          if (_conversion != null)
            Text(
              '${_amountController.text} $_from = ${_conversion!.converted.toStringAsFixed(4)} $_to',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          if (_conversion != null)
            Text(
              '${t.t('rateLabel')}: 1 $_from = ${_conversion!.rate.toStringAsFixed(6)} $_to',
            ),
          if (_conversion != null && _conversion!.source == RateSource.cached)
            Text(
              t.t('offlineRateNotice'),
              style: const TextStyle(color: Color(0xFF8A5C00)),
            ),
          if (_conversion != null)
            Text(
              _conversion!.source == RateSource.live ? t.t('liveRate') : t.t('cachedRate'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          const Spacer(),
          Text(
            t.t('noBackendNotice'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class DiscountCalculatorTab extends StatefulWidget {
  const DiscountCalculatorTab({super.key});

  @override
  State<DiscountCalculatorTab> createState() => _DiscountCalculatorTabState();
}

class _DiscountCalculatorTabState extends State<DiscountCalculatorTab> {
  final TextEditingController _priceController = TextEditingController();
  double _discountPercent = 20;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final original = _toDouble(_priceController.text);
    final saved = original * (_discountPercent / 100);
    final finalPrice = original - saved;

    return _CalculatorContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.t('originalPrice')),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text('${t.t('discountValue')}: ${_discountPercent.toStringAsFixed(0)}%'),
          Slider(
            value: _discountPercent,
            min: 0,
            max: 90,
            divisions: 90,
            label: _discountPercent.toStringAsFixed(0),
            onChanged: (value) => setState(() => _discountPercent = value),
          ),
          const SizedBox(height: 24),
          _ResultLine(label: t.t('youSave'), value: saved),
          _ResultLine(label: t.t('finalPrice'), value: finalPrice),
        ],
      ),
    );
  }
}

class PercentageCalculatorTab extends StatefulWidget {
  const PercentageCalculatorTab({super.key});

  @override
  State<PercentageCalculatorTab> createState() => _PercentageCalculatorTabState();
}

class _PercentageCalculatorTabState extends State<PercentageCalculatorTab> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _percentController = TextEditingController(text: '10');
  final TextEditingController _partController = TextEditingController();
  final TextEditingController _wholeController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _percentController.dispose();
    _partController.dispose();
    _wholeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final number = _toDouble(_numberController.text);
    final percent = _toDouble(_percentController.text);
    final part = _toDouble(_partController.text);
    final whole = _toDouble(_wholeController.text);
    final percentOfNumber = number * (percent / 100);
    final whatPercent = whole == 0 ? 0 : (part / whole) * 100;

    return _CalculatorContainer(
      child: ListView(
        children: [
          Text(t.t('whatIsPercentOf'), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _numberController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.t('numberN')),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _percentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.t('percentX')),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _ResultLine(label: t.t('result'), value: percentOfNumber),
          const SizedBox(height: 24),
          Text(t.t('partOfWhole'), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _partController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.t('part')),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _wholeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.t('whole')),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text(
            '${whatPercent.toStringAsFixed(2)}%',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: ${value.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _CalculatorContainer extends StatelessWidget {
  const _CalculatorContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

enum RateSource { live, cached }

class CurrencyConversion {
  CurrencyConversion({
    required this.converted,
    required this.rate,
    required this.source,
  });

  final double converted;
  final double rate;
  final RateSource source;
}

class CurrencyService {
  static Future<CurrencyConversion> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (from == to) {
      return CurrencyConversion(converted: amount, rate: 1, source: RateSource.live);
    }

    final cacheKey = 'rate_${from}_$to';
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse('https://api.frankfurter.app/latest?amount=1&from=$from&to=$to');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Request failed with status ${response.statusCode}');
      }

      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = map['rates'] as Map<String, dynamic>;
      final rate = (rates[to] as num).toDouble();

      await prefs.setDouble(cacheKey, rate);
      await prefs.setInt('${cacheKey}_ts', DateTime.now().millisecondsSinceEpoch);

      return CurrencyConversion(
        converted: amount * rate,
        rate: rate,
        source: RateSource.live,
      );
    } catch (_) {
      final cachedRate = prefs.getDouble(cacheKey);
      if (cachedRate == null) {
        rethrow;
      }

      return CurrencyConversion(
        converted: amount * cachedRate,
        rate: cachedRate,
        source: RateSource.cached,
      );
    }
  }
}

class AdMobConfig {
  AdMobConfig._();

  // Test IDs. Replace with production IDs before release.
  static const String appId = 'ca-app-pub-3940256099942544~3347511713';
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
}

class AdController {
  static int _conversionCount = 0;
  static InterstitialAd? _interstitial;

  static void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  static void onConversionCompleted() {
    _conversionCount++;
    _loadInterstitial();

    if (_conversionCount % 3 == 0 && _interstitial != null) {
      _interstitial!.show();
      _interstitial = null;
    }
  }
}
