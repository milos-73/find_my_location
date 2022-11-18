import 'package:find_me/markers_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EditRecord extends StatefulWidget {
   final int index;
   final MyMarkers marker;

  const EditRecord({Key? key, required this.index, required this.marker}) : super(key: key);

  @override
  State<EditRecord> createState() => _EditRecordState();
}

class _EditRecordState extends State<EditRecord> {

  bool isLoading = false;
  late Box<MyMarkers> myMarkersBox;

  TextEditingController nameController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController altitudeController = TextEditingController();
  TextEditingController accuracyController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController townController = TextEditingController();
  TextEditingController countyController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  @override
  void initState() {
    super.initState();
   setState((){isLoading = true;});
    myMarkersBox = Hive.box('myMarkersBox');

    setState((){nameController.text = widget.marker.name!;});
    setState((){latitudeController.text = '${widget.marker.lat}';});
    setState((){longitudeController.text = '${widget.marker.long}';});
    setState((){accuracyController.text = '${widget.marker.accuracy}';});
    setState((){altitudeController.text = '${widget.marker.altitude}';});
    setState((){streetController.text = widget.marker.street!;});
    setState((){townController.text = widget.marker.city!;});
    setState((){countyController.text = widget.marker.county!;});
    setState((){stateController.text = widget.marker.state!;});
    setState((){zipController.text = widget.marker.zip!;});
    setState((){descriptionController.text = widget.marker.description!;});
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Name',),controller: nameController,),
            TextFormField(decoration: const InputDecoration(labelText: 'Latitude',),controller: latitudeController),
            TextFormField(decoration: const InputDecoration(labelText: 'Longitude',),controller:longitudeController),
            TextFormField(decoration: const InputDecoration(labelText: 'Altitude',),controller:altitudeController),
            TextFormField(decoration: const InputDecoration(labelText: 'Accuracy',),controller:accuracyController),
            TextFormField(decoration: const InputDecoration(labelText: 'Street',),controller: streetController),
            TextFormField(decoration: const InputDecoration(labelText: 'Town',),controller:townController),
            TextFormField(decoration: const InputDecoration(labelText: 'County',),controller:countyController),
            TextFormField(decoration: const InputDecoration(labelText: 'State',),controller:stateController),
            TextFormField(decoration: const InputDecoration(labelText: 'Postal Code',),controller:zipController),
            TextFormField(decoration: const InputDecoration(labelText: 'Notes',),controller:descriptionController,minLines: 1,maxLines: 3,),
            const SizedBox(height: 10,),
            TextButton(onPressed: (){
              final newMarker = MyMarkers(dateTime: DateTime.now(), name: nameController.text, description: descriptionController.text, lat: double.parse(latitudeController.text) , long: double.parse(longitudeController.text), altitude: double.parse(altitudeController.text), accuracy: double.parse(accuracyController.text), street: streetController.text, city: townController.text, county: countyController.text, state: stateController.text,zip: zipController.text);
              myMarkersBox.putAt(widget.index, newMarker);;
              Navigator.pop(context);
            }, child: Container(color: Colors.green, padding: const EdgeInsets.all(14), child: const Text('SAVE'),)),
          ],),
        ),
      ),
    );
  }
}
