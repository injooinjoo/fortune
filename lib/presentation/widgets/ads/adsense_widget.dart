// Conditional imports for web and non-web platforms
export 'adsense_widget_stub.dart'
    if (dart.library.html) 'adsense_widget_web.dart';