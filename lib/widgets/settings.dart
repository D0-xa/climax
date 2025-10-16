import 'package:flutter/material.dart';

import 'package:hive/hive.dart';

import 'package:climax/services/models.dart' show TempUnits;
import 'package:climax/services/conversions.dart' show darkMode, deviceWidth;

const Map<String, Color> colorfulWords = {
  'l': Colors.red,
  'i': Colors.yellow,
  'm': Colors.blueAccent,
  'a': Colors.green,
  'x': Colors.redAccent,
};
const TextStyle _style = TextStyle(fontSize: 12.0);

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final box = Hive.box('weather');
  late final String unit;
  double _turns = 0.0;
  double? _height = 0.0;
  TempUnits? _currentUnit;
  bool insertNow = false;

  @override
  void initState() {
    super.initState();
    unit = box.get('unit');
    _currentUnit = unit == 'metric' ? TempUnits.metric : TempUnits.imperial;
  }

  @override
  Widget build(BuildContext context) {
    final String tempUnit =
        _currentUnit == TempUnits.metric ? 'Celsius' : 'Fahrenheit';

    return AlertDialog.adaptive(
      alignment: Alignment(0, -0.84),
      insetPadding: EdgeInsets.all(16.0),
      iconPadding: EdgeInsets.only(left: 10.0, top: 2.0),
      contentPadding: EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 16.0),
      clipBehavior: Clip.hardEdge,
      backgroundColor: darkMode ? Color(0xff494d50) : null,
      icon: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: darkMode ? Colors.white70 : Colors.black,
            highlightColor: Colors.blue.withValues(alpha: 0.1),
          ),
          Expanded(
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: 'C',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  children:
                      colorfulWords.entries
                          .map(
                            (e) => TextSpan(
                              text: e.key,
                              style: TextStyle(color: e.value),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ),
          SizedBox(width: 50.0),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              selected: darkMode,
              selectedTileColor: const Color(0xff343637),
              selectedColor: Colors.white70,
              leading: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.jpeg'),
                  ),
                  CircleAvatar(
                    backgroundColor:
                        darkMode ? const Color(0xff343637) : Colors.white,
                    radius: 10.5,
                    child: Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              darkMode
                                  ? Colors.grey.shade700
                                  : const Color(0xffd8d8de),
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 14.0,
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                'Emmanuel Chidiebere',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'emmanuelchidi@climax.com',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  SizedBox(height: 18.0),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: deviceWidth < 450 ? 14.0 : 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      foregroundColor: darkMode ? Colors.white : Colors.black,
                    ),
                    child: Text('Manage your Climax Account'),
                  ),
                ],
              ),
              isThreeLine: true,
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            ListTile(
              selected: darkMode,
              selectedTileColor: const Color(0xff343637),
              selectedColor: Colors.white70,
              leading: SizedBox(
                width: 40.0,
                child: Icon(
                  Icons.thermostat_outlined,
                  color: darkMode ? Colors.white70 : const Color(0xff575757),
                  size: 20.0,
                ),
              ),
              title: Text(
                'Temperature units',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: Text(
                _turns == 0
                    ? tempUnit
                    : 'Changing this setting will update across all of your account settings.',
                style: TextStyle(fontSize: 12.0),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: darkMode ? Colors.white70 : Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: AnimatedRotation(
                  turns: _turns,
                  duration: Durations.medium2,
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 22.0,
                    color: darkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              onTap: () {
                setState(() {
                  _turns = _turns == 0 ? -0.5 : 0;
                  _height = _height == 0 ? null : 0;
                });
                if (unit != box.get('unit')) {
                  Navigator.pop(context, true);
                }
              },
            ),
            const SizedBox(height: 2.0),
            AnimatedSize(
              duration: Durations.medium2,
              alignment: Alignment.topCenter,
              curve: Curves.easeInOut,
              child: Container(
                height: _height,
                decoration: BoxDecoration(
                  color: darkMode ? const Color(0xff343637) : Colors.white,
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: RadioGroup<TempUnits>(
                  groupValue: _currentUnit,
                  onChanged: (value) {
                    box.put(
                      'unit',
                      value == TempUnits.metric ? 'metric' : 'imperial',
                    );
                    setState(() => _currentUnit = value);
                  },
                  child: Column(
                    children: [
                      RadioListTile.adaptive(
                        title: const Text('Celsius'),
                        value: TempUnits.metric,
                      ),
                      RadioListTile.adaptive(
                        title: const Text('Fahrenheit'),
                        value: TempUnits.imperial,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_height == null) const SizedBox(height: 2.0),
            ListTile(
              selected: darkMode,
              selectedTileColor: const Color(0xff343637),
              leading: SizedBox(
                width: 38.0,
                child: Icon(
                  Icons.feedback_outlined,
                  color: darkMode ? Colors.white70 : const Color(0xff575757),
                  size: 20.0,
                ),
              ),
              title: Text(
                'Send feedback',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 18.0,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Privacy Policy', style: _style),
                  Text('•', style: TextStyle(fontSize: 16.0, height: 0.0)),
                  Text('Terms of Service', style: _style),
                ],
              ),
            ),
          ],
        ),
      ),
      scrollable: true,
    );
  }
}
