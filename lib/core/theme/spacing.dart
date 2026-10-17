import 'package:flutter/material.dart';

/// One spacing scale for the whole app, so rhythm is a decision made once.
abstract final class Gap {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 48;

  static const SizedBox hxs = SizedBox(height: xs);
  static const SizedBox hs = SizedBox(height: s);
  static const SizedBox hm = SizedBox(height: m);
  static const SizedBox hl = SizedBox(height: l);
  static const SizedBox hxl = SizedBox(height: xl);
  static const SizedBox hxxl = SizedBox(height: xxl);

  static const SizedBox wxs = SizedBox(width: xs);
  static const SizedBox ws = SizedBox(width: s);
  static const SizedBox wm = SizedBox(width: m);
  static const SizedBox wl = SizedBox(width: l);
  static const SizedBox wxl = SizedBox(width: xl);
}

/// Corner radii. Round things are the brand, so the scale starts generous.
abstract final class Radii {
  static const double s = 12;
  static const double m = 18;
  static const double l = 24;
  static const double xl = 32;

  static const BorderRadius brS = BorderRadius.all(Radius.circular(s));
  static const BorderRadius brM = BorderRadius.all(Radius.circular(m));
  static const BorderRadius brL = BorderRadius.all(Radius.circular(l));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
}
