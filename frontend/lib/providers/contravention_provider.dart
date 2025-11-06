// lib/providers/contravention_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contravention_models.dart';

class ContraventionFormDataNotifier extends StateNotifier<ContraventionFormData> {
  ContraventionFormDataNotifier() : super(ContraventionFormData());

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void addMedia(ContraventionMediaDetail mediaDetail) {
    final newMediaList = [...state.media, mediaDetail];
    state = state.copyWith(media: newMediaList);
  }

  void removeMedia(int mediaId) {
    final newMediaList =
        state.media.where((m) => m.id != mediaId).toList();
    state = state.copyWith(media: newMediaList);
  }
  void updateMedia(ContraventionMediaDetail updateMedia){
    final newMediaList = state.media.map((m) {
      if (m.id == updateMedia.id) {
        return updateMedia;
      }
      return m;
    }).toList();
    state = state.copyWith(media: newMediaList);
  }
}

final contraventionFormDataProvider =
    StateNotifierProvider<ContraventionFormDataNotifier, ContraventionFormData>(
        (ref) {
  return ContraventionFormDataNotifier();
});