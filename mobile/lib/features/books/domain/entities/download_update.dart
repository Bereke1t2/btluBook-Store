class DownloadUpdate {
  final double progress;
  final String? bookPath;
  final String? coverPath;
  final bool isCompleted;

  DownloadUpdate({
    required this.progress,
    this.bookPath,
    this.coverPath,
    this.isCompleted = false,
  });
}
