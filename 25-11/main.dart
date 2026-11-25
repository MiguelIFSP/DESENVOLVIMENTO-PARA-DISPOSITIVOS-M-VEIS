import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Atividades',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ActivitiesPage(),
    );
  }
}

class Activity {
  final String date;
  final String description;

  Activity({required this.date, required this.description});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      date: json['date'].toString(),
      description: json['description'].toString(),
    );
  }
}

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();

  static String get _apiUrl {
    if (kIsWeb) return 'http://127.0.0.1/atividades_api/api.php';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/atividades_api/api.php';
    }
    return 'http://127.0.0.1/atividades_api/api.php';
  }

  List<Activity> _activities = [];
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _dayController.text = _formatDate(_selectedDate);
    _loadActivities();
  }

  @override
  void dispose() {
    _activityController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _isoDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null ||
        month == null ||
        year == null ||
        year < 1000 ||
        year > 9999) {
      return null;
    }

    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  Future<void> _loadActivities() async {
    setState(() => _loading = true);

    try {
      final uri = Uri.parse(_apiUrl).replace(queryParameters: {
        'year': _selectedMonth.year.toString(),
        'month': _selectedMonth.month.toString(),
      });
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final items = data['activities'] as List<dynamic>? ?? [];
        setState(() {
          _activities = items
              .map((item) => Activity.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      } else {
        _showMessage('Não foi possível carregar as atividades.');
      }
    } catch (_) {
      _showMessage('Erro ao conectar ao servidor XAMPP.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addActivity() async {
    final date = _parseDate(_dayController.text);
    final description = _activityController.text.trim();

    if (date == null) {
      _showMessage('Informe uma data válida no formato dd/mm/aaaa.');
      return;
    }
    if (description.isEmpty) {
      _showMessage('Digite a atividade realizada.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': _isoDate(date),
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        _activityController.clear();
        setState(() {
          _selectedMonth = DateTime(date.year, date.month);
        });
        await _loadActivities();
        _showMessage('Atividade cadastrada com sucesso!');
      } else {
        _showMessage('Não foi possível salvar a atividade.');
      }
    } catch (_) {
      _showMessage('Erro ao conectar ao servidor XAMPP.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _monthName(int month) {
    const names = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return names[month];
  }

  List<Activity> get _monthActivities {
    final result = _activities.where((activity) {
      final date = DateTime.parse(activity.date);
      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month;
    }).toList();

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List<DateTime>.generate(
      24,
      (index) => DateTime(now.year, now.month - index),
    );

    if (!_loading &&
        !months.any((month) =>
            month.year == _selectedMonth.year &&
            month.month == _selectedMonth.month)) {
      months.insert(0, _selectedMonth);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividades do Dia'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Nova atividade',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _dayController,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  labelText: 'Dia (dd/mm/aaaa)',
                                  hintText: 'dd/mm/aaaa',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _activityController,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _addActivity(),
                                decoration: const InputDecoration(
                                  labelText: 'Atividade',
                                  hintText: 'Ex: Estudei Flutter',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _addActivity,
                                icon: const Icon(Icons.save),
                                label: const Text('Salvar atividade'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<DateTime>(
                        value: _selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Selecionar mês',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        items: months.map((month) {
                          return DropdownMenuItem<DateTime>(
                            value: month,
                            child: Text(
                                '${_monthName(month.month)} de ${month.year}'),
                          );
                        }).toList(),
                        onChanged: (month) {
                          if (month != null) {
                            setState(() => _selectedMonth = month);
                            _loadActivities();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Atividades de ${_monthName(_selectedMonth.month)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (_monthActivities.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Nenhuma atividade cadastrada neste mês.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ..._monthActivities.map((activity) {
                          final date = DateTime.parse(activity.date);
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(date.day.toString()),
                              ),
                              title: Text(activity.description),
                              subtitle: Text(_formatDate(date)),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}


