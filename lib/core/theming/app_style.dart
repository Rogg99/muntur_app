import 'package:flutter/material.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/core/utils/size_utils.dart';
import 'package:munturai/core/fonctions.dart';

class AppStyle {

  static TextStyle txtError = TextStyle(
    fontSize: getFontSize(
      13,
    ),
    color: Colors.red,
    fontFamily: 'Arimo Hebrew Subset',
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static TextStyle txtWarning = TextStyle(
    color: UIColors.warningColor,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Arimo Hebrew Subset',
    fontWeight: FontWeight.w600,
  );

  static double getDeviceDpi() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    //log('Screen DPR : ' + data.devicePixelRatio.toString());
    return data.devicePixelRatio;
  }

  static TextStyle txtAclonica({double size=14,String weight='Regular',Color color = Colors.black}){
    return TextStyle(
      color: color,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Aclonica',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
    );
  }


  static TextStyle txtInter({double size=14,String weight='Regular',Color color = Colors.black}){
    return TextStyle(
      color: color,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Inter',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
    );
  }

  static TextStyle txtPoppins({double size=14,String weight='Regular',Color color = Colors.black}){
    return TextStyle(
      color: color,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Poppins',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
    );
  }

  static TextStyle txtStream({double size=14,String weight='Regular',Color color = Colors.black}){
    return TextStyle(
      color: color,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Stream',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
    );
  }

  static TextStyle txtArimoHebrewSubset({double size=14,String weight='Regular',Color color = Colors.black}){
    return TextStyle(
      color: color,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Arimo Hebrew Subset',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
    );
  }

  static TextStyle txtRoboto({double size=14,String weight='Regular',Color color = Colors.black}){
    return TextStyle(
      color: color,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Roboto',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
    );
  }

  static TextStyle txtEncodeSansSm({double size=14,String weight='Regular',Color color = Colors.black}){
    return TextStyle(
      color: color,
      fontSize: getFontSize(
        size,
      ),
      fontFamily: 'Encode Sans',
      fontWeight: weight=='Regular'?FontWeight.w400 : FontWeight.w700,
    );
  }

}

