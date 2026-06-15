import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const GlobalCalcApp());
}

class GlobalCalcApp extends StatelessWidget {
  const GlobalCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlobalCalc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A84FF)),
        useMaterial3: true,
      ),
      home: const GlobalCalcHomePage(),
    );
  }
}

class GlobalCalcHomePage extends StatelessWidget {
  const GlobalCalcHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GlobalCalc'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: 'Tips'),
              Tab(icon: Icon(Icons.currency_exchange), text: 'Currency'),
              Tab(icon: Icon(Icons.local_offer), text: 'Discount'),
              Tab(icon: Icon(Icons.percent), text: 'Percentages'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TipCalculatorTab(),
            CurrencyConverterTab(),
            DiscountCalculatorTab(),
            PercentageCalculatorTab(),
          ],
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
            decoration: const InputDecoration(labelText: 'Bill amount'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text('Tip: ${_tipPercent.toStringAsFixed(0)}%'),
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
            decoration: const InputDecoration(labelText: 'Split by people'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          _ResultLine(label: 'Tip amount', value: tipAmount),
          _ResultLine(label: 'Total with tip', value: total),
          _ResultLine(label: 'Per person', value: perPerson),
        ],
      ),
    );
  }
}

class CurrencyConverterTab extends StatefulWidget {
  const CurrencyConverterTab({super.key});

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
  double? _converted;
  double? _rate;
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
        _converted = result.converted;
        _rate = result.rate;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not fetch exchange rate. Check connection and try again.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CalculatorContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _from,
                  decoration: const InputDecoration(labelText: 'From'),
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
                  decoration: const InputDecoration(labelText: 'To'),
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
            label: const Text('Convert now'),
          ),
          const SizedBox(height: 20),
          if (_converted != null)
            Text(
              '${_amountController.text} $_from = ${_converted!.toStringAsFixed(4)} $_to',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          if (_rate != null)
            Text('1 $_from = ${_rate!.toStringAsFixed(6)} $_to'),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          const Spacer(),
          Text(
            'No backend needed: rates fetched directly from Frankfurter API.',
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
            decoration: const InputDecoration(labelText: 'Original price'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text('Discount: ${_discountPercent.toStringAsFixed(0)}%'),
          Slider(
            value: _discountPercent,
            min: 0,
            max: 90,
            divisions: 90,
            label: _discountPercent.toStringAsFixed(0),
            onChanged: (value) => setState(() => _discountPercent = value),
          ),
          const SizedBox(height: 24),
          _ResultLine(label: 'You save', value: saved),
          _ResultLine(label: 'Final price', value: finalPrice),
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
    final number = _toDouble(_numberController.text);
    final percent = _toDouble(_percentController.text);
    final part = _toDouble(_partController.text);
    final whole = _toDouble(_wholeController.text);
    final percentOfNumber = number * (percent / 100);
    final whatPercent = whole == 0 ? 0 : (part / whole) * 100;

    return _CalculatorContainer(
      child: ListView(
        children: [
          Text('A) What is X% of N?', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _numberController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'N (number)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _percentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'X (percent)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _ResultLine(label: 'Result', value: percentOfNumber),
          const SizedBox(height: 24),
          Text('B) Part is what % of whole?', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _partController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Part'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _wholeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Whole'),
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

class CurrencyService {
  static Future<CurrencyConversion> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (from == to) {
      return CurrencyConversion(converted: amount, rate: 1);
    }

    final uri = Uri.parse(
      'https://api.frankfurter.app/latest?amount=$amount&from=$from&to=$to',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = map['rates'] as Map<String, dynamic>;
    final converted = (rates[to] as num).toDouble();
    final double rate = amount == 0 ? 0.0 : converted / amount;

    return CurrencyConversion(converted: converted, rate: rate);
  }
}

class CurrencyConversion {
  CurrencyConversion({required this.converted, required this.rate});

  final double converted;
  final double rate;
}
