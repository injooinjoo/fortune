// Helper function for lerping doubles
double? lerpDouble(num? a, num? b, double t) {
  if (a == null || b == null) return null;
  return a + (b - a) * t;
}
