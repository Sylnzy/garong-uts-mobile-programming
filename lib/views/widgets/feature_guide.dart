import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '/core/services/onboarding_service.dart';

class FeatureGuide {
  final BuildContext context;
  final List<GlobalKey> keys;
  final List<String> titles;
  final List<String> descriptions;

  TutorialCoachMark? _tutorialCoachMark;
  List<TargetFocus> _targets = [];

  FeatureGuide({
    required this.context,
    required this.keys,
    required this.titles,
    required this.descriptions,
  }) {
    _initTargets();
    _initCoachMark();
  }

  void _initTargets() {
    _targets = [];
    for (int i = 0; i < keys.length; i++) {
      _targets.add(
        TargetFocus(
          identify: 'target_$i',
          keyTarget: keys[i],
          alignSkip: Alignment.bottomRight,
          enableOverlayTab: true,
          shape: ShapeLightFocus.RRect,
          radius: 8,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1C2E),
                    borderRadius: BorderRadius.circular(16),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: controller.next,
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
        ),
      );
    }
  }

  void _initCoachMark() {
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targets,
      colorShadow: const Color(0xFF0F1C2E).withOpacity(0.5),
      textSkip: "Lewati",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        OnboardingService.markOnboardingAsComplete();
      },
      onSkip: () {
        OnboardingService.markOnboardingAsComplete();
        return true;
      },
    );
  }

  Future<void> showGuide() async {
    final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();
    if (!hasSeenOnboarding) {
      // Add a small delay to ensure all widgets are properly rendered
      await Future.delayed(const Duration(milliseconds: 500));
      _tutorialCoachMark?.show(context: context);
    }
  }

  void show() {
    _tutorialCoachMark?.show(context: context);
  }
}
