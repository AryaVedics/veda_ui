// The small banner ad that every Véda app except Cycle carries, written once so
// the apps cannot drift apart: the same non-personalized request, the same
// consent step (Google's UMP in Europe and the UK), the same placement above
// the tab bar, the same retry. Véda itself has its own copy of this code in
// flutter_app/lib/widgets/ad_banner.dart and services/ads_service.dart; keep
// the two behaving alike.

library;

export 'src/ad_banner.dart';
export 'src/ads_service.dart';
