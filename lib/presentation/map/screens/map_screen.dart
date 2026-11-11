import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:parkomat/core/l10n/l10n.dart';

@RoutePage()
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(context.l10n.appTitle)));
  }
}
