import 'dart:math';

import 'package:flutter/material.dart';

/// AIHealthAssistantPanel
///
/// Prototype panel that simulates an AI-powered health assistant.
/// - Shows simulated device health metrics and an auto-generated analysis.
/// - Lets users ask general health questions and receive mocked AI guidance.
/// - Provides a FAQ section with common questions and answers.
///
/// Integration notes (for future real AI/backend wiring):
/// - Replace [_simulateMetrics] with real device data or API calls.
/// - Replace [_analyzeMetrics] with server-side analysis or on-device ML.
/// - Replace [_mockAiAnswer] with an async call to your AI endpoint.
///   For example:
///     final answer = await healthAiApi.getAnswer(question, metrics);
/// - The widget is self-contained and can be dropped into any screen.
class AIHealthAssistantPanel extends StatefulWidget {
  const AIHealthAssistantPanel({Key? key, this.onClose}) : super(key: key);

  final VoidCallback? onClose;

  @override
  State<AIHealthAssistantPanel> createState() => _AIHealthAssistantPanelState();
}

class _AIHealthAssistantPanelState extends State<AIHealthAssistantPanel> {
  final TextEditingController _questionCtrl = TextEditingController();
  final ScrollController _analysisScroll = ScrollController();

  Map<String, dynamic>? _metrics;
  String _analysis = 'Running health analysis...';
  bool _isSending = false;
  final List<_FaqItem> _faqs = _defaultFaqs;

  @override
  void initState() {
    super.initState();
    _runSimulatedAnalysis();
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _analysisScroll.dispose();
    super.dispose();
  }

  Future<void> _runSimulatedAnalysis() async {
    // Simulate delay as if calling an API
    await Future.delayed(const Duration(milliseconds: 300));
    final metrics = _simulateMetrics();
    final analysis = _analyzeMetrics(metrics);
    if (!mounted) return;
    setState(() {
      _metrics = metrics;
      _analysis = analysis;
    });
  }

  Map<String, dynamic> _simulateMetrics() {
    // This data is mocked. In production, wire up your device/health SDK.
    final rnd = Random();
    return {
      'heartRate': 60 + rnd.nextInt(60), // bpm 60–120
      'bloodPressureSys': 100 + rnd.nextInt(40), // 100–140
      'bloodPressureDia': 60 + rnd.nextInt(30), // 60–90
      'sleepQuality': 60 + rnd.nextInt(41), // 60–100%
      'activityLevel': 3000 + rnd.nextInt(9000), // steps
      'oxygenSaturation': 94 + rnd.nextInt(6), // 94–99%
      'stressLevel': 10 + rnd.nextInt(70), // 10–80 scale
      'lastSyncMinutesAgo': rnd.nextInt(180),
    };
  }

  String _analyzeMetrics(Map<String, dynamic> m) {
    final issues = <String>[];

    // Common healthy ranges (general guidance, not medical advice)
    final hr = m['heartRate'] as int; // resting
    if (hr < 50) {
      issues.add('Your heart rate appears low. If you feel dizzy or weak, consider seeking medical advice.');
    } else if (hr > 100) {
      issues.add('Your heart rate is slightly elevated; try resting and hydrating.');
    }

    final sys = m['bloodPressureSys'] as int;
    final dia = m['bloodPressureDia'] as int;
    if (sys >= 140 || dia >= 90) {
      issues.add('Blood pressure is elevated. Monitor regularly and reduce salt/stress.');
    } else if (sys < 90 || dia < 60) {
      issues.add('Blood pressure seems low. Stand up slowly and ensure adequate fluids.');
    }

    final spo2 = m['oxygenSaturation'] as int;
    if (spo2 < 95) {
      issues.add('Oxygen saturation is a bit low; ensure good ventilation and consider deep-breathing.');
    }

    final sleep = m['sleepQuality'] as int;
    if (sleep < 75) {
      issues.add('Sleep quality could be improved. Aim for consistent schedule and limit screens before bed.');
    }

    final steps = m['activityLevel'] as int;
    if (steps < 5000) {
      issues.add('Activity level is low today. A short walk could be beneficial.');
    }

    final stress = m['stressLevel'] as int;
    if (stress > 60) {
      issues.add('Stress level appears high. Consider relaxation techniques or short breaks.');
    }

    final syncMin = m['lastSyncMinutesAgo'] as int;
    if (syncMin > 60) {
      issues.add('Data was last synced over an hour ago; connect your device to refresh.');
    }

    if (issues.isEmpty) {
      return 'Everything looks good based on your recent metrics. Keep up the healthy habits!';
    }

    return 'Here are a few observations:\n- ' + issues.join('\n- ');
  }

