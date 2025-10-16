import 'package:flutter/material.dart';

import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'settings.dart';
import 'package:climax/services/location.dart' show serviceActive;
import 'package:climax/services/weather.dart' hide WeatherService;
import 'package:climax/services/models.dart' show CurrentForecast, City;
import 'package:climax/services/conversions.dart'
    show darkMode, deviceWidth, fontScale, roundNum;

bool _managing = false;
String _text = 'Manage';
bool _updating = false;
final ButtonStyle _textButtonStyle = TextButton.styleFrom(
  foregroundColor: const Color(0xff28577d),
  overlayColor: Colors.lightBlue,
);
final ButtonStyle _buttonStyleDark = TextButton.styleFrom(
  foregroundColor: const Color(0xffacd3ff),
  overlayColor: Colors.lightBlueAccent,
);

class Forecast extends StatelessWidget {
  const Forecast({
    required this.location,
    required this.forecast,
    required this.handleSelection,
    required this.currentCity,
    required this.usePrecise,
    required this.controller,
    super.key,
  });

  final CurrentForecast forecast;
  final String location;
  final City? currentCity;
  final void Function({City? selectedCity}) handleSelection;
  final Future<bool> Function() usePrecise;
  final SearchController controller;

  void refreshSuggestions(SearchController controller) {
    controller.text += '@';
    controller.text = controller.text.replaceAll('@', '');
  }

