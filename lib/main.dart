import 'package:cron_expression_parser/cron_expression_parser.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CronApp());
}

class CronApp extends StatefulWidget {
  const CronApp({super.key});

  @override
  State<CronApp> createState() => _CronAppState();
}

class _CronAppState extends State<CronApp> {
  bool _darkMode = false;
  bool _proUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.spaceGroteskTextTheme();
    final colorSeed = const Color(0xFF0FB4A5);

    return MaterialApp(
      title: 'Cron Expression Lab',
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colorSeed),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        useMaterial3: true,
        textTheme: baseTextTheme,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorSeed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: baseTextTheme,
      ),
      home: CronHomePage(
        darkMode: _darkMode,
        proUnlocked: _proUnlocked,
        onToggleDarkMode: (value) => setState(() => _darkMode = value),
        onUnlockPro: () => setState(() => _proUnlocked = true),
      ),
    );
  }
}

enum Frequency { everyMinute, hourly, daily, weekly, monthly, custom }

class CronHomePage extends StatefulWidget {
  const CronHomePage({
    super.key,
    required this.darkMode,
    required this.proUnlocked,
    required this.onToggleDarkMode,
    required this.onUnlockPro,
  });

  final bool darkMode;
  final bool proUnlocked;
  final ValueChanged<bool> onToggleDarkMode;
  final VoidCallback onUnlockPro;

  @override
  State<CronHomePage> createState() => _CronHomePageState();
}

class _CronHomePageState extends State<CronHomePage> {
  final _cronController = TextEditingController(text: '0 17 * * 1');
  final _customController = TextEditingController(text: '*/5 * * * *');

  Frequency _frequency = Frequency.weekly;
  TimeOfDay _timeOfDay = const TimeOfDay(hour: 17, minute: 0);
  int _minuteInterval = 5;
  int _minuteOfHour = 0;
  int _dayOfMonth = 1;
  int _weekday = DateTime.monday; // 1 = Monday, 7 = Sunday

