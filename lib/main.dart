import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convertor Monedă',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CurrencyConverterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();

  // Cursuri valutare (față de MDL - Leul moldovenesc)
  Map<String, double> _exchangeRates = {
    'MDL': 1.0,
    'EUR': 20.1352,
    'USD': 17.5585,
    'GBP': 23.4668,
    'RON': 3.8234,
    'UAH': 0.3919,
  };

  String _sourceCurrency = 'MDL';
  String _targetCurrency = 'EUR';
  String _convertedAmount = '';
  bool _isLoading = false;
  String _lastUpdate = 'Niciodată';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchExchangeRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://www.curs.md/ro/curs_valutar/oficial'),
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        Map<String, double> newRates = {'MDL': 1.0};

        // Structura tabelului pe curs.md:
        // Coloana 0: Cod valută (EUR, USD, etc.)
        // Coloana 1: Denumire valută (link)
        // Coloana 2: Cursul valutar în MDL (cu virgulă ca separator zecimal)
        final rows = document.querySelectorAll('table tr');

        for (var row in rows) {
          final cells = row.querySelectorAll('td');

          // Fiecare rând are 7 coloane
          if (cells.length >= 3) {
            // Coloana 0: Codul valutei
            final currencyCode = cells[0].text.trim();

            // Coloana 2: Cursul valutar
            String rateText = cells[2].text.trim();

            // Curățăm textul: înlocuim virgula cu punct, eliminăm spații și alte caractere
            rateText = rateText
                .replaceAll(',', '.')
                .replaceAll(' ', '')
                .replaceAll('\n', '')
                .replaceAll('\r', '')
                .trim();

            final rate = double.tryParse(rateText);

            // Validăm: cod de 2-3 caractere majuscule + rată validă
            if (currencyCode.length >= 2 &&
                currencyCode.length <= 4 && // unele coduri pot avea 4 caractere
                currencyCode.toUpperCase() == currencyCode &&
                RegExp(r'^[A-Z]+$').hasMatch(currencyCode) && // doar litere
                rate != null &&
                rate > 0) {
              newRates[currencyCode] = rate;
            }
          }
        }

        if (newRates.length > 1) {
          setState(() {
            _exchangeRates = newRates;
            _lastUpdate = DateTime.now().toString().substring(0, 16);
            _isLoading = false;

            // Verificăm dacă monedele selectate există în noile rate
            if (!_exchangeRates.containsKey(_sourceCurrency)) {
              _sourceCurrency = 'MDL';
            }
            if (!_exchangeRates.containsKey(_targetCurrency)) {
              _targetCurrency = _exchangeRates.keys.firstWhere(
                (key) => key != 'MDL',
                orElse: () => 'EUR',
              );
            }
          });
        } else {
          throw Exception('Nu s-au putut extrage cursurile valutare. Site-ul poate fi temporar indisponibil.');
        }
      } else {
        throw Exception('Eroare la încărcarea datelor: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Eroare: ${e.toString()}';
      });
    }
  }

  void _convertCurrency() {
    final String amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      setState(() {
        _convertedAmount = 'Vă rugăm introduceți o sumă';
      });
      return;
    }

    final double? amount = double.tryParse(amountText);

    if (amount == null || amount < 0) {
      setState(() {
        _convertedAmount = 'Sumă invalidă';
      });
      return;
    }

    // Conversie: sumă în moneda sursă -> MDL -> moneda destinație
    final double amountInMDL = amount * _exchangeRates[_sourceCurrency]!;
    final double convertedValue = amountInMDL / _exchangeRates[_targetCurrency]!;

    setState(() {
      _convertedAmount = '${convertedValue.toStringAsFixed(4)} $_targetCurrency';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertor Monedă'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchExchangeRates,
            tooltip: 'Actualizează cursurile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon decorativ
            const Icon(
              Icons.currency_exchange,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Indicator de încărcare / ultima actualizare
            Card(
              color: _isLoading ? Colors.blue.shade50 : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _isLoading
                          ? 'Actualizare cursuri...'
                          : 'Actualizat: $_lastUpdate',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isLoading ? Colors.blue.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Mesaj de eroare dacă există
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // TextField pentru introducerea sumei
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Suma',
                hintText: 'Introduceți suma de convertit',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            // Card pentru moneda sursă
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Din:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _sourceCurrency,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_circle),
                      elevation: 16,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      underline: Container(
                        height: 2,
                        color: Colors.blue,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _sourceCurrency = newValue!;
                          _convertedAmount = '';
                        });
                      },
                      items: (_exchangeRates.keys.toList()..sort())
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            '$value (${_exchangeRates[value]!.toStringAsFixed(4)} MDL)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Icon săgeată conversie
            const Center(
              child: Icon(
                Icons.swap_vert,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            // Card pentru moneda destinație
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'În:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _targetCurrency,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_circle),
                      elevation: 16,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      underline: Container(
                        height: 2,
                        color: Colors.green,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _targetCurrency = newValue!;
                          _convertedAmount = '';
                        });
                      },
                      items: (_exchangeRates.keys.toList()..sort())
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            '$value (${_exchangeRates[value]!.toStringAsFixed(4)} MDL)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Buton pentru conversie
            ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('CONVERTEȘTE'),
            ),
            const SizedBox(height: 32),

            // Rezultatul conversiei
            if (_convertedAmount.isNotEmpty)
              Card(
                color: Colors.green.shade50,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Rezultat:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _convertedAmount,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            // Informații despre sursa datelor
            const SizedBox(height: 24),
            Card(
              color: const Color(0xFFF5F5F5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Cursuri valutare live',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sursa: Banca Națională a Moldovei (BNM)',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Website: curs.md',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Valute disponibile: ${_exchangeRates.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
