import 'dart:html' as html;

void cleanUrlInBrowser(String cleanUrl) {
  html.window.history.replaceState(null, '', cleanUrl);
}