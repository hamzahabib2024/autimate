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

/// A fixed grid shape, rather than a maximum tile size.
///
/// [SymbolScale] answers "how big should a symbol be"; this answers "how many
/// cards should be on screen at once", which is a different question with a
/// different reason behind it. A child with limited motor control needs
/// bigger targets *and fewer of them*; a child with a narrow visual field
/// needs fewer regardless of size.
///
/// **The trade-off worth stating.** A fixed grid is what makes motor
/// planning possible — a word keeps one position and is found by the path
/// the hand takes. But the board currently re-flows when a category filter
/// is applied, so that benefit is not yet real. Choosing a grid size here is
/// groundwork for fixed positions rather than a delivery of them, and the
/// caregiver screen says so rather than implying more than is true.
enum GridShape {
  /// Four cards. For a first board, or severe motor difficulty.
  twoByTwo(2, 2),

  /// Six cards.
  threeByTwo(3, 2),

  /// Nine cards. A common starting board in AAC practice.
  threeByThree(3, 3),

  /// Twelve cards.
  fourByThree(4, 3),

  /// Twenty cards.
  fiveByFour(5, 4),

  /// Forty-eight cards. Only workable on a tablet.
  sixByEight(6, 8),

  /// No fixed shape: tiles flow to fit, sized by [SymbolScale]. The current
  /// default, and the only option that scrolls rather than paginating.
  flowing(0, 0);

  const GridShape(this.columns, this.rows);

  final int columns;
  final int rows;

  bool get isFixed => columns > 0 && rows > 0;

  /// How many cards fit on one page. Zero means unbounded.
  int get capacity => columns * rows;

  /// Aspect ratio for a tile in this shape. Fewer cards means squarer,
  /// larger targets; a dense grid necessarily gets shorter tiles.
  double get childAspectRatio => switch (this) {
    GridShape.twoByTwo => 0.95,
    GridShape.threeByTwo => 0.95,
    GridShape.threeByThree => 0.90,
    GridShape.fourByThree => 0.85,
    GridShape.fiveByFour => 0.82,
    GridShape.sixByEight => 0.80,
    GridShape.flowing => 0.95,
  };

  /// Label key suffix, so the l10n lookup stays exhaustive.
  String get labelKey => name;
}
