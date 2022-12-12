import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AlertDialogs {
  showLocationAlertDialogForLocationPermitions(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Otvoriť nastavenia"),
      onPressed: () async {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        await Geolocator.openLocationSettings();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(
          "GPS povolenia sú pernamentne zablokované. Pre lepší výsledok udeľte aplikácii v nastaveniach GPS povolenie a skúste vyhľadávanie znova. Ak aplikácii neumožníte prístup k GPS, budú nastavené defaultne hodnoty."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    Future futureValue = showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
    await futureValue.then((value) => print(value)).then((value) {
      return value;
    });
  }

  showLocationAlertDialogToAnableLocationServices(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Otvoriť nastavenia"),
      onPressed: () async {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        await Geolocator.openLocationSettings();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(
          "The Location Service is not enabled. As the main aim of the application is to find your location plese enable this service in phone settings and back in application refresh the screen with the Refresh button."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    Future futureValue = showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
    await futureValue.then((value) => print(value)).then((value) {
      return value;
    });
  }

  showLocationAlertDialogGPSNotWorking(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // Widget continueButton = TextButton(
    //   child: Text("Otvoriť nastavenia"),
    //   onPressed: () async {
    //     Navigator.popUntil(context, ModalRoute.withName('/'));
    //     await Geolocator.openLocationSettings();
    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(
          "Váš telefón pravdepodobne nemá GPS signál. Použije sa prednastavené lokácia."),
      actions: [
        cancelButton,
        //continueButton,
      ],
    );

    // show the dialog
    Future futureValue = showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
    await futureValue.then((value) => print(value)).then((value) {
      return value;
    });
  }

  showconnectionStatusMessage(BuildContext context, String connectionType) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // Widget continueButton = TextButton(
    //   child: Text("Otvoriť nastavenia"),
    //   onPressed: () async {
    //     Navigator.popUntil(context, ModalRoute.withName('/'));
    //     await Geolocator.openLocationSettings();
    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(
          "$connectionType"),
      actions: [
        cancelButton,
        //continueButton,
      ],
    );

    // show the dialog
    Future futureValue = showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
    await futureValue.then((value) => print(value)).then((value) {
      return value;
    });
  }

}
