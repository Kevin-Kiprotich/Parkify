import "package:duration_picker/duration_picker.dart";
import "package:flutter/material.dart";
import "package:parkify/Components/app_text_field.dart";
import "package:parkify/functions/custom_dialogs.dart";

class ParkingModal extends StatefulWidget {
  const ParkingModal(
      {super.key,
      required this.id,
      required this.name,
      required this.capacity,
      required this.availableSpaces,
      required this.onNavigationCancelled});
  final int id;
  final String name;
  final int capacity;
  final int availableSpaces;
  final void Function() onNavigationCancelled;
  @override
  State<ParkingModal> createState() => _ParkingModalState();
}

class _ParkingModalState extends State<ParkingModal> {
  final Duration _duration = const Duration(hours: 0, minutes: 0);
  final TextEditingController _durationController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
            bottom: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
          child: SafeArea(
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onNavigationCancelled();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    const Text(
                      "Capacity:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.capacity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // DurationPicker(duration: _duration, onChange: (val) {}),
                Row(
                  children: [
                    const Text(
                      "Available Spaces:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: widget.availableSpaces > 0
                              ? Colors.green
                              : Colors.red),
                      child: Center(
                        child: Text(
                          widget.availableSpaces.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.availableSpaces > 0)
                  Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Drive Duration (Minutes)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _durationController,
                          hintText: 'Drive Duration in minutes',
                          keyboardType: const TextInputType.numberWithOptions(),
                          onChanged: (val) {
                            if (double.parse(val) > 120) {
                              _durationController.text = '120';
                              showError(context,
                                  "The maximum drive time is 120 minutes (2 Hours)");
                            }
                          },
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final Duration? result = await showDurationPicker(
                                context: context,
                                initialTime: _duration,
                                baseUnit: BaseUnit.minute,
                                upperBound: const Duration(hours: 1),
                              );
                              if (result != null) {
                                print(result.inMinutes);
                                _durationController.text =
                                    result.inMinutes.toString();
                              }
                            },
                            icon: const Icon(Icons.timer_outlined),
                          ),
                          validator: (value) {
                            if (value!.isEmpty || double.parse(value) <= 0) {
                              return "Please provide a valid time";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onNavigationCancelled();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Back"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.availableSpaces > 0
                            ? () {
                                if (_formkey.currentState!.validate()) {
                                  if (widget.availableSpaces > 0) {
                                    final result = {
                                      'parkinfo':{
                                        'id':widget.id,
                                        'name':widget.name,
                                        'capacity':widget.capacity,
                                        'available_spaces':widget.availableSpaces
                                      },
                                      'duration':
                                          double.parse(_durationController.text)
                                    };
                                    Navigator.pop(context, result);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "No available spaces",
                                          textAlign: TextAlign.center,
                                        ),
                                        action: SnackBarAction(
                                            label: "Ok",
                                            onPressed: () {
                                              // Navigator.of(context).pop();
                                            }),
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Navigate"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
