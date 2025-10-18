import '../fortune_conditions.dart';

class BlindDateFortuneConditions extends FortuneConditions {
  final String partnerInfo;
  final String meetingPlace;
  final String expectations;

  BlindDateFortuneConditions({
    required this.partnerInfo,
    required this.meetingPlace,
    required this.expectations,
  });

  @override
  String generateHash() => 'partner:${partnerInfo.hashCode}|place:${meetingPlace.hashCode}|exp:${expectations.hashCode}';

  @override
  Map<String, dynamic> toJson() => {'partnerInfo': partnerInfo, 'meetingPlace': meetingPlace, 'expectations': expectations};

  @override
  Map<String, dynamic> toIndexableFields() => {'partner_hash': partnerInfo.hashCode.toString(), 'place_hash': meetingPlace.hashCode.toString(), 'expectations_hash': expectations.hashCode.toString()};

  @override
  Map<String, dynamic> buildAPIPayload() => {'fortune_type': 'blind_date', 'partner_info': partnerInfo, 'meeting_place': meetingPlace, 'expectations': expectations, 'date': _formatDate(DateTime.now())};

  @override
  bool operator ==(Object other) => identical(this, other) || other is BlindDateFortuneConditions && partnerInfo == other.partnerInfo && meetingPlace == other.meetingPlace && expectations == other.expectations;

  @override
  int get hashCode => partnerInfo.hashCode ^ meetingPlace.hashCode ^ expectations.hashCode;

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
