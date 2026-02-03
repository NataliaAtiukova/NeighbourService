import 'package:url_launcher/url_launcher.dart';

Future<void> launchWhatsApp(String number) async {
  final sanitized = number.replaceAll(RegExp(r'[^0-9+]'), '');
  final uri = Uri.parse('https://wa.me/${sanitized.replaceAll('+', '')}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
