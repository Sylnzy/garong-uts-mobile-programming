import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '/core/services/onboarding_service.dart';

enum ContentPosition { top, bottom }

class FeatureGuide {
  final BuildContext context;
  final List<GlobalKey> keys;
  final List<String> titles;
  final List<String> descriptions;
  final List<ContentPosition>? contentPositions;

  TutorialCoachMark? _tutorialCoachMark;
  List<TargetFocus> _targets = [];
  bool _isActive = false;

  FeatureGuide({
    required this.context,
    required this.keys,
    required this.titles,
    required this.descriptions,
    this.contentPositions,
  }) {
    _initTargets();
    _initCoachMark();
  }

  void _initTargets() {
    _targets = [];
    for (int i = 0; i < keys.length; i++) {
      final keyName = 'target_$i';

      // Special handling for navbar (specifically the last item with _navbarKey)
      final bool isNavbarKey = i == keys.length - 1;

      // Default to bottom if contentPositions is null or index is out of bounds
      final ContentPosition defaultPosition =
          isNavbarKey ? ContentPosition.top : ContentPosition.bottom;

      // Get content position (with default fallback)
      final ContentPosition position =
          contentPositions != null && i < contentPositions!.length
              ? contentPositions![i]
              : defaultPosition;

      // Ensure navbar tooltip is positioned above with custom positioning
      final contentAlign =
          position == ContentPosition.top
              ? ContentAlign.top
              : ContentAlign.bottom;

      // Adjust positioning for navbar specifically
      final TargetFocus target = TargetFocus(
        identify: keyName,
        keyTarget: keys[i],
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        paddingFocus: 10,
        focusAnimationDuration: const Duration(milliseconds: 500),
        pulseVariation: Tween(begin: 1.0, end: 0.99),
        contents: [
          TargetContent(
            align: contentAlign,
            customPosition:
                isNavbarKey
                    ? CustomTargetContentPosition(
                      top: 100,
                      right: 0,
                      left: 0,
                      bottom: null,
                    )
                    : null,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1C2E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titles[i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descriptions[i],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Scroll first, then go to next step
                          if (i < keys.length - 1) {
                            // Pre-scroll to next target
                            _scrollToTarget(i + 1);
                            // Short delay to allow scrolling to complete
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                controller.next();
                              },
                            );
                          } else {
                            controller.next();
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F1C2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          i == keys.length - 1 ? 'Selesai' : 'Lanjut',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );

      _targets.add(target);
    }
  }

  void _initCoachMark() {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targets,
      colorShadow: const Color(0xFF0F1C2E).withOpacity(0.7),
      textSkip: "Lewati",
      paddingFocus: 10,
      opacityShadow: 0.8,
      hideSkip: false,
      onClickOverlay: (target) {
        // Do nothing when overlay is clicked to prevent accidental skips
        return false;
      },
      onSkip: () {
        _isActive = false;
        OnboardingService.markOnboardingAsComplete();
        return true;
      },
      onFinish: () {
        _isActive = false;
        OnboardingService.markOnboardingAsComplete();
      },
    );
  }

  Future<void> showGuide() async {
    // Prevent showing multiple guides simultaneously
    if (_isActive) return;

    final BuildContext currentContext = context;
    final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();

    if (!hasSeenOnboarding && _tutorialCoachMark != null) {
      _isActive = true;

      // Add a small delay to ensure all widgets are properly rendered
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if context is still valid
      if (currentContext.mounted) {
        _tutorialCoachMark?.show(context: currentContext);
      } else {
        _isActive = false;
      }
    }
  }

  void show() {
    if (_tutorialCoachMark != null && !_isActive) {
      _isActive = true;
      _tutorialCoachMark!.show(context: context);
    }
  }

  void dispose() {
    _tutorialCoachMark = null;
    _isActive = false;
  }

  // Method to scroll to the target element
  void _scrollToTarget(int index) {
    if (index >= keys.length) return;

    // Don't scroll for the navbar (last item)
    if (index == keys.length - 1) return;

    // Use the current key to find the element's position and scroll to it
    final currentContext = keys[index].currentContext;
    if (currentContext == null) return;

    // Find scrollable ancestor
    final ScrollableState? scrollableState = Scrollable.of(currentContext);
    if (scrollableState != null) {
      // Get the render object
      final RenderObject? renderBox = currentContext.findRenderObject();
      if (renderBox != null && renderBox is RenderBox) {
        // Calculate position in the viewport
        final position = scrollableState.position;
        final targetPosition = renderBox.localToGlobal(
          Offset.zero,
          ancestor: position.context.notificationContext?.findRenderObject(),
        );

        if (targetPosition != null) {
          // Scroll to position with some padding
          scrollableState.position.animateTo(
            position.pixels +
                targetPosition.dy -
                100, // Subtract pixels for padding
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }
}
