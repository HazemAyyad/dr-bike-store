enum FavoritesCapability { unsupported, remote }

enum FavoriteMutationResult { unsupported, invalidIdentity }

/// Capability boundary for Favorites. No HTTP dependency is accepted until an
/// authoritative Store endpoint is specified by the backend.
class FavoritesRepository {
  const FavoritesRepository();

  FavoritesCapability get capability => FavoritesCapability.unsupported;
  bool get supportsRemoteFavorites => capability == FavoritesCapability.remote;

  FavoriteMutationResult requestMutation({
    required int? listingId,
    int? productId,
  }) {
    if (listingId == null || listingId <= 0) {
      return FavoriteMutationResult.invalidIdentity;
    }
    return FavoriteMutationResult.unsupported;
  }
}
