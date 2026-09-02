/// How large the AAC symbols are drawn.
///
/// Straight from the AAC design literature: image magnification, with the
/// size under the user's control, is a repeated recommendation for this
/// audience. Vision varies, and so does the amount of visual field a child
/// can scan comfortably — a board that suits one child is unusable for
/// another at the same size.
///
/// The trade-off is real and worth stating in the UI: bigger symbols mean
/// fewer cards on screen and more scrolling. The subtitle says so, because
/// a caregiver choosing this should be choosing knowingly.
enum SymbolScale {
  /// Roughly two columns on a phone.
  comfortable(184, 190),

  /// Noticeably larger symbol, about one fewer column.
  large(228, 236),

  /// For low vision or a very narrow visual field.
  largest(280, 292);

  const SymbolScale(this.maxExtent, this.mainExtent);

  /// Maximum tile width handed to the grid delegate.
  final double maxExtent;

  /// Tile height. Scales with width so the symbol keeps its share of the
  /// tile rather than the caption growing to fill the extra room.
  final double mainExtent;
}
