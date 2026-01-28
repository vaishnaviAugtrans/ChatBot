import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

var _dialogContext;
bool _checkingPermission = false;
bool _dialogShowing = false;

Future<void> ensureLocationPermission(BuildContext context) async {
  if (_checkingPermission) return; // STOP re-entry
  _checkingPermission = true;

  try {
    // Check service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showIfNotShowing(
        context,
        title: "Enable Location",
        message: "Please turn on location services.",
        openSettings: Geolocator.openLocationSettings,
      );
      return;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Permanently denied
    if (permission == LocationPermission.deniedForever) {
      _showIfNotShowing(
        context,
        title: "Permission Required",
        message:
        "Location permission is permanently denied. Please enable it from settings.",
        openSettings: openAppSettings,
      );
      return;
    }

    // Still denied
    if (permission == LocationPermission.denied) {
      _showIfNotShowing(
        context,
        title: "Location Required",
        message: "Location permission is mandatory to use this app.",
      );
      return;
    }

    // Permission granted → close dialog
    if (_dialogShowing && _dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
    }

    _dialogContext = null;
    _dialogShowing = false;
  } finally {
    _checkingPermission = false; // unlock
  }
}

void _showIfNotShowing(
    BuildContext context, {
      required String title,
      required String message,
      VoidCallback? openSettings,
    }) {
  if (_dialogShowing) return;

  _dialogShowing = true;

  _showLocationDialog(
    context,
    title: title,
    message: message,
    openSettings: openSettings,
  );
}

void _showLocationDialog(
    BuildContext context, {
      required String title,
      required String message,
      VoidCallback? openSettings,
    }) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      _dialogContext = dialogCtx;

      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (openSettings != null)
            TextButton(
              onPressed: openSettings, // just open settings
              child: const Text("Open Settings"),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop(); // just close dialog
                _dialogContext = null;
                _dialogShowing = false;
              },
              child: const Text("Retry"),
            ),
        ],
      );
    },
  );
}