  String? _validationMessage;
  String? _meaning;
  List<DateTime> _nextRuns = const [];
  final List<String> _savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _verifyCurrent();
  }

  @override
  void dispose() {
    _cronController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _heroHeader(theme)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _builderCard(theme),
                  const SizedBox(height: 12),
                  _manualInputCard(theme),
                  const SizedBox(height: 12),
                  _resultsCard(theme),
                  const SizedBox(height: 12),
                  _savedRecipesCard(theme),
                  const SizedBox(height: 12),
                  if (!widget.proUnlocked) _adPlaceholder(theme),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1FC2AA), Color(0xFF0F8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                'Cron Expression Generator & Tester',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: widget.darkMode ? 'Switch to light' : 'Switch to dark',
                onPressed: () => widget.onToggleDarkMode(!widget.darkMode),
                icon: Icon(
                  widget.darkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pick "Every Monday at 5 PM" → get a cron. Verify any string in one tap.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _Badge(text: 'Offline-friendly UI'),
              _Badge(text: 'UTC + local preview'),
              _Badge(text: 'Save recipes (Pro)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _builderCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Build a schedule',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showProSheet(context),
                  child: const Text('Pro · \$1.99'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedButton<Frequency>(
              segments: const [
                ButtonSegment(
                  value: Frequency.everyMinute,
                  label: Text('Every minute'),
                ),
                ButtonSegment(value: Frequency.hourly, label: Text('Hourly')),
                ButtonSegment(value: Frequency.daily, label: Text('Daily')),
                ButtonSegment(value: Frequency.weekly, label: Text('Weekly')),
                ButtonSegment(value: Frequency.monthly, label: Text('Monthly')),
                ButtonSegment(value: Frequency.custom, label: Text('Custom')),
              ],
              selected: {_frequency},
              onSelectionChanged: (value) {
                setState(() => _frequency = value.first);
                _updateCronFromBuilder();
              },
            ),
            const SizedBox(height: 12),
            _builderFields(theme),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _updateCronFromBuilder,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Generate Cron'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _saveRecipe,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save recipe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _builderFields(ThemeData theme) {
    switch (_frequency) {
      case Frequency.everyMinute:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Interval (minutes)', style: theme.textTheme.labelLarge),
            Slider(
              value: _minuteInterval.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '$_minuteInterval',
              onChanged: (v) => setState(() => _minuteInterval = v.round()),
            ),
          ],
        );
      case Frequency.hourly:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('At minute', style: theme.textTheme.labelLarge),
            Slider(
              value: _minuteOfHour.toDouble(),
              min: 0,
              max: 59,
              divisions: 59,
              label: _minuteOfHour.toString().padLeft(2, '0'),
              onChanged: (v) => setState(() => _minuteOfHour = v.round()),
            ),
          ],
        );
      case Frequency.daily:
      case Frequency.weekly:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Time of day', style: theme.textTheme.labelLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule),
                  label: Text(_formatTimeOfDay(_timeOfDay)),
                ),
              ],
            ),
            if (_frequency == Frequency.weekly) ...[
              const SizedBox(height: 8),
              Text('Day of week', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: List.generate(7, (i) {
                  final weekday = i + 1; // 1..7
                  const labels = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  return ChoiceChip(
                    label: Text(labels[i]),
                    selected: _weekday == weekday,
                    onSelected: (_) => setState(() => _weekday = weekday),
                  );
                }),
              ),
            ],
          ],
        );
      case Frequency.monthly:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Time of day', style: theme.textTheme.labelLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule),
                  label: Text(_formatTimeOfDay(_timeOfDay)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Day of month', style: theme.textTheme.labelLarge),
            Slider(
              value: _dayOfMonth.toDouble(),
              min: 1,
              max: 31,
              divisions: 30,
              label: _dayOfMonth.toString(),
              onChanged: (v) => setState(() => _dayOfMonth = v.round()),
            ),
          ],
        );
      case Frequency.custom:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Custom cron (5 parts)', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: _customController,
              decoration: const InputDecoration(
                hintText: '*/15 8-18 * * 1-5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
              ),
              onChanged: (_) => _cronController.text = _customController.text,
            ),
          ],
        );
    }
  }

  Widget _manualInputCard(ThemeData theme) {
    const quickPresets = <String, String>{
      'Every 5 minutes': '*/5 * * * *',
      'Workdays 9 AM': '0 9 * * 1-5',
      'Sundays at 7 PM': '0 19 * * 0',
      '1st of month 8 AM': '0 8 1 * *',
      'Twice daily 6 & 18h': '0 6,18 * * *',
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verify any cron string',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cronController,
              decoration: InputDecoration(
                hintText: '*/5 * * * *',
                prefixIcon: const Icon(Icons.code),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _verifyCurrent(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _verifyCurrent,
                  icon: const Icon(Icons.verified),
                  label: const Text('Verify'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    _cronController.clear();
                    setState(() {
                      _validationMessage = null;
                      _meaning = null;
                      _nextRuns = const [];
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickPresets.entries
                  .map(
                    (entry) => ActionChip(
                      label: Text(entry.key),
                      onPressed: () {
                        _cronController.text = entry.value;
                        _verifyCurrent();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultsCard(ThemeData theme) {
    final isValid = _validationMessage == null;
    final badgeColor = isValid ? Colors.green : Colors.red;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'What does this cron do?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isValid ? Icons.check_circle : Icons.error_outline,
                        color: badgeColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isValid ? 'Valid' : 'Invalid',
                        style: TextStyle(color: badgeColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_validationMessage != null)
              Text(
                _validationMessage!,
                style: const TextStyle(color: Colors.red),
              )
            else ...[
              if (_meaning != null)
                Text(_meaning!, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 12),
              if (_nextRuns.isNotEmpty) ...[
                Text(
                  'Next runs (local time)',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                _nextRunsList(),
              ] else
                Text(
                  'Tap Verify to preview the schedule.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _nextRunsList() {
    final formatter = DateFormat('EEE, MMM d • h:mm a');
    return Column(
      children: _nextRuns
          .take(8)
          .map(
            (dt) => ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(formatter.format(dt.toLocal())),
              subtitle: Text('${dt.toUtc()} UTC'),
            ),
          )
          .toList(),
    );
  }

  Widget _savedRecipesCard(ThemeData theme) {
    final content = widget.proUnlocked
        ? (_savedRecipes.isEmpty
              ? Text(
                  'No recipes yet. Generate a cron then tap Save.',
                  style: theme.textTheme.bodyMedium,
                )
              : Column(
                  children: _savedRecipes
                      .map(
                        (cron) => ListTile(
                          leading: const Icon(Icons.bookmark),
                          title: Text(cron),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              _cronController.text = cron;
                              _verifyCurrent();
                            },
                          ),
                        ),
                      )
                      .toList(),
                ))
        : Row(
            children: [
              const Icon(Icons.lock_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Save recipes + Dark mode with Pro (one-time \$1.99).',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () => _showProSheet(context),
                child: const Text('Unlock'),
              ),
            ],
          );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Saved recipes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (widget.proUnlocked)
                  Switch(
                    value: widget.darkMode,
                    onChanged: (v) => widget.onToggleDarkMode(v),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _adPlaceholder(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.campaign_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ads live here on the free tier. Upgrade to Pro to hide them forever.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () => _showProSheet(context),
              child: const Text('Go Pro'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
    );
    if (picked != null) {
      setState(() => _timeOfDay = picked);
      _updateCronFromBuilder();
    }
  }

  void _updateCronFromBuilder() {
    String expression;
    switch (_frequency) {
      case Frequency.everyMinute:
        expression = '*/$_minuteInterval * * * *';
        break;
      case Frequency.hourly:
        expression = '$_minuteOfHour * * * *';
        break;
      case Frequency.daily:
        expression = '${_timeOfDay.minute} ${_timeOfDay.hour} * * *';
        break;
      case Frequency.weekly:
        expression = '${_timeOfDay.minute} ${_timeOfDay.hour} * * $_weekday';
        break;
      case Frequency.monthly:
        expression = '${_timeOfDay.minute} ${_timeOfDay.hour} $_dayOfMonth * *';
        break;
      case Frequency.custom:
        expression = _customController.text.trim();
        break;
    }
    _cronController.text = expression;
    _verifyCurrent();
  }

  void _verifyCurrent() {
    final value = _cronController.text.trim();
    try {
      final cron = Cron.parse(value);
      final now = DateTime.now().toUtc();
      final until = now.add(const Duration(days: 7));
      final runs = cron.toList(now, until).take(12).toList();
      if (runs.isEmpty) {
        setState(() {
          _validationMessage = 'No runs in the next 7 days';
          _meaning = null;
          _nextRuns = const [];
        });
        return;
      }

      final next = runs.first;
      final local = next.toLocal();
      final desc =
          'Next at ${DateFormat('EEE, MMM d h:mm a').format(local)} '
          '(${next.toUtc()} UTC).';

      setState(() {
        _validationMessage = null;
        _meaning = desc;
        _nextRuns = runs;
      });
    } catch (e) {
      setState(() {
        _validationMessage = e.toString();
        _meaning = null;
        _nextRuns = const [];
      });
    }
  }

  void _saveRecipe() {
    if (!widget.proUnlocked) {
      _showProSheet(context);
      return;
    }
    final cron = _cronController.text.trim();
    if (cron.isEmpty) return;
    if (_savedRecipes.contains(cron)) return;
    setState(() => _savedRecipes.add(cron));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved "$cron"')), // simple acknowledgement
    );
  }

  void _showProSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Cron Lab Pro',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Text('\$1.99'),
                ],
              ),
              const SizedBox(height: 12),
              const Text('• Save unlimited cron recipes'),
              const Text('• Dark mode toggle'),
              const Text('• Removes ads forever'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onUnlockPro();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pro unlocked for this demo!'),
                    ),
                  );
                },
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Unlock Pro'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final dt = DateTime(0, 1, 1, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
