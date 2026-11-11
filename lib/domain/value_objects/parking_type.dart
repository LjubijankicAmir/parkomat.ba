/// What kind of parking a place is. Each has its own glyph and color.
enum ParkingType {
  /// A multi-storey garage above ground, drawn as a 3D volume.
  garage,

  /// An underground garage, drawn as a dashed footprint.
  underground,

  /// An open lot.
  lot,

  /// A paid street zone. On the map these are the zone lines.
  street,
}
