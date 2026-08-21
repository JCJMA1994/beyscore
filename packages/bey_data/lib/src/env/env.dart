/// Environment configuration.
///
/// Build-time constants for cloud sync via Supabase.
class Env {
  const Env._({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;

  static const current = Env._(
    supabaseUrl: String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://dhbhcaxkxbqxyodwrsas.supabase.co',
    ),
    supabaseAnonKey: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRoYmhjYXhreGJxeHlvZHdyc2FzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4OTc2OTEsImV4cCI6MjEwMjQ3MzY5MX0.RyF4RH4x_eiKx3Pt9Ek-EPvQh0Ibl3qNeRUovKNr3CU',
    ),
  );

  static bool get hasSupabaseConfig =>
      current.supabaseUrl.isNotEmpty && current.supabaseAnonKey.isNotEmpty;
}
