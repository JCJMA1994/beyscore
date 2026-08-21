/// The 12 fine-grained capabilities of the system.
///
/// Follows SISTEMA.md:
/// There is no global `isAdmin`. Capabilities are computed per resource.
enum Capability {
  recordMatchResult,
  confirmResult,
  resolveDispute,
  applyInstantLoss,
  closeRound,
  runDraw,
  editTournament,
  viewCatalogAndDecks,
  registerToTournament,
  checkInDeck,
  publishResults,
  exportTournamentData,
}
