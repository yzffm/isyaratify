import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/sign_media_model.dart';

/// Area peragaan isyarat huruf BISINDO pada panel inspektor kamus.
///
/// Menampilkan video loop dari API publik Wikimedia Commons beserta atribusi
/// lisensi (CC BY-SA 4.0). Setiap kondisi (memuat, gagal, tidak tersedia)
/// ditampilkan eksplisit — tidak ada kegagalan senyap.
class SignMediaPanel extends StatelessWidget {
  const SignMediaPanel({
    super.key,
    required this.letter,
    required this.media,
    required this.status,
    required this.error,
    required this.onRetry,
    required this.fallback,
  });

  final String letter;
  final SignMediaModel? media;
  final SignMediaStatus status;
  final String? error;
  final VoidCallback onRetry;

  /// Ilustrasi lokal bila video belum/tidak tersedia.
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    final Widget body;
    if (media != null) {
      body = SignVideoPlayer(
        key: ValueKey<String>(media!.mediaUrl),
        url: media!.mediaUrl,
        fallback: fallback,
        onRetry: onRetry,
      );
    } else if (status == SignMediaStatus.loading ||
        status == SignMediaStatus.idle) {
      body = Stack(
        fit: StackFit.expand,
        children: [
          fallback,
          const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        ],
      );
    } else {
      body = _StatusOverlay(
        fallback: fallback,
        message: status == SignMediaStatus.failed
            ? (error ?? 'Video isyarat gagal dimuat.')
            : 'Video untuk huruf $letter belum tersedia di Wikimedia Commons.',
        onRetry: status == SignMediaStatus.failed ? onRetry : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            color: ext.cameraBackdrop,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              body,
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    media != null ? 'Peragaan Video' : 'Referensi Visual 2D',
                    style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.public_rounded, size: 14, color: scheme.outline),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                media != null
                    ? 'Sumber: ${media!.attributionText}. '
                          'Varian BISINDO Malang; dapat berbeda antar daerah.'
                    : 'Sumber video: API Wikimedia Commons (CC BY-SA 4.0).',
                style: AppTextStyles.labelSm.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({
    required this.fallback,
    required this.message,
    this.onRetry,
  });

  final Widget fallback;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        fallback,
        Container(color: Colors.black.withValues(alpha: 0.55)),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(color: Colors.white),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Pemutar video loop senyap; resource dilepas pada `dispose()`.
class SignVideoPlayer extends StatefulWidget {
  const SignVideoPlayer({
    super.key,
    required this.url,
    required this.fallback,
    required this.onRetry,
  });

  final String url;
  final Widget fallback;
  final VoidCallback onRetry;

  @override
  State<SignVideoPlayer> createState() => _SignVideoPlayerState();
}

class _SignVideoPlayerState extends State<SignVideoPlayer> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    setState(() => c.value.isPlaying ? c.pause() : c.play());
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (_failed || (c != null && c.value.hasError)) {
      return _StatusOverlay(
        fallback: widget.fallback,
        message: 'Video tidak dapat diputar di perangkat/browser ini.',
        onRetry: widget.onRetry,
      );
    }
    if (c == null || !c.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          widget.fallback,
          const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        ],
      );
    }
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
          ),
          if (!c.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
        ],
      ),
    );
  }
}
