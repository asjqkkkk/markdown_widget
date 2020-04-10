import 'package:flutter/material.dart';
import '../tags/markdown_tags.dart';
import '../tags/all_tags.dart';
export '../tags/all_tags.dart';

class StyleConfig {
  StyleConfig._internal();

  static StyleConfig _obj;

  factory StyleConfig({
    CheckBoxBuilder checkBoxBuilder,
    ImgBuilder imgBuilder,
    VideoBuilder videoBuilder,
    VideoConfig videoConfig,
    TitleConfig titleConfig,
    PConfig pConfig,
    OlConfig olConfig,
    UlConfig ulConfig,
    PreConfig preConfig,
    BlockQuoteConfig blockQuoteConfig,
    TableConfig tableConfig,
    HrConfig hrConfig,
    CheckBoxConfig checkBoxConfig,
  }) {
    _obj ??= StyleConfig._internal();
    _obj.imgBuilder = imgBuilder ?? _obj.imgBuilder;
    _obj.videoBuilder = videoBuilder ?? _obj.videoBuilder;
    _obj.checkBoxBuilder = checkBoxBuilder ?? _obj.checkBoxBuilder;
    _obj.titleConfig = titleConfig ?? _obj.titleConfig;
    _obj.videoConfig = videoConfig ?? _obj.videoConfig;
    _obj.pConfig =  pConfig ?? _obj.pConfig;
    _obj.olConfig = olConfig ?? _obj.olConfig;
    _obj.ulConfig = ulConfig ?? _obj.ulConfig;
    _obj.preConfig = preConfig ??_obj.preConfig;
    _obj.blockQuoteConfig = blockQuoteConfig ?? _obj.blockQuoteConfig;
    _obj.tableConfig = tableConfig ?? _obj.tableConfig;
    _obj.hrConfig = hrConfig ?? _obj.hrConfig;
    _obj.checkBoxConfig = checkBoxConfig ?? _obj.checkBoxConfig;
    return _obj;
  }

  ///input
  CheckBoxBuilder checkBoxBuilder;
  CheckBoxConfig checkBoxConfig;

  ///img
  ImgBuilder imgBuilder;

  ///video
  VideoBuilder videoBuilder;
  VideoConfig videoConfig;

  ///h1~h5
  TitleConfig titleConfig;

  ///p
  PConfig pConfig;

  ///ol
  OlConfig olConfig;

  ///ul
  UlConfig ulConfig;

  ///pre
  PreConfig preConfig;

  ///blockquote
  BlockQuoteConfig blockQuoteConfig;

  ///table
  TableConfig tableConfig;

  ///hr
  HrConfig hrConfig;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StyleConfig &&
              runtimeType == other.runtimeType &&
              checkBoxBuilder == other.checkBoxBuilder &&
              checkBoxConfig == other.checkBoxConfig &&
              imgBuilder == other.imgBuilder &&
              videoBuilder == other.videoBuilder &&
              videoConfig == other.videoConfig &&
              titleConfig == other.titleConfig &&
              pConfig == other.pConfig &&
              olConfig == other.olConfig &&
              ulConfig == other.ulConfig &&
              preConfig == other.preConfig &&
              blockQuoteConfig == other.blockQuoteConfig &&
              tableConfig == other.tableConfig &&
              hrConfig == other.hrConfig;

  @override
  int get hashCode =>
      checkBoxBuilder.hashCode ^
      checkBoxConfig.hashCode ^
      imgBuilder.hashCode ^
      videoBuilder.hashCode ^
      videoConfig.hashCode ^
      titleConfig.hashCode ^
      pConfig.hashCode ^
      olConfig.hashCode ^
      ulConfig.hashCode ^
      preConfig.hashCode ^
      blockQuoteConfig.hashCode ^
      tableConfig.hashCode ^
      hrConfig.hashCode;




}


TextStyle getTextStyle(String tag){
  final pConfig = StyleConfig().pConfig;
  TextStyle style = TextStyle();
  switch(tag){
    case code:
      style = pConfig?.codeStyle ?? defaultCodeStyle;
      break;
    case del:
      style = pConfig?.delStyle ?? defaultDelStyle;
      break;
    case em:
      style = pConfig?.emStyle ?? defaultEmStyle;
      break;
    case strong:
      style = pConfig?.strongStyle ?? defaultStrongStyle;
      break;
  }
  return style;
}

TextStyle defaultPStyle = TextStyle(color: Color.fromRGBO(30, 34, 38, 1.0),);
TextStyle defaultCodeStyle = TextStyle(color: Colors.grey,fontSize: 12, );
TextStyle defaultDelStyle = TextStyle(decoration: TextDecoration.lineThrough);
TextStyle defaultEmStyle = TextStyle(fontStyle: FontStyle.italic);
TextStyle defaultStrongStyle = TextStyle(fontWeight: FontWeight.bold);
TextStyle defaultBlockStyle = TextStyle(color: Color.fromRGBO(169, 170, 180, 1.0));

Color defaultCodeBackground = Color.fromRGBO(245, 245, 245, 1.0);
Color defaultTableBorderColor = Color.fromRGBO(215, 219, 223, 1.0);
Color defaultDividerColor = Color.fromRGBO(229, 230, 235, 1.0);
Color defaultBlockColor = Color.fromRGBO(215, 219, 223, 1.0);
Color defaultPreBackground = Color.fromRGBO(243, 246, 249, 1);

