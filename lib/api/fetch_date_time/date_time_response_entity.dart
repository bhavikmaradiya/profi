import 'dart:convert';

import '../../generated/json/base/json_field.dart';
import '../../generated/json/date_time_response_entity.g.dart';

@JsonSerializable()
class DateTimeResponseEntity {
  String? abbreviation;
  @JSONField(name: "client_ip")
  String? clientIp;
  String? datetime;
  @JSONField(name: "day_of_week")
  int? dayOfWeek;
  @JSONField(name: "day_of_year")
  int? dayOfYear;
  bool? dst;
  @JSONField(name: "dst_from")
  dynamic dstFrom;
  @JSONField(name: "dst_offset")
  int? dstOffset;
  @JSONField(name: "dst_until")
  dynamic dstUntil;
  @JSONField(name: "raw_offset")
  int? rawOffset;
  String? timezone;
  int? unixtime;
  @JSONField(name: "utc_datetime")
  String? utcDatetime;
  @JSONField(name: "utc_offset")
  String? utcOffset;
  @JSONField(name: "week_number")
  int? weekNumber;

  DateTimeResponseEntity();

  factory DateTimeResponseEntity.fromJson(Map<String, dynamic> json) =>
      $DateTimeResponseEntityFromJson(json);

  Map<String, dynamic> toJson() => $DateTimeResponseEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
