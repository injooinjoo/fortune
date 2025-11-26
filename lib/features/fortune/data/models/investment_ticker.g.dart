// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_ticker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvestmentTickerImpl _$$InvestmentTickerImplFromJson(
        Map<String, dynamic> json) =>
    _$InvestmentTickerImpl(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      exchange: json['exchange'] as String?,
      description: json['description'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
    );

Map<String, dynamic> _$$InvestmentTickerImplToJson(
        _$InvestmentTickerImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'category': instance.category,
      'exchange': instance.exchange,
      'description': instance.description,
      'isPopular': instance.isPopular,
    };
