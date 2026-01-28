import 'package:flutter/material.dart';

class Dimensions {
  static double _scaleFactor(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 320) return 0.75; // Very small screens (e.g., older phones)
    if (width < 360) return 0.85; // Small screens (e.g., smaller phones)
    if (width < 400) return 1.1;  // Medium screens (e.g., standard phones)
    if (width < 600) return 1.2;  // Large screens (e.g., larger phones)
    if (width < 800) return 1.3;  // Extra-large screens (e.g., tablets in portrait)
    return 1.4; // Very large screens (e.g., tablets in landscape or large devices)
  }

  static double xlargeTextSize(BuildContext context) {
    return 22.0 * _scaleFactor(context);
  }

  static double largerTextSize(BuildContext context) {
    return 19.0 * _scaleFactor(context);
  }

  static double largeTextSize(BuildContext context) {
    return 15.0 * _scaleFactor(context);
  }

  static double mediumTextSize(BuildContext context) {
    return 13.0 * _scaleFactor(context);
  }

  static double navigationTitleSize(BuildContext context) {
    return 11.0 * _scaleFactor(context);
  }

  static double smallTextSize(BuildContext context) {
    return 11.0 * _scaleFactor(context);
  }

  static double superSmallTextSize(BuildContext context) {
    return 9.0 * _scaleFactor(context);
  }

  static double smallerTextSize(BuildContext context) {
    return 7.0 * _scaleFactor(context);
  }

  static double subheadingTextSize(BuildContext context) {
    return 7.0 * _scaleFactor(context);
  }

  static double utilizationTextSize(BuildContext context) {
    return 12.0 * _scaleFactor(context);
  }

  static double level1Margin(BuildContext context) {
    return 4.0 * _scaleFactor(context);
  }

  static double level2Margin(BuildContext context) {
    return 8.0 * _scaleFactor(context);
  }

  static double level3Margin(BuildContext context) {
    return 16.0 * _scaleFactor(context);
  }

  static double level4Margin(BuildContext context) {
    return 32.0 * _scaleFactor(context);
  }

  static double level5Margin(BuildContext context) {
    return 50.0 * _scaleFactor(context);
  }

  static double stepperMargin(BuildContext context) {
    return 6.0 * _scaleFactor(context);
  }

  static double level0Padding(BuildContext context) {
    return 2.0 * _scaleFactor(context);
  }

  static double level1Padding(BuildContext context) {
    return 4.0 * _scaleFactor(context);
  }

  static double level2Padding(BuildContext context) {
    return 8.0 * _scaleFactor(context);
  }

  static double iconSize(BuildContext context) {
    return 25.0 * _scaleFactor(context);
  }

  static double smallSize(BuildContext context) {
    return 40.0 * _scaleFactor(context);
  }

  static double level1Size(BuildContext context) {
    return 50.0 * _scaleFactor(context);
  }

  static double level2Size(BuildContext context) {
    return 75.0 * _scaleFactor(context);
  }

  static double level3Size(BuildContext context) {
    return 100.0 * _scaleFactor(context);
  }

  static double level4Size(BuildContext context) {
    return 125.0 * _scaleFactor(context);
  }

  static double level5Size(BuildContext context) {
    return 150.0 * _scaleFactor(context);
  }

  static double level6Size(BuildContext context) {
    return 200.0 * _scaleFactor(context);
  }

  static double level7Size(BuildContext context) {
    return 380.0 * _scaleFactor(context);
  }
}
