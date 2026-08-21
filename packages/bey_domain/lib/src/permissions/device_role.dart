/// The physical surface or role of the running device.
///
/// Follows SISTEMA.md:
/// - `phone`: Individual user or tournament organizer phone.
/// - `table`: Shared scorekeeper tablet paired with a specific table number.
/// - `wideWeb`: Spectator/wide screen dashboard in read-only mode.
enum DeviceRole {
  phone,
  table,
  wideWeb,
}
