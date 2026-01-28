import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dimensions.dart';

class CommonMethods{
  // Method to show SnackBar
  static void showSnackBar(
      BuildContext context,
      String message, {
        Color? backgroundColor,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontSize: Dimensions.mediumTextSize(context),
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      backgroundColor: backgroundColor ??
          (isDark ? Colors.grey[900] : Colors.white), // default color based on theme
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 30.0, left: 10.0, right: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String convertDate(String? date1, String? inputFormatPattern, String? outputFormatPattern) {
    print("date1:$date1");
    print("inputFormatPattern:$inputFormatPattern");
    print("outputFormatPattern:$outputFormatPattern");

    if (date1 == null || inputFormatPattern == null || outputFormatPattern == null) {
      return ""; // Return empty string if any value is null
    }

    try {
      DateTime parsedDate = DateFormat(inputFormatPattern).parse(date1);
      String formattedDate = DateFormat(outputFormatPattern).format(parsedDate);
      print(formattedDate); // Print the converted date (like Kotlin's println)
      return formattedDate;
    } catch (e) {
      print("Date conversion error: $e");
      return ""; // Return empty string if parsing fails
    }
  }
}