import 'package:flutter/material.dart';

import '../enums/color_enums.dart';
import '../utils/color_utils.dart';

class LoadingProgress {
  static bool _isDialogShowing = false;

  static showHideProgress(BuildContext context, bool isLoading) {
    if (isLoading && !_isDialogShowing) {
      _isDialogShowing = true;
      showGeneralDialog(
        context: context,
        barrierColor: ColorUtils.getColor(
          context,
          ColorEnums.transparentColor,
        ),
        barrierDismissible: false,
        pageBuilder: (_, __, ___) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: isLoading
                  ? AbsorbPointer(
                      child: CircularProgressIndicator(
                        color: ColorUtils.getColor(
                          context,
                          ColorEnums.black33Color,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          );
        },
      );
    } else {
      if (_isDialogShowing) {
        _isDialogShowing = false;
        Navigator.pop(context);
      }
    }
  }
}
