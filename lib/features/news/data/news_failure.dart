/// Domain-level failure surfaced to the caller instead of a DioException.
class NewsFailure implements Exception {
  final String message;

  const NewsFailure(this.message);

  @override
  String toString() => message;
}