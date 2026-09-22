class NewsFailure implements Exception {
  final String message;

  const NewsFailure(this.message);

  @override
  String toString() => message;
}
