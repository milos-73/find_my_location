import 'dart:io';

class AdHelper {

  static String get mainScreen {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2661558273173422/1834421921';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2661558273173422/9242539004';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get markerList {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2661558273173422/7059228793';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2661558273173422/3352450901';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get detailedScreen {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2661558273173422/5994964105';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2661558273173422/3990212329';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }


  static String get detailedScreenEnter {
    if (Platform.isAndroid) {
      return "ca-app-pub-2661558273173422/2984252418";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2661558273173422/9050967314";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get editSave {
    if (Platform.isAndroid) {
      return "ca-app-pub-2661558273173422/1481004027";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2661558273173422/7737885641";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get editCancel {
    if (Platform.isAndroid) {
      return "ca-app-pub-2661558273173422/6867657102";
    } else if (Platform.isIOS) {
      return "ca-app-pub-2661558273173422/5687842349";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }



  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
  static String get markerList2 {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2661558273173422~6523641826';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2661558273173422~6807947354';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }





}
