import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../core/model/product_media_model.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_media.dart';
import '../../../core/widget/store_states.dart';
import 'product_media_presentation.dart';

class VideoView extends StatefulWidget {
  const VideoView({
    required this.media,
    this.showFullscreen = true,
    this.onOpenViewer,
    super.key,
  });

  final ProductMedia media;
  final bool showFullscreen;
  final VoidCallback? onOpenViewer;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController? _controller;
  Object? _terminalError;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.id != widget.media.id ||
        oldWidget.media.path != widget.media.path) {
      _replaceController();
    }
  }

  Future<void> _replaceController() async {
    final previous = _controller;
    _controller = null;
    _terminalError = null;
    _muted = false;
    if (mounted) setState(() {});
    await previous?.dispose();
    await _initialize();
  }

  Future<void> _initialize() async {
    if (!widget.media.isVideo) {
      if (mounted) {
        setState(() => _terminalError = StateError('Unsupported video media'));
      }
      return;
    }
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(productMediaUrl(widget.media.path)),
    );
    _controller = controller;
    try {
      await controller.initialize().timeout(const Duration(seconds: 15));
      if (mounted && identical(_controller, controller)) setState(() {});
    } catch (error) {
      if (identical(_controller, controller)) _controller = null;
      await controller.dispose();
      if (mounted) setState(() => _terminalError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_terminalError != null) {
      return StoreMediaPlaceholder(
        icon: Icons.videocam_off_outlined,
        message: 'storeVideoUnavailable'.tr,
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      final poster = widget.media.posterPath;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (poster != null)
            StoreNetworkMedia(
              url: productMediaUrl(poster),
              semanticLabel: 'storeVideoPoster'.tr,
              fit: BoxFit.cover,
            )
          else
            const ColoredBox(color: Color(0xFF0D0E12)),
          const SizedBox.expand(child: StoreSkeletonBox(borderRadius: 0)),
        ],
      );
    }

    return ColoredBox(
      color: const Color(0xFF0D0E12),
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder:
            (context, value, _) => Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
                if (!value.isPlaying)
                  Center(
                    child: IconButton.filled(
                      key: const Key('video-play-pause-center'),
                      tooltip: 'storePlay'.tr,
                      onPressed: () => _togglePlayback(controller),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0x990D0E12),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(58, 58),
                      ),
                      icon: const Icon(
                        Icons.play_arrow,
                        size: StoreIconSizes.large,
                      ),
                    ),
                  ),
                PositionedDirectional(
                  start: StoreSpacing.sm,
                  end: StoreSpacing.sm,
                  bottom: StoreSpacing.sm,
                  child: _VideoControls(
                    controller: controller,
                    value: value,
                    muted: _muted,
                    showFullscreen: widget.showFullscreen,
                    onPlayPause: () => _togglePlayback(controller),
                    onMute: () => _toggleMute(controller),
                    onFullscreen:
                        widget.showFullscreen ? _openFullscreen : null,
                  ),
                ),
                if (value.hasError)
                  StoreMediaPlaceholder(
                    icon: Icons.videocam_off_outlined,
                    message: 'storeVideoUnavailable'.tr,
                  ),
              ],
            ),
      ),
    );
  }

  Future<void> _togglePlayback(VideoPlayerController controller) async {
    controller.value.isPlaying
        ? await controller.pause()
        : await controller.play();
  }

  Future<void> _toggleMute(VideoPlayerController controller) async {
    _muted = !_muted;
    await controller.setVolume(_muted ? 0 : 1);
    if (mounted) setState(() {});
  }

  void _openFullscreen() {
    if (widget.onOpenViewer case final callback?) {
      callback();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => Scaffold(
              backgroundColor: const Color(0xFF0D0E12),
              appBar: AppBar(
                backgroundColor: const Color(0xFF0D0E12),
                foregroundColor: Colors.white,
              ),
              body: SafeArea(
                child: VideoView(media: widget.media, showFullscreen: false),
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.controller,
    required this.value,
    required this.muted,
    required this.showFullscreen,
    required this.onPlayPause,
    required this.onMute,
    required this.onFullscreen,
  });

  final VideoPlayerController controller;
  final VideoPlayerValue value;
  final bool muted;
  final bool showFullscreen;
  final VoidCallback onPlayPause;
  final VoidCallback onMute;
  final VoidCallback? onFullscreen;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.fromSTEB(
      StoreSpacing.xs,
      StoreSpacing.xxs,
      StoreSpacing.xxs,
      StoreSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: const Color(0xB30D0E12),
      borderRadius: BorderRadius.circular(StoreRadii.md),
    ),
    child: Row(
      children: [
        IconButton(
          key: const Key('video-play-pause'),
          tooltip: value.isPlaying ? 'storePause'.tr : 'storePlay'.tr,
          visualDensity: VisualDensity.compact,
          color: Colors.white,
          onPressed: onPlayPause,
          icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        Text(
          _formatDuration(value.position),
          key: const Key('video-current-time'),
          textDirection: TextDirection.ltr,
          style: StoreTypography.caption.copyWith(color: Colors.white),
        ),
        const SizedBox(width: StoreSpacing.xs),
        Expanded(
          child: VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: StoreSpacing.sm),
            colors: const VideoProgressColors(
              playedColor: StorePalette.purple,
              bufferedColor: Colors.white38,
              backgroundColor: Colors.white24,
            ),
          ),
        ),
        const SizedBox(width: StoreSpacing.xs),
        Text(
          _formatDuration(value.duration),
          key: const Key('video-duration'),
          textDirection: TextDirection.ltr,
          style: StoreTypography.caption.copyWith(color: Colors.white),
        ),
        IconButton(
          tooltip: muted ? 'storeUnmute'.tr : 'storeMute'.tr,
          visualDensity: VisualDensity.compact,
          color: Colors.white,
          onPressed: onMute,
          icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
        ),
        if (showFullscreen)
          IconButton(
            key: const Key('video-fullscreen'),
            tooltip: 'storeFullscreen'.tr,
            visualDensity: VisualDensity.compact,
            color: Colors.white,
            onPressed: onFullscreen,
            icon: const Icon(Icons.fullscreen),
          ),
      ],
    ),
  );
}

String _formatDuration(Duration value) {
  final totalSeconds = value.inSeconds.clamp(0, 359999);
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final tail =
      '${minutes.toString().padLeft(hours > 0 ? 2 : 1, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
  return hours > 0 ? '$hours:$tail' : tail;
}
