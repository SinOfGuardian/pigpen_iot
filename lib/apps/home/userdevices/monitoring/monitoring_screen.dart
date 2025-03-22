import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


const _pageTitle = 'Live Monitoring';
const _pageDescription = 'Visible live data covers the current 1 min and is '
    'updated once every 3 seconds.';

/// Monitoring page
class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  Widget _header() {
    return Consumer(
      builder: (context, ref, child) {
        final url = ref.watch(activeDeviceProvider.select((thing) => thing!.graphicUrl));
        return Header.titleWithDeviceGraphic(
          title: _pageTitle,
          description: _pageDescription,
          graphicUrl: url,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _header(),
              const _GraphsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Graph section
class _GraphsSection extends ConsumerStatefulWidget {
  const _GraphsSection();
  @override
  ConsumerState<_GraphsSection> createState() => _GraphsSectionState();
}

class _GraphsSectionState extends ConsumerState<_GraphsSection>
    with AutomaticKeepAliveClientMixin {
  late final Timer timer;
  int tempVal = 0, humidVal = 0, soilMoistVal = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        ref.read(graphDataProvider(tempSensor).notifier).update(tempVal);
        ref.read(graphDataProvider(humidSensor).notifier).update(humidVal);
        ref.read(graphDataProvider(soilSensor).notifier).update(soilMoistVal);
      },
    );

    ref.listenManual(
      fireImmediately: true,
      deviceStreamProvider,
      (oldState, newState) {
        newState.whenData((device) {
          tempVal = device.temperature;
          humidVal = device.humidity;
          soilMoistVal = device.soilMoisture;
        });
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _GraphSectionView(this);
  }
}

class _GraphSectionView extends StlsView<_GraphsSectionState> {
  _GraphSectionView(super.state) : super(key: ObjectKey(state));

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _SingleGraph(provider: graphDataProvider(tempSensor)),
            const SizedBox(height: 20),
            _SingleGraph(provider: graphDataProvider(humidSensor)),
            const SizedBox(height: 20),
            _SingleGraph(provider: graphDataProvider(soilSensor)),
          ],
        ),
      ),
    );
  }
}

/// Must separate graph view since it is immutable
class _SingleGraph extends ConsumerWidget {
  final AutoDisposeStateNotifierProvider<GraphNotifier, GraphData> provider;
  const _SingleGraph({required this.provider});

  final TextStyle labelTextStyle = const TextStyle(color: Colors.grey, fontSize: 10);

  List<FlSpot> convertListToSpots(List<int> list) {
    return list.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList();
  }

  Widget _minMaxIndicator(int highest, int lowest) {
    return Row(
      children: [
        // const Text('H'),
        const SizedBox(width: 18, child: Icon(Icons.arrow_drop_up_rounded, size: 20)),
        Text(highest.toString(), style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 5),
        // const Text('L'),
        const SizedBox(width: 18, child: Icon(Icons.arrow_drop_down_rounded, size: 20)),
        Text(lowest.toString(), style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _graphHeader(BuildContext context, GraphData graphData) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        titledBottomNotesSheet(
          context: context,
          title: graphData.sensor.title.toCapitalizeFirst(),
          message: graphData.sensor.noteMessage,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                graphData.sensor.title.toCapitalizeFirst(),
                style: textTheme.titleMedium,
              ),
              _minMaxIndicator(graphData.highest, graphData.lowest),
            ],
          ),
          Text(
            graphData.data.toString() + graphData.sensor.suffix,
            style: textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  SideTitleWidget _bottomIndicator(double value, TitleMeta meta) {
    String text = '';
    const minX = 0.0;
    const maxX = 20.0;

    if (value == minX || value == maxX) text = (value * 3).toInt().toString();
    return SideTitleWidget(
        axisSide: meta.axisSide, child: Text(text, style: labelTextStyle));
  }

  Text _leftIndicator(double value, TitleMeta meta, GraphData graphData) {
    final minY = graphData.minY;
    final maxY = graphData.maxY;
    final newValue = '${value.toInt()}${graphData.sensor.suffix}';

    String text = '';
    if (value == minY || value == ((maxY - minY) / 2) + minY || value == maxY) {
      text = newValue;
    } else if (value.toInt() == graphData.data.toInt()) {
      return Text('~',
          textAlign: TextAlign.center,
          style: TextStyle(color: graphData.sensor.lineColor, fontSize: 16));
    }
    return Text(text, style: labelTextStyle);
  }

  double getHorizontalInterval(double minY, double maxY) {
    final result = (maxY - minY) / 4;
    return result.toInt().toDouble();
  }

  LineChartData _mainData(BuildContext context, List<FlSpot> spots, GraphData graphData) {
    final colorScheme = Theme.of(context).colorScheme;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: getHorizontalInterval(graphData.minY, graphData.maxY),
        verticalInterval: 3.333333333333333,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: colorScheme.surfaceContainerHighest, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: colorScheme.surfaceContainerHighest, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: 1,
            getTitlesWidget: (value, meta) => _leftIndicator(value, meta, graphData),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 20,
            interval: 1,
            getTitlesWidget: _bottomIndicator,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot group) => colorScheme.surface),
      ),
      minX: 0,
      maxX: 20,
      minY: graphData.minY,
      maxY: graphData.maxY,
      clipData: const FlClipData.vertical(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          color: graphData.sensor.lineColor,
          barWidth: 4,
          isCurved: true,
          curveSmoothness: 0.25,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                graphData.sensor.lineColor.withOpacity(0.2),
                graphData.sensor.lineColor.withOpacity(0.0),
              ],
            ),
          ),
          shadow: Shadow(
              color: graphData.sensor.lineColor.withOpacity(0.5),
              offset: const Offset(0, 2),
              blurRadius: 8),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphData = ref.watch(provider);
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 2 / 1,
        child: Column(
          children: [
            _graphHeader(context, graphData),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                _mainData(
                  context,
                  convertListToSpots(graphData.arrayOfData),
                  graphData,
                ),
                curve: Curves.easeInSine,
                duration: const Duration(milliseconds: 300),
              ),
            ), // cont
          ],
        ),
      ),
    );
  }
}
