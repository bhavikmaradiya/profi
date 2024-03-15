import 'package:profi/generated/json/base/json_convert_content.dart';
import 'package:profi/api/fetch_date_time/date_time_response_entity.dart';

DateTimeResponseEntity $DateTimeResponseEntityFromJson(Map<String, dynamic> json) {
	final DateTimeResponseEntity dateTimeResponseEntity = DateTimeResponseEntity();
	final String? abbreviation = jsonConvert.convert<String>(json['abbreviation']);
	if (abbreviation != null) {
		dateTimeResponseEntity.abbreviation = abbreviation;
	}
	final String? clientIp = jsonConvert.convert<String>(json['client_ip']);
	if (clientIp != null) {
		dateTimeResponseEntity.clientIp = clientIp;
	}
	final String? datetime = jsonConvert.convert<String>(json['datetime']);
	if (datetime != null) {
		dateTimeResponseEntity.datetime = datetime;
	}
	final int? dayOfWeek = jsonConvert.convert<int>(json['day_of_week']);
	if (dayOfWeek != null) {
		dateTimeResponseEntity.dayOfWeek = dayOfWeek;
	}
	final int? dayOfYear = jsonConvert.convert<int>(json['day_of_year']);
	if (dayOfYear != null) {
		dateTimeResponseEntity.dayOfYear = dayOfYear;
	}
	final bool? dst = jsonConvert.convert<bool>(json['dst']);
	if (dst != null) {
		dateTimeResponseEntity.dst = dst;
	}
	final dynamic? dstFrom = jsonConvert.convert<dynamic>(json['dst_from']);
	if (dstFrom != null) {
		dateTimeResponseEntity.dstFrom = dstFrom;
	}
	final int? dstOffset = jsonConvert.convert<int>(json['dst_offset']);
	if (dstOffset != null) {
		dateTimeResponseEntity.dstOffset = dstOffset;
	}
	final dynamic? dstUntil = jsonConvert.convert<dynamic>(json['dst_until']);
	if (dstUntil != null) {
		dateTimeResponseEntity.dstUntil = dstUntil;
	}
	final int? rawOffset = jsonConvert.convert<int>(json['raw_offset']);
	if (rawOffset != null) {
		dateTimeResponseEntity.rawOffset = rawOffset;
	}
	final String? timezone = jsonConvert.convert<String>(json['timezone']);
	if (timezone != null) {
		dateTimeResponseEntity.timezone = timezone;
	}
	final int? unixtime = jsonConvert.convert<int>(json['unixtime']);
	if (unixtime != null) {
		dateTimeResponseEntity.unixtime = unixtime;
	}
	final String? utcDatetime = jsonConvert.convert<String>(json['utc_datetime']);
	if (utcDatetime != null) {
		dateTimeResponseEntity.utcDatetime = utcDatetime;
	}
	final String? utcOffset = jsonConvert.convert<String>(json['utc_offset']);
	if (utcOffset != null) {
		dateTimeResponseEntity.utcOffset = utcOffset;
	}
	final int? weekNumber = jsonConvert.convert<int>(json['week_number']);
	if (weekNumber != null) {
		dateTimeResponseEntity.weekNumber = weekNumber;
	}
	return dateTimeResponseEntity;
}

Map<String, dynamic> $DateTimeResponseEntityToJson(DateTimeResponseEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['abbreviation'] = entity.abbreviation;
	data['client_ip'] = entity.clientIp;
	data['datetime'] = entity.datetime;
	data['day_of_week'] = entity.dayOfWeek;
	data['day_of_year'] = entity.dayOfYear;
	data['dst'] = entity.dst;
	data['dst_from'] = entity.dstFrom;
	data['dst_offset'] = entity.dstOffset;
	data['dst_until'] = entity.dstUntil;
	data['raw_offset'] = entity.rawOffset;
	data['timezone'] = entity.timezone;
	data['unixtime'] = entity.unixtime;
	data['utc_datetime'] = entity.utcDatetime;
	data['utc_offset'] = entity.utcOffset;
	data['week_number'] = entity.weekNumber;
	return data;
}