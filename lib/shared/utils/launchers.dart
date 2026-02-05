import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchWhatsApp({
  required BuildContext context,
  required String number,
  required String message,
}) async {
  final digitsOnly = number.replaceAll(RegExp(r'\\D'), '');
  if (digitsOnly.isEmpty) {
    _showSnack(context, 'Invalid phone number.');
    return;
  }

  final encodedMessage = Uri.encodeComponent(message);
  final deepLink =
      Uri.parse('whatsapp://send?phone=$digitsOnly&text=$encodedMessage');
  final waMe = Uri.parse('https://wa.me/$digitsOnly?text=$encodedMessage');

  try {
    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink, mode: LaunchMode.externalApplication);
      return;
    }
    if (await canLaunchUrl(waMe)) {
      await launchUrl(waMe, mode: LaunchMode.externalApplication);
      return;
    }
  } catch (_) {
    // Fall through to fallback handling.
  }

  await Clipboard.setData(
    ClipboardData(text: '$number\\n$message'),
  );
  _showSnack(context, 'WhatsApp not installed. Number copied.');

  final marketUrl = Uri.parse('market://details?id=com.whatsapp');
  final webUrl = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.whatsapp',
  );
  if (await canLaunchUrl(marketUrl)) {
    await launchUrl(marketUrl, mode: LaunchMode.externalApplication);
  } else if (await canLaunchUrl(webUrl)) {
    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
