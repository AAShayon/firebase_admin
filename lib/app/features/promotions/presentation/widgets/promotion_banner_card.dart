import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionBannerCard extends StatefulWidget {
  final PromotionEntity promotion;
  final VoidCallback onViewAll;

  const PromotionBannerCard({
    super.key,
    required this.promotion,
    required this.onViewAll,
  });

  @override
  State<PromotionBannerCard> createState() => _PromotionBannerCardState();
}

class _PromotionBannerCardState extends State<PromotionBannerCard> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    // Set up a timer to update the countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLeft();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important to cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    final timeLeft = widget.promotion.endDate.difference(now);

    // If the time is up, set it to zero and stop the timer
    if (timeLeft.isNegative) {
      setState(() => _timeLeft = Duration.zero);
      _timer?.cancel();
    } else {
      setState(() => _timeLeft = timeLeft);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: widget.onViewAll,
        child: Stack(
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: widget.promotion.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (c,u,e) => const Icon(Icons.error),
            ),
            // Gradient Overlay
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            // Text and Countdown Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.promotion.title,
                    style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.promotion.description,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCountdownTimer(),
                      ElevatedButton(
                        onPressed: widget.onViewAll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('View Offer'),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade700.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            'Ends in: ${_formatDuration(_timeLeft)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}