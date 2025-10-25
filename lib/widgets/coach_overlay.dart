import 'dart:math';
import 'package:flutter/material.dart';
import '../services/guide_service.dart';
import 'owl_character.dart';
import '../chat_bot/chat_screen.dart';

class CoachOverlay extends StatefulWidget {
  final Stream stream; // Stream<GuideStep?> but avoid import cycles in this widget
  final String characterName;
  final ImageProvider? avatar;
  final VoidCallback? onTap;

  const CoachOverlay({super.key, required this.stream, required this.characterName, this.avatar, this.onTap});

  @override
  State<CoachOverlay> createState() => _CoachOverlayState();
}

class _CoachOverlayState extends State<CoachOverlay> {
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    // Listen for updates and trigger rebuild
    widget.stream.listen((step) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _removeEntry() {
    if (_entry != null) {
      try {
        _entry!.remove();
      } catch (e) {
        print('Error removing overlay entry: $e');
      }
      _entry = null;
    }
  }

  @override
  void dispose() {
    _removeEntry();
    super.dispose();
  }

  OverlayEntry _buildEntry(dynamic step) {
    Rect? targetRect;
    if (step.anchorKey != null && step.anchorKey.currentContext != null) {
      final box = step.anchorKey.currentContext!.findRenderObject() as RenderBox;
      final pos = box.localToGlobal(Offset.zero);
      targetRect = pos & box.size;
    }

    return OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          ignoring: true,
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.transparent)),
              if (targetRect != null)
                Positioned(
                  left: targetRect.left - 8,
                  top: targetRect.top - 8,
                  width: targetRect.width + 16,
                  height: targetRect.height + 16,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orangeAccent, width: 2),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: (step.bubbleAlignment is Alignment)
                    ? step.bubbleAlignment as Alignment
                    : Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: IgnorePointer(
                    ignoring: false,
                    child: _bubble(step.title as String, step.message as String),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bubble(String title, String message) {
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  // Hide current tip and open chat screen
                  GuideService().hide();
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.2),
                    border: Border.all(color: Colors.orange, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: widget.avatar != null
                      ? ClipOval(child: Image(image: widget.avatar!, width: 20, height: 20, fit: BoxFit.cover))
                      : const OwlCharacter(size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.characterName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(title, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(message, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => GuideService().hide(),
                child: const Icon(Icons.close, color: Colors.white70, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('CoachOverlay.build: GuideService.current = \'${GuideService().current}\'');
    return Stack(
      children: [
        // Show tip bubble only when a GuideStep is active
        if (GuideService().current != null)
          Align(
            alignment: (GuideService().current!.bubbleAlignment is Alignment)
                ? GuideService().current!.bubbleAlignment as Alignment
                : Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _bubble(
                GuideService().current!.title,
                GuideService().current!.message,
              ),
            ),
          ),
      ],
    );
  }
}
