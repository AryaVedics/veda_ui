// The look every Véda app shares (see FAMILY-LOOK.md in veda_core's
// flutter_app/design/family_icons): one place for the colours, the display
// font, the theme, the tab bar, the header with the app's medallion, cards,
// the logo menu, and the single JSON file each app keeps on the phone.
//
// An app picks its palette (AppColors.peacock, .nightfall, .wine, .umber) and
// supplies its own mark image; everything else is the same everywhere.

library;

export 'package:phosphor_flutter/phosphor_flutter.dart';

export 'src/app_colors.dart';
export 'src/backup.dart';
export 'src/brand.dart';
export 'src/calendar.dart';
export 'src/breathing.dart';
export 'src/chart_style.dart';
export 'src/charts.dart';
export 'src/common.dart';
export 'src/group_metrics.dart';
export 'src/heart_pulse_icon.dart';
export 'src/json_store.dart';
export 'src/link_bridge.dart';
export 'src/link_section.dart';
export 'src/logo_menu.dart';
export 'src/notice_carousel.dart';
export 'src/open_veda.dart';
export 'src/metric_info.dart' show MetricInfo, metricInfoByKey, metricInfoList;
export 'src/metric_ghost.dart' show GhostMetricChart;
export 'src/metric_views.dart';
export 'src/profile_sections.dart';
export 'src/restore_inbox.dart';
export 'src/score_ring.dart';
export 'src/shelf_glyph.dart';
export 'src/score_glow.dart';
export 'src/skin_tab.dart';
export 'src/support.dart';
export 'src/theme.dart';
export 'src/veda_link.dart';
export 'src/veda_tab_bar.dart';
