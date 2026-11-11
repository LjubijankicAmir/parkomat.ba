import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AssetModule {
  /// The app's bundled assets. Tests pass their own bundle.
  @lazySingleton
  AssetBundle get assetBundle => rootBundle;
}
