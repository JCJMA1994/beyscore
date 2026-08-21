abstract class CatalogRemoteDataSource {
  Future<Map<String, dynamic>> fetchManifest();
  Future<List<Map<String, dynamic>>> fetchCatalog(int version);
}