  Iterable<Widget> getHistoryList(
    SearchController controller,
    BuildContext ctx,
  ) => <Widget>[
    Column(
      children: [
        serviceActive
            ? ListTile(
              leading: Icon(
                Icons.location_on_outlined,
                size: 18.0,
                color: darkMode ? const Color(0xffcde5ff) : null,
              ),
              title: Text('Current location'),
              textColor: darkMode ? const Color(0xffcde5ff) : null,
              horizontalTitleGap: 4,
            )
            : Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0, top: 18.0, bottom: 4.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  _updating = true;
                  refreshSuggestions(controller);
                  final isOnline = await usePrecise();
                  if (isOnline && serviceActive) {
                    final locWeather = await getcurrentloc();
                    if (locWeather != null) myLocWeather = locWeather;
                  }
                  _updating = false;
                  refreshSuggestions(controller);
                  nullify = true;
                },
                label: Text('Use precise location'),
                icon:
                    _updating
                        ? CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            darkMode ? const Color(0xff001d33) : Colors.white,
                          ),
                          strokeWidth: 2.0,
                          constraints: BoxConstraints.tightFor(
                            width: 20,
                            height: 20,
                          ),
                        )
                        : Icon(Icons.location_searching),
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      darkMode ? const Color(0xff001d33) : Colors.white,
                  backgroundColor:
                      darkMode
                          ? const Color(0xffacd3ff)
                          : const Color(0xff2b5f8a),
                ),
              ),
            ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: darkMode ? const Color(0xff214868) : Colors.white,
            backgroundImage: AssetImage(myLocWeather.icon),
          ),
          title: Text(myLocWeather.name),
          subtitle: Text('${myLocWeather.temp} • ${myLocWeather.description}'),
          trailing:
              isSaved(myLocWeather.city)
                  ? null
                  : TextButton(
                    onPressed: () async {
                      await saveLocation(myLocWeather.city);
                      if (ctx.mounted) showSnackbar(ctx, 'Location saved');
                      refreshSuggestions(controller);
                    },
                    style: darkMode ? _buttonStyleDark : _textButtonStyle,
                    child: Text('Save'),
                  ),
          contentPadding: EdgeInsets.only(left: 16.0, right: 10.0),
          onTap: () {
            controller.closeView(location);
            handleSelection(selectedCity: myLocWeather.city);
          },
        ),
        const SizedBox(height: 16.0),
      ],
    ),
    Column(
      children: [
        if (savedWeather.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved locations',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: darkMode ? const Color(0xffcde5ff) : null,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _managing = !_managing;
                    _text = _managing ? 'Done' : 'Manage';
                    refreshSuggestions(controller);
                  },
                  style: darkMode ? _buttonStyleDark : _textButtonStyle,
                  child: Text(_text),
                ),
              ],
            ),
          ),
        ListView.builder(
          itemCount: savedWeather.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder:
              (context, i) => ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      darkMode ? const Color(0xff214868) : Colors.white,
                  backgroundImage: AssetImage(savedWeather[i]!.icon),
                ),
                title: Text(savedWeather[i]!.name),
                subtitle: Text(
                  '${savedWeather[i]!.temp} • ${savedWeather[i]!.description}',
                ),
                contentPadding: EdgeInsets.only(left: 16.0, right: 10.0),
                trailing:
                    _managing
                        ? IconButton(
                          onPressed: () {
                            deleteLocation(i);
                            showSnackbar(ctx);
                            refreshSuggestions(controller);
                          },
                          icon: Icon(Icons.cancel_outlined),
                        )
                        : null,
                onTap: () {
                  controller.closeView(location);
                  handleSelection(selectedCity: savedWeather[i]!.city);
                },
              ),
        ),
        const SizedBox(height: 36.0),
        Text(myLocWeather.city.name),
        Text(
          serviceActive ? 'From your device' : 'Based on your past activity',
          style: TextStyle(
            color: darkMode ? const Color(0xffacd3ff) : const Color(0xff28577d),
          ),
        ),
        const SizedBox(height: 48.0),
      ],
    ),
  ];

  Future<Iterable<Widget>> getSuggestions(
    SearchController controller,
    BuildContext ctx,
  ) async {
    final String input = controller.value.text.trim();
    final filteredCities = await getCities(input);

    return controller.text.isEmpty && ctx.mounted
        ? getHistoryList(controller, ctx)
        : filteredCities.isEmpty
        ? [
          Container(
            padding: EdgeInsets.only(top: 12.0),
            alignment: Alignment.center,
            child: Text(
              await InternetConnection().hasInternetAccess
                  ? 'No results found for "$input"'
                  : "You're offline! Please check your internet connection",
            ),
          ),
        ]
        : filteredCities.map(
          (City filteredCity) => ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  darkMode ? const Color(0xff295980) : const Color(0xffc7e4fc),
              child: Icon(Icons.location_on_outlined),
            ),
            title: Text(filteredCity.name),
            trailing:
                isSaved(filteredCity)
                    ? null
                    : TextButton(
                      onPressed: () async {
                        await saveLocation(filteredCity);
                        if (ctx.mounted) showSnackbar(ctx, 'Location saved');
                        refreshSuggestions(controller);
                      },
                      style: darkMode ? _buttonStyleDark : _textButtonStyle,
                      child: Text('Save'),
                    ),
            contentPadding: EdgeInsets.only(left: 16.0, top: 20.0),
            onTap: () async {
              await Future.delayed(
                Durations.medium2,
                () => controller.closeView(filteredCity.name),
              );
              handleSelection(selectedCity: filteredCity);
              nullify = true;
            },
          ),
        );
  }

  void showSnackbar(BuildContext ctx, [String? text]) {
    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(text ?? 'Location removed'),
        margin: EdgeInsets.all(20),
        action:
            text == null
                ? SnackBarAction(label: 'Undo', onPressed: () => undoDelete())
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int i = darkMode ? 1 : 0;
    final Color color =
        darkMode ? const Color(0xffcde5ff) : const Color(0xff001d33);
    final TextStyle style = TextStyle(
      color: darkMode ? const Color(0xffd4d4d4) : Colors.blueGrey.shade700,
    );
    final num aspectFactor = roundNum(
      fontScale < 1
          ? fontScale + 0.1
          : fontScale < 1.15
          ? fontScale + (1 - fontScale.clamp(1, 1.12))
          : fontScale < 1.5
          ? fontScale - 0.2
          : fontScale - 0.4,
      precision: 2,
    )!.clamp(0.9, 1.2);

    return Stack(
      children: [
        SoftEdgeBlur(
          edges: [
            EdgeBlur(
              type: EdgeType.bottomEdge,
              size: 20.0,
              sigma: 8.0,
              tintColor: forecast.color[i],
              controlPoints: [
                ControlPoint(position: 0.1, type: ControlPointType.visible),
                ControlPoint(position: 1.0, type: ControlPointType.transparent),
              ],
            ),
          ],
          child: AspectRatio(
            aspectRatio:
                deviceWidth < 420
                    ? 1.1 / aspectFactor
                    : deviceWidth < 480
                    ? 1.2 / aspectFactor
                    : 1.4 / aspectFactor,
            child: Image.asset(
              forecast.image![i],
              // color: Color(0xffe0edff),
              // colorBlendMode: darkMode ? BlendMode.darken : BlendMode.softLight,
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 8.0),
            child: Column(
              spacing: 24,
              children: [
                ExcludeFocus(
                  child: SearchAnchor.bar(
                    suggestionsBuilder: (context, controller) async {
                      if (controller.text.isEmpty) {
                        return getHistoryList(controller, context);
                      }
                      return getSuggestions(controller, context);
                    },
                    searchController: controller,
                    onOpen: () => controller.clear(),
                    onClose: () {
                      controller.text = location;
                      _managing = false;
                      _text = 'Manage';
                    },
                    barLeading: Icon(
                      Icons.location_on_outlined,
                      color:
                          darkMode
                              ? const Color(0xffd4d4d4)
                              : Colors.grey.shade800,
                    ),
                    barElevation: WidgetStateProperty.all(0.5),
                    isFullScreen: false,
                    shrinkWrap: true,
                    barTrailing: [
                      GestureDetector(
                        onTap: () async {
                          final newSettings = await showAdaptiveDialog<bool>(
                            context: context,
                            builder: (context) => SettingsDialog(),
                          );
                          if (newSettings ?? false) {
                            handleSelection(selectedCity: currentCity);
                          }
                        },
                        child: CircleAvatar(
                          backgroundImage: AssetImage(
                            'assets/images/avatar.jpeg',
                          ),
                          radius: 16.0,
                        ),
                      ),
                    ],
                    barBackgroundColor: WidgetStateProperty.all(
                      darkMode
                          ? Color.lerp(
                            forecast.color[1],
                            const Color(0xff002134),
                            .30,
                          )
                          : const Color(0xffe5f0ff),
                    ),
                    barTextStyle: WidgetStateProperty.all(
                      TextStyle(
                        fontSize: 22,
                        color: darkMode ? const Color(0xffd4d4d4) : null,
                      ),
                    ),
                    viewBackgroundColor: Color.lerp(
                      forecast.color[i],
                      darkMode ? Colors.black : Colors.white,
                      .4,
                    ),
                    viewHintText: 'Search for a location',
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Now',
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(height: 0.0, color: color),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              forecast.temp!,
                              style: TextStyle(
                                color: color,
                                fontSize: 72.0,
                                height: 0.0,
                              ),
                            ),
                            Image.asset(
                              forecast.icon,
                              scale: fontScale > 1 ? 1.3 : 1.4,
                            ),
                          ],
                        ),
                        Text(
                          'High: ${forecast.max} • Low: ${forecast.min}',
                          style: style.copyWith(height: 0.0),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            forecast.description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(color: color),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            'Feels like ${forecast.feelsLike}',
                            style: style,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
