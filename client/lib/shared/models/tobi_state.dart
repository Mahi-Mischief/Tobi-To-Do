class TobiState {
  final String animationName;
  final int frameCount;
  final int fps;
  final bool loop;

  const TobiState({
    required this.animationName,
    this.frameCount = 36,
    this.fps = 12,
    this.loop = true,
  });
}
