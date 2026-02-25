import 'package:in_app_review/in_app_review.dart';

import '../config.dart';
import 'storage_service.dart';

class ReviewPromptService {
  ReviewPromptService._();
  static final instance = ReviewPromptService._();

  bool _checkedThisLaunch = false;

  Future<void> checkAndPromptIfEligible() async {
    if (_checkedThisLaunch) return;
    _checkedThisLaunch = true;

    if (!AppConfig.reviewPromptEnabled) return;

    final openCount = await StorageService.instance.incrementAndGetAppOpenCount();
    if (openCount < AppConfig.reviewPromptMinAppOpens) return;

    final now = DateTime.now();
    final lastPromptAtMs = await StorageService.instance.getLastReviewPromptAtMs();
    if (lastPromptAtMs != null) {
      final lastPromptAt = DateTime.fromMillisecondsSinceEpoch(lastPromptAtMs);
      if (now.difference(lastPromptAt).inDays < AppConfig.reviewPromptCooldownDays) {
        return;
      }
    }

    final review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
        await StorageService.instance.setLastReviewPromptAtMs(now.millisecondsSinceEpoch);
        return;
      }

      if (AppConfig.iosAppStoreId.isNotEmpty) {
        await review.openStoreListing(appStoreId: AppConfig.iosAppStoreId);
        await StorageService.instance.setLastReviewPromptAtMs(now.millisecondsSinceEpoch);
      }
    } catch (_) {}
  }
}
