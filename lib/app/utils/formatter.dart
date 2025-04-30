import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:safety_check/app/data/models/04_fault.dart';
import 'package:safety_check/app/data/services/app_service.dart';

/// 전화번호를 3-4-4 형식으로 변환 (010-1234-5678)
String formatTel(String? phoneNumber) {
  // null이거나 빈 문자열인 경우 빈 문자열 반환
  if (phoneNumber == null || phoneNumber.isEmpty) {
    return '';
  }

  // 숫자만 추출
  String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

  // 길이에 따라 다르게 포맷팅
  if (digits.length == 11) {
    // 11자리 휴대폰 번호 (01012345678 -> 010-1234-5678)
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
  } else if (digits.length == 10) {
    // 10자리 번호 (0212345678 -> 02-1234-5678 또는 010-123-4567)
    if (digits.startsWith('02')) {
      // 서울 지역번호
      return '${digits.substring(0, 2)}-${digits.substring(2, 6)}-${digits.substring(6)}';
    } else {
      // 기타 10자리 번호
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
  } else if (digits.length == 8) {
    // 8자리 번호 (12345678 -> 1234-5678, 내선번호 등)
    return '${digits.substring(0, 4)}-${digits.substring(4)}';
  } else {
    // 그 외 경우는 원본 반환
    return phoneNumber;
  }
}

/// 숫자에 천 단위 콤마 추가 (금액 표시 등)
String formatNumberWithComma(dynamic value) {
  if (value == null) return '';

  // Convert to string and remove any existing commas
  String numberStr = value.toString().replaceAll(',', '');

  String formattedNumber = "";
  if (numberStr.contains('.')) {
    double number = double.parse(numberStr);
    var formatter = NumberFormat('#,###.00');
    formattedNumber = formatter.format(number);
  } else {
    int number = int.parse(numberStr);
    var formatter = NumberFormat('#,###');
    formattedNumber = formatter.format(number);
  }
  return formattedNumber;
}

// 유형 및 형상을 문자열로 변환
String makeCateString(Fault? fault) {
  final appService = Get.find<AppService>();
  String cate1 = appService.faultCate1?[fault?.cate1_seq] ?? "";
  String cate2 = fault?.cate2
          ?.split(', ')
          .map(
            (e) => appService.faultCate2?[e] ?? "",
          )
          .join(", ") ??
      "";
  String result = "$cate1 $cate2";
  if (cate1 == "" || cate2 == "") {
    result = result.trim();
  }
  return result;
}
