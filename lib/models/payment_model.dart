import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/payment_method_enum.dart';
import '../helper/utils/constants.dart';

part 'payment_model.freezed.dart';

part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const PaymentModel._();

  @JsonSerializable()
  const factory PaymentModel({
    @JsonKey(toJson: Constants.toNull, includeIfNull: false) required int? paymentId,
    required double amount,
    required int userId,
    required int showId,
    required DateTime paymentDatetime,
    required PaymentMethod paymentMethod,
    @JsonKey(fromJson: Constants.toNull, includeIfNull: false)
        required List<int>? bookingIds,
  }) = _PaymentModel;

  Map<String, dynamic> toUpdateJson({
    int? userId,
    int? showId,
    double? amount,
    PaymentMethod? paymentMethod,
    DateTime? paymentDatetime,
  }) {
    if (userId == null &&
        showId == null &&
        amount == null &&
        paymentMethod == null &&
        paymentDatetime == null) return const {};
    return copyWith(
      paymentId: paymentId,
      showId: showId ?? this.showId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDatetime: paymentDatetime ?? this.paymentDatetime,
    ).toJson();
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
}