  Future<void> _sendQuestion() async {
    if (_questionCtrl.text.trim().isEmpty) return;
    final q = _questionCtrl.text.trim();
    setState(() => _isSending = true);

    // Simulate latency as if calling an AI API
    await Future.delayed(const Duration(milliseconds: 450));

    final answer = _mockAiAnswer(q, _metrics);

    setState(() {
      // Append to analysis area as a simple chat-like log
      _analysis += '\n\nYou: $q\nAI: $answer';
      _isSending = false;
      _questionCtrl.clear();
    });

    // Auto-scroll to bottom
    await Future.delayed(const Duration(milliseconds: 50));
    if (_analysisScroll.hasClients) {
      _analysisScroll.animateTo(
        _analysisScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  String _mockAiAnswer(String question, Map<String, dynamic>? m) {
    // Extremely simplified, rule-based responses for demo purposes.
    final q = question.toLowerCase();
    if (q.contains('heart rate') || q.contains('hr')) {
      return 'A normal resting heart rate for adults is typically 60–100 bpm. If you just exercised or had caffeine, it may be higher; rest and recheck.';
    }
    if (q.contains('blood pressure') || q.contains('bp')) {
      return 'Typical optimal blood pressure is around 120/80 mmHg. Consistently 140/90 or higher can be considered elevated; monitor and consult a clinician if persistent.';
    }
    if (q.contains('sleep')) {
      return 'Aim for 7–9 hours of sleep with good sleep hygiene (consistent schedule, dark/quiet room, limited screens before bed).';
    }
    if (q.contains('oxygen') || q.contains('spo2')) {
      return 'Normal SpO₂ is usually 95–99% at sea level. If you feel short of breath or values are repeatedly low, seek medical advice.';
    }
    if (q.contains('steps') || q.contains('activity')) {
      return 'General activity goals are 7k–10k steps/day for many adults, but any movement helps. Start where you are and increase gradually.';
    }
    if (q.contains('stress')) {
      return 'Try short breathing exercises (4-7-8), brief walks, or mindfulness breaks. If stress is persistent, talk to a professional.';
    }
    return 'I can provide general wellness guidance. For specific concerns, consult a healthcare professional. How can I help further?';
  }

  void _openFaq() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.help_center, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Health Assistant FAQ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = _faqs[index];
                      return ExpansionTile(
                        title: Text(item.question, style: const TextStyle(fontWeight: FontWeight.w600)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(item.answer),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: _faqs.length,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
              // Height enough to sit above a bottom nav bar while showing content
              maxHeight: 380,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.monitor_heart, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Health Assistant',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _openFaq,
                        icon: const Icon(Icons.help_outline),
                        label: const Text('FAQ'),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Analysis text area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _analysisScroll,
                          child: Text(
                            _analysis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Input row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _questionCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Ask a health question...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _sendQuestion(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: _isSending ? null : _sendQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: _isSending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send),
                          label: const Text('Send'),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

const List<_FaqItem> _defaultFaqs = [
  _FaqItem(
    'What is a normal resting heart rate?',
    'For most adults, 60–100 bpm is considered typical at rest. Athletes can be lower. Persistent values outside this range may warrant evaluation.',
  ),
  _FaqItem(
    'What blood pressure is considered high?',
    'Readings consistently ≥140/90 mmHg are generally considered high. Reduce salt, manage stress, and consult a clinician if persistent.',
  ),
  _FaqItem(
    'How much sleep do I need?',
    'Most adults benefit from 7–9 hours nightly. Keep a consistent schedule and reduce screen exposure before bed.',
  ),
  _FaqItem(
    'What is normal blood oxygen (SpO₂)?',
    'Typically 95–99% at sea level. Values can be lower at altitude. Seek care if low values accompany symptoms like shortness of breath.',
  ),
  _FaqItem(
    'How many steps should I aim for per day?',
    'A common goal is 7k–10k steps/day, but any increase in daily movement helps. Customize goals based on fitness level.',
  ),
  _FaqItem(
    'How can I lower stress levels?',
    'Try breathing exercises, short walks, mindfulness, and adequate sleep. If stress affects daily life, consider professional support.',
  ),
];
