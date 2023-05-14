import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/utils/utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_detail_state.freezed.dart';

@freezed
class ProfileDetailState with _$ProfileDetailState {
  const ProfileDetailState._();

  const factory ProfileDetailState({
    required Profile profile,
    @Default(false) bool isEditing,
    @Default(false) bool showErrorMessages,
    @Default(MutationState.initial()) MutationState save,
  }) = _ProfileDetailState;
}
