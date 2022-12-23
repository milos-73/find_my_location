import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddressLookUp extends StatefulWidget {
  const AddressLookUp({Key? key}) : super(key: key);

  @override
  State<AddressLookUp> createState() => _AddressLookUpState();
}

class _AddressLookUpState extends State<AddressLookUp> {

  bool showAddress = false;

  @override
  void initState() {

    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //TextButton(onPressed: () {setState(() {loadBeers = !loadBeers;});}, child: Text('Pivo na výčape') ),
        ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 80),
            child: (showAddress) ? Text('ADRESA') :  Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text('Pre klikni na pohár'),
            )),
        Column(
          children: [


            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                IconButton(onPressed: () {setState(() {showAddress = !showAddress;});}, icon: FaIcon(FontAwesomeIcons.houseChimney,), tooltip: 'Klikni pre adrese',),

              ],
            ),
          ],
        ),

      ],
    );
  }
}
