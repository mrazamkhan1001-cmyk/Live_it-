class Artist {
  final String id;
  final String name;
  final String imageUrl;
  final String monthlyListeners;
  final bool isVerified;

  Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.monthlyListeners,
    this.isVerified = true,
  });
}
