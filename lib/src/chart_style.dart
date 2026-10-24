// How this app draws its charts (Rings, Petals or Bars): one choice, shared by
// every chart in the app, the app's own default (Petals unless the app says
// otherwise) until the person picks. Changing it
// anywhere (a chart's own switch, or Profile) changes every chart at once, and
// it is remembered on the phone.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'common.dart';
import 'metric_views.dart';

const _key = 'metric_chart_style';

class ChartStylePref {
  ChartStylePref._();

  static final instance = ChartStylePref._();

  /// The style every chart follows.
  final ValueNotifier<MetricStyle> style = ValueNotifier(MetricStyle.petals);

  bool _loaded = false;

  /// [defaultStyle] is what this app shows until the person picks one.
  Future<void> load({MetricStyle defaultStyle = MetricStyle.petals}) async {
    if (_loaded) return;
    _loaded = true;
    style.value = defaultStyle;
    try {
      final saved = (await SharedPreferences.getInstance()).getString(_key);
      final s = MetricStyle.values.where((v) => v.name == saved).firstOrNull;
      if (s != null) style.value = s;
    } catch (_) {
      // The app's default.
    }
  }

  Future<void> set(MetricStyle s) async {
    style.value = s;
    try {
      await (await SharedPreferences.getInstance()).setString(_key, s.name);
    } catch (_) {
      // Still applies for this session.
    }
  }
}

/// Profile's row for it: "Charts" with the same Rings, Petals, Bars switch.
class ChartStyleSection extends StatelessWidget {
  const ChartStyleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How charts are drawn',
            style: TextStyle(fontSize: 14, color: colors.textPrimary),
          ),
          const SizedBox(height: 3),
          Text(
            'Rings, petals or bars. Every chart in this app follows it, and a '
            "chart's own switch changes it too.",
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<MetricStyle>(
            valueListenable: ChartStylePref.instance.style,
            builder: (context, s, _) => MetricStyleToggle(
              value: s,
              onChanged: ChartStylePref.instance.set,
            ),
          ),
        ],
      ),
    );
  }
}
