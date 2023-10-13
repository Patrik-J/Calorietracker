import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:path_parsing/path_parsing.dart';


class WaterTank extends StatefulWidget {
  final Color waterColor;

  final Color bottleColor;

  final Color capColor;

  const WaterTank({
    Key? key,
    required this.waterColor,
    required this.bottleColor,
    required this.capColor
}) : super(key: key);

  @override
  WaterTankState createState() => WaterTankState();
}

class WaterTankState extends State<WaterTank>
    with TickerProviderStateMixin, WaterContainer {
  //get waterLevel => 0.0;

  @override
  void initState() {
    super.initState();
    initWater(widget.waterColor, this);
    waves.first.animation.addListener(() {
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    disposeWater();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1,
          child: CustomPaint(
            painter: WaterBottlePainter(
              waves: waves,
              bubbles: bubbles,
              waterLevel: waterLevel,
              bottleColor: widget.bottleColor,
              capColor: widget.capColor,
            ),
          ),
        ),
      ],
    );
  }
}

class WaterBottlePainter extends CustomPainter {
  /// Holds all wave object instances
  final List<WaveLayer> waves;

  /// Holds all bubble object instances
  final List<Bubble> bubbles;

  /// Water level, 0 = no water, 1 = full water
  final waterLevel;

  /// Bottle color
  final bottleColor;

  /// Bottle cap color
  final capColor;

  WaterBottlePainter({Listenable? repaint,
    required this.waves,
    required this.bubbles,
    required this.bottleColor,
    required this.capColor,
    required this.waterLevel,
  })
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    {
      final paint = Paint();
      paint.color = bottleColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      paintEmptyBottle(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;
      final rect = Rect.fromLTRB(0, 0, size.width, size.height);
      canvas.saveLayer(rect, paint);
      paintBottleMask(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcIn;
      paint.style = PaintingStyle.fill;
      paintWaves(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcATop;
      paint.style = PaintingStyle.fill;
      paintBubbles(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcATop;
      paint.style = PaintingStyle.fill;
      paintGlossyOverlay(canvas, size, paint);
    }
    canvas.restore();
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcATop;
      paint.style = PaintingStyle.fill;
      paint.color = capColor;
      paintCap(canvas, size, paint);
    }
  }

  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final neckTop = size.width * 0.1;
    final neckBottom = size.height;
    final neckRingOuter = 0.0;
    final neckRingOuterR = size.width - neckRingOuter;
    final neckRingInner = size.width * 0.1;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(neckRingOuter, neckTop);
    path.lineTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);
    path.lineTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.lineTo(neckRingOuterR, neckTop);
    canvas.drawPath(path, paint);
  }

  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final neckRingInner = size.width * 0.1;
    final neckRingInnerR = size.width - neckRingInner;
    canvas.drawRect(
        Rect.fromLTRB(
            neckRingInner + 5, 0, neckRingInnerR - 5, size.height - 5),
        paint);
  }

  void paintWaves(Canvas canvas, Size size, Paint paint) {
    for (var wave in waves) {
      paint.color = wave.color;
      final transform = Matrix4.identity();
      final desiredW = 15 * size.width;
      final desiredH = 0.1 * size.height;
      final translateRange = desiredW - size.width;
      final scaleX = desiredW / wave.svgData.getBounds().width;
      final scaleY = desiredH / wave.svgData.getBounds().height;
      final translateX = -wave.offset * translateRange;
      final waterRange = size.height +
          desiredH; // 0 = no water = size.height; 1 = full water = -size.width
      final translateY = (1.0 - waterLevel) * waterRange - desiredH;
      transform.translate(translateX, translateY);
      transform.scale(scaleX, scaleY);
      canvas.drawPath(wave.svgData.transform(transform.storage), paint);
      if (waves.indexOf(wave) != waves.length - 1) {
        continue;
      }
      final gap = size.height - desiredH - translateY;
      if (gap > 0) {
        canvas.drawRect(
            Rect.fromLTRB(0, desiredH + translateY, size.width, size.height),
            paint);
      }
    }
  }

  void paintBubbles(Canvas canvas, Size size, Paint paint) {
    for (var bubble in bubbles) {
      paint.color = bubble.color;
      final offset = Offset(
          bubble.x * size.width, (bubble.y + 1.0 - waterLevel) * size.height);
      final radius = bubble.size * math.min(size.width, size.height);
      canvas.drawCircle(offset, radius, paint);
    }
  }

  void paintGlossyOverlay(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withAlpha(20);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width * 0.5, size.height), paint);
    paint.color = Colors.white.withAlpha(80);
    canvas.drawRect(
        Rect.fromLTRB(size.width * 0.9, 0, size.width * 0.95, size.height),
        paint);
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
      colors: [
        Colors.white.withAlpha(180),
        Colors.white.withAlpha(0),
      ],
    ).createShader(rect);
    paint.color = Colors.white;
    paint.shader = gradient;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  void paintCap(Canvas canvas, Size size, Paint paint) {
    final capTop = 0.0;
    final capBottom = size.width * 0.2;
    final capMid = (capBottom - capTop) / 2;
    final capL = size.width * 0.08 + 5;
    final capR = size.width - capL;
    final neckRingInner = size.width * 0.1 + 5;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(capL, capTop);
    path.lineTo(neckRingInner, capMid);
    path.lineTo(neckRingInner, capBottom);
    path.lineTo(neckRingInnerR, capBottom);
    path.lineTo(neckRingInnerR, capMid);
    path.lineTo(capR, capTop);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaterBottlePainter oldDelegate) => true;
}


mixin class WaterContainer {
  List<WaveLayer> waves = List<WaveLayer>.empty(growable: true);

  List<Bubble> bubbles = List<Bubble>.empty(growable: true);

  static const WAVE_COUNT = 2;

  static const BUBBLE_COUNT = 2;

  double waterLevel = 0.0;

  void initWater(Color themeColor, TickerProvider ticker) {
    var f = math.Random().nextInt(5000) + 15000;
    var d = math.Random().nextInt(500) + 1500;
    var color = HSLColor.fromColor(themeColor);
    for (var i = 1; i <= WAVE_COUNT; i++) {
      final wave = WaveLayer();
      wave.init(ticker, frequency: f);
      final sat = color.saturation * math.pow(0.6, (WAVE_COUNT - i));
      final light = color.lightness * math.pow(0.8, (WAVE_COUNT - i));
      wave.color = color.withSaturation(sat).withLightness(light).toColor();
      waves.add(wave);
      f -= d;
      f = math.max(f, 0);
    }

    for (var i = 0; i < BUBBLE_COUNT; i++) {
      final bubble = Bubble();
      bubble.init(ticker);
      bubble.randomize();
      bubbles.add(bubble);
    }
  }

  void disposeWater() {
    waves.forEach((e) => e.dispose());
    bubbles.forEach((e) => e.dispose());
  }

}


class PathWriter extends PathProxy {
  PathWriter({Path? path}) : this.path = path ?? Path();

  final Path path;

  @override
  void close() {
    path.close();
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    path.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    path.moveTo(x, y);
  }
}

class WaveLayer {
  late final Animation<double> animation;
  late final AnimationController controller;

  final svgData = Path();

  Color color = Colors.blueGrey;

  double get offset => animation.value;

  void init(TickerProvider provider, {int frequency = 100}) {
    controller = AnimationController(
      vsync: provider,
      duration: Duration(milliseconds: frequency),
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutSine
      )
    );
    animation.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        controller.repeat(reverse: true);
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.value = math.Random().nextDouble();
    controller.forward();
    buildPath();
  }

  void dispose() {
    controller.dispose();
  }

  void buildPath() {
    // for beautiful waves, see https://getwaves.io/
    const PATHS = [
      // jaggy
      "M0,96L6.2,112C12.3,128,25,160,37,197.3C49.2,235,62,277,74,256C86.2,235,98,149,111,106.7C123.1,64,135,64,148,80C160,96,172,128,185,138.7C196.9,149,209,139,222,133.3C233.8,128,246,128,258,149.3C270.8,171,283,213,295,202.7C307.7,192,320,128,332,117.3C344.6,107,357,149,369,160C381.5,171,394,149,406,149.3C418.5,149,431,171,443,165.3C455.4,160,468,128,480,133.3C492.3,139,505,181,517,213.3C529.2,245,542,267,554,256C566.2,245,578,203,591,197.3C603.1,192,615,224,628,208C640,192,652,128,665,133.3C676.9,139,689,213,702,240C713.8,267,726,245,738,229.3C750.8,213,763,203,775,213.3C787.7,224,800,256,812,229.3C824.6,203,837,117,849,112C861.5,107,874,181,886,208C898.5,235,911,213,923,186.7C935.4,160,948,128,960,117.3C972.3,107,985,117,997,149.3C1009.2,181,1022,235,1034,261.3C1046.2,288,1058,288,1071,261.3C1083.1,235,1095,181,1108,133.3C1120,85,1132,43,1145,53.3C1156.9,64,1169,128,1182,170.7C1193.8,213,1206,235,1218,245.3C1230.8,256,1243,256,1255,229.3C1267.7,203,1280,149,1292,144C1304.6,139,1317,181,1329,197.3C1341.5,213,1354,203,1366,176C1378.5,149,1391,107,1403,90.7C1415.4,75,1428,85,1434,90.7L1440,96L1440,320L1433.8,320C1427.7,320,1415,320,1403,320C1390.8,320,1378,320,1366,320C1353.8,320,1342,320,1329,320C1316.9,320,1305,320,1292,320C1280,320,1268,320,1255,320C1243.1,320,1231,320,1218,320C1206.2,320,1194,320,1182,320C1169.2,320,1157,320,1145,320C1132.3,320,1120,320,1108,320C1095.4,320,1083,320,1071,320C1058.5,320,1046,320,1034,320C1021.5,320,1009,320,997,320C984.6,320,972,320,960,320C947.7,320,935,320,923,320C910.8,320,898,320,886,320C873.8,320,862,320,849,320C836.9,320,825,320,812,320C800,320,788,320,775,320C763.1,320,751,320,738,320C726.2,320,714,320,702,320C689.2,320,677,320,665,320C652.3,320,640,320,628,320C615.4,320,603,320,591,320C578.5,320,566,320,554,320C541.5,320,529,320,517,320C504.6,320,492,320,480,320C467.7,320,455,320,443,320C430.8,320,418,320,406,320C393.8,320,382,320,369,320C356.9,320,345,320,332,320C320,320,308,320,295,320C283.1,320,271,320,258,320C246.2,320,234,320,222,320C209.2,320,197,320,185,320C172.3,320,160,320,148,320C135.4,320,123,320,111,320C98.5,320,86,320,74,320C61.5,320,49,320,37,320C24.6,320,12,320,6,320L0,320Z",
      "M0,64L6.2,90.7C12.3,117,25,171,37,202.7C49.2,235,62,245,74,240C86.2,235,98,213,111,224C123.1,235,135,277,148,282.7C160,288,172,256,185,245.3C196.9,235,209,245,222,245.3C233.8,245,246,235,258,213.3C270.8,192,283,160,295,138.7C307.7,117,320,107,332,101.3C344.6,96,357,96,369,101.3C381.5,107,394,117,406,149.3C418.5,181,431,235,443,256C455.4,277,468,267,480,224C492.3,181,505,107,517,85.3C529.2,64,542,96,554,133.3C566.2,171,578,213,591,240C603.1,267,615,277,628,266.7C640,256,652,224,665,218.7C676.9,213,689,235,702,229.3C713.8,224,726,192,738,181.3C750.8,171,763,181,775,186.7C787.7,192,800,192,812,165.3C824.6,139,837,85,849,85.3C861.5,85,874,139,886,160C898.5,181,911,171,923,181.3C935.4,192,948,224,960,213.3C972.3,203,985,149,997,128C1009.2,107,1022,117,1034,144C1046.2,171,1058,213,1071,197.3C1083.1,181,1095,107,1108,96C1120,85,1132,139,1145,165.3C1156.9,192,1169,192,1182,181.3C1193.8,171,1206,149,1218,144C1230.8,139,1243,149,1255,170.7C1267.7,192,1280,224,1292,250.7C1304.6,277,1317,299,1329,288C1341.5,277,1354,235,1366,192C1378.5,149,1391,107,1403,128C1415.4,149,1428,235,1434,277.3L1440,320L1440,320L1433.8,320C1427.7,320,1415,320,1403,320C1390.8,320,1378,320,1366,320C1353.8,320,1342,320,1329,320C1316.9,320,1305,320,1292,320C1280,320,1268,320,1255,320C1243.1,320,1231,320,1218,320C1206.2,320,1194,320,1182,320C1169.2,320,1157,320,1145,320C1132.3,320,1120,320,1108,320C1095.4,320,1083,320,1071,320C1058.5,320,1046,320,1034,320C1021.5,320,1009,320,997,320C984.6,320,972,320,960,320C947.7,320,935,320,923,320C910.8,320,898,320,886,320C873.8,320,862,320,849,320C836.9,320,825,320,812,320C800,320,788,320,775,320C763.1,320,751,320,738,320C726.2,320,714,320,702,320C689.2,320,677,320,665,320C652.3,320,640,320,628,320C615.4,320,603,320,591,320C578.5,320,566,320,554,320C541.5,320,529,320,517,320C504.6,320,492,320,480,320C467.7,320,455,320,443,320C430.8,320,418,320,406,320C393.8,320,382,320,369,320C356.9,320,345,320,332,320C320,320,308,320,295,320C283.1,320,271,320,258,320C246.2,320,234,320,222,320C209.2,320,197,320,185,320C172.3,320,160,320,148,320C135.4,320,123,320,111,320C98.5,320,86,320,74,320C61.5,320,49,320,37,320C24.6,320,12,320,6,320L0,320Z",
      "M0,64L6.2,74.7C12.3,85,25,107,37,106.7C49.2,107,62,85,74,80C86.2,75,98,85,111,128C123.1,171,135,245,148,256C160,267,172,213,185,176C196.9,139,209,117,222,101.3C233.8,85,246,75,258,106.7C270.8,139,283,213,295,213.3C307.7,213,320,139,332,101.3C344.6,64,357,64,369,85.3C381.5,107,394,149,406,144C418.5,139,431,85,443,85.3C455.4,85,468,139,480,176C492.3,213,505,235,517,224C529.2,213,542,171,554,138.7C566.2,107,578,85,591,74.7C603.1,64,615,64,628,53.3C640,43,652,21,665,37.3C676.9,53,689,107,702,160C713.8,213,726,267,738,245.3C750.8,224,763,128,775,122.7C787.7,117,800,203,812,245.3C824.6,288,837,288,849,261.3C861.5,235,874,181,886,160C898.5,139,911,149,923,138.7C935.4,128,948,96,960,80C972.3,64,985,64,997,101.3C1009.2,139,1022,213,1034,202.7C1046.2,192,1058,96,1071,90.7C1083.1,85,1095,171,1108,176C1120,181,1132,107,1145,80C1156.9,53,1169,75,1182,101.3C1193.8,128,1206,160,1218,165.3C1230.8,171,1243,149,1255,138.7C1267.7,128,1280,128,1292,106.7C1304.6,85,1317,43,1329,64C1341.5,85,1354,171,1366,208C1378.5,245,1391,235,1403,208C1415.4,181,1428,139,1434,117.3L1440,96L1440,320L1433.8,320C1427.7,320,1415,320,1403,320C1390.8,320,1378,320,1366,320C1353.8,320,1342,320,1329,320C1316.9,320,1305,320,1292,320C1280,320,1268,320,1255,320C1243.1,320,1231,320,1218,320C1206.2,320,1194,320,1182,320C1169.2,320,1157,320,1145,320C1132.3,320,1120,320,1108,320C1095.4,320,1083,320,1071,320C1058.5,320,1046,320,1034,320C1021.5,320,1009,320,997,320C984.6,320,972,320,960,320C947.7,320,935,320,923,320C910.8,320,898,320,886,320C873.8,320,862,320,849,320C836.9,320,825,320,812,320C800,320,788,320,775,320C763.1,320,751,320,738,320C726.2,320,714,320,702,320C689.2,320,677,320,665,320C652.3,320,640,320,628,320C615.4,320,603,320,591,320C578.5,320,566,320,554,320C541.5,320,529,320,517,320C504.6,320,492,320,480,320C467.7,320,455,320,443,320C430.8,320,418,320,406,320C393.8,320,382,320,369,320C356.9,320,345,320,332,320C320,320,308,320,295,320C283.1,320,271,320,258,320C246.2,320,234,320,222,320C209.2,320,197,320,185,320C172.3,320,160,320,148,320C135.4,320,123,320,111,320C98.5,320,86,320,74,320C61.5,320,49,320,37,320C24.6,320,12,320,6,320L0,320Z",
      "M0,224L6.2,208C12.3,192,25,160,37,133.3C49.2,107,62,85,74,85.3C86.2,85,98,107,111,133.3C123.1,160,135,192,148,181.3C160,171,172,117,185,96C196.9,75,209,85,222,122.7C233.8,160,246,224,258,250.7C270.8,277,283,267,295,245.3C307.7,224,320,192,332,165.3C344.6,139,357,117,369,112C381.5,107,394,117,406,133.3C418.5,149,431,171,443,170.7C455.4,171,468,149,480,144C492.3,139,505,149,517,144C529.2,139,542,117,554,96C566.2,75,578,53,591,53.3C603.1,53,615,75,628,101.3C640,128,652,160,665,149.3C676.9,139,689,85,702,90.7C713.8,96,726,160,738,181.3C750.8,203,763,181,775,160C787.7,139,800,117,812,90.7C824.6,64,837,32,849,32C861.5,32,874,64,886,90.7C898.5,117,911,139,923,149.3C935.4,160,948,160,960,165.3C972.3,171,985,181,997,202.7C1009.2,224,1022,256,1034,266.7C1046.2,277,1058,267,1071,256C1083.1,245,1095,235,1108,218.7C1120,203,1132,181,1145,154.7C1156.9,128,1169,96,1182,117.3C1193.8,139,1206,213,1218,240C1230.8,267,1243,245,1255,224C1267.7,203,1280,181,1292,149.3C1304.6,117,1317,75,1329,53.3C1341.5,32,1354,32,1366,26.7C1378.5,21,1391,11,1403,26.7C1415.4,43,1428,85,1434,106.7L1440,128L1440,320L1433.8,320C1427.7,320,1415,320,1403,320C1390.8,320,1378,320,1366,320C1353.8,320,1342,320,1329,320C1316.9,320,1305,320,1292,320C1280,320,1268,320,1255,320C1243.1,320,1231,320,1218,320C1206.2,320,1194,320,1182,320C1169.2,320,1157,320,1145,320C1132.3,320,1120,320,1108,320C1095.4,320,1083,320,1071,320C1058.5,320,1046,320,1034,320C1021.5,320,1009,320,997,320C984.6,320,972,320,960,320C947.7,320,935,320,923,320C910.8,320,898,320,886,320C873.8,320,862,320,849,320C836.9,320,825,320,812,320C800,320,788,320,775,320C763.1,320,751,320,738,320C726.2,320,714,320,702,320C689.2,320,677,320,665,320C652.3,320,640,320,628,320C615.4,320,603,320,591,320C578.5,320,566,320,554,320C541.5,320,529,320,517,320C504.6,320,492,320,480,320C467.7,320,455,320,443,320C430.8,320,418,320,406,320C393.8,320,382,320,369,320C356.9,320,345,320,332,320C320,320,308,320,295,320C283.1,320,271,320,258,320C246.2,320,234,320,222,320C209.2,320,197,320,185,320C172.3,320,160,320,148,320C135.4,320,123,320,111,320C98.5,320,86,320,74,320C61.5,320,49,320,37,320C24.6,320,12,320,6,320L0,320Z"
    ];
    // const PATH_SOFTER = [
    //   // soft
    //   "M0,256L9.6,245.3C19.2,235,38,213,58,213.3C76.8,213,96,235,115,234.7C134.4,235,154,213,173,213.3C192,213,211,235,230,224C249.6,213,269,171,288,144C307.2,117,326,107,346,133.3C364.8,160,384,224,403,218.7C422.4,213,442,139,461,128C480,117,499,171,518,202.7C537.6,235,557,245,576,240C595.2,235,614,213,634,176C652.8,139,672,85,691,96C710.4,107,730,181,749,208C768,235,787,213,806,170.7C825.6,128,845,64,864,48C883.2,32,902,64,922,80C940.8,96,960,96,979,117.3C998.4,139,1018,181,1037,192C1056,203,1075,181,1094,165.3C1113.6,149,1133,139,1152,112C1171.2,85,1190,43,1210,58.7C1228.8,75,1248,149,1267,170.7C1286.4,192,1306,160,1325,170.7C1344,181,1363,235,1382,218.7C1401.6,203,1421,117,1430,74.7L1440,32L1440,320L1430.4,320C1420.8,320,1402,320,1382,320C1363.2,320,1344,320,1325,320C1305.6,320,1286,320,1267,320C1248,320,1229,320,1210,320C1190.4,320,1171,320,1152,320C1132.8,320,1114,320,1094,320C1075.2,320,1056,320,1037,320C1017.6,320,998,320,979,320C960,320,941,320,922,320C902.4,320,883,320,864,320C844.8,320,826,320,806,320C787.2,320,768,320,749,320C729.6,320,710,320,691,320C672,320,653,320,634,320C614.4,320,595,320,576,320C556.8,320,538,320,518,320C499.2,320,480,320,461,320C441.6,320,422,320,403,320C384,320,365,320,346,320C326.4,320,307,320,288,320C268.8,320,250,320,230,320C211.2,320,192,320,173,320C153.6,320,134,320,115,320C96,320,77,320,58,320C38.4,320,19,320,10,320L0,320Z",
    //   "M0,128L9.6,117.3C19.2,107,38,85,58,80C76.8,75,96,85,115,112C134.4,139,154,181,173,202.7C192,224,211,224,230,213.3C249.6,203,269,181,288,170.7C307.2,160,326,160,346,160C364.8,160,384,160,403,176C422.4,192,442,224,461,245.3C480,267,499,277,518,234.7C537.6,192,557,96,576,64C595.2,32,614,64,634,90.7C652.8,117,672,139,691,144C710.4,149,730,139,749,122.7C768,107,787,85,806,106.7C825.6,128,845,192,864,224C883.2,256,902,256,922,218.7C940.8,181,960,107,979,112C998.4,117,1018,203,1037,197.3C1056,192,1075,96,1094,85.3C1113.6,75,1133,149,1152,160C1171.2,171,1190,117,1210,96C1228.8,75,1248,85,1267,85.3C1286.4,85,1306,75,1325,106.7C1344,139,1363,213,1382,218.7C1401.6,224,1421,160,1430,128L1440,96L1440,320L1430.4,320C1420.8,320,1402,320,1382,320C1363.2,320,1344,320,1325,320C1305.6,320,1286,320,1267,320C1248,320,1229,320,1210,320C1190.4,320,1171,320,1152,320C1132.8,320,1114,320,1094,320C1075.2,320,1056,320,1037,320C1017.6,320,998,320,979,320C960,320,941,320,922,320C902.4,320,883,320,864,320C844.8,320,826,320,806,320C787.2,320,768,320,749,320C729.6,320,710,320,691,320C672,320,653,320,634,320C614.4,320,595,320,576,320C556.8,320,538,320,518,320C499.2,320,480,320,461,320C441.6,320,422,320,403,320C384,320,365,320,346,320C326.4,320,307,320,288,320C268.8,320,250,320,230,320C211.2,320,192,320,173,320C153.6,320,134,320,115,320C96,320,77,320,58,320C38.4,320,19,320,10,320L0,320Z",
    //   "M0,128L9.6,122.7C19.2,117,38,107,58,122.7C76.8,139,96,181,115,213.3C134.4,245,154,267,173,277.3C192,288,211,288,230,256C249.6,224,269,160,288,149.3C307.2,139,326,181,346,202.7C364.8,224,384,224,403,202.7C422.4,181,442,139,461,144C480,149,499,203,518,218.7C537.6,235,557,213,576,176C595.2,139,614,85,634,69.3C652.8,53,672,75,691,101.3C710.4,128,730,160,749,192C768,224,787,256,806,229.3C825.6,203,845,117,864,106.7C883.2,96,902,160,922,181.3C940.8,203,960,181,979,160C998.4,139,1018,117,1037,144C1056,171,1075,245,1094,272C1113.6,299,1133,277,1152,229.3C1171.2,181,1190,107,1210,64C1228.8,21,1248,11,1267,58.7C1286.4,107,1306,213,1325,256C1344,299,1363,277,1382,272C1401.6,267,1421,277,1430,282.7L1440,288L1440,320L1430.4,320C1420.8,320,1402,320,1382,320C1363.2,320,1344,320,1325,320C1305.6,320,1286,320,1267,320C1248,320,1229,320,1210,320C1190.4,320,1171,320,1152,320C1132.8,320,1114,320,1094,320C1075.2,320,1056,320,1037,320C1017.6,320,998,320,979,320C960,320,941,320,922,320C902.4,320,883,320,864,320C844.8,320,826,320,806,320C787.2,320,768,320,749,320C729.6,320,710,320,691,320C672,320,653,320,634,320C614.4,320,595,320,576,320C556.8,320,538,320,518,320C499.2,320,480,320,461,320C441.6,320,422,320,403,320C384,320,365,320,346,320C326.4,320,307,320,288,320C268.8,320,250,320,230,320C211.2,320,192,320,173,320C153.6,320,134,320,115,320C96,320,77,320,58,320C38.4,320,19,320,10,320L0,320Z",
    //   "M0,224L9.6,202.7C19.2,181,38,139,58,101.3C76.8,64,96,32,115,32C134.4,32,154,64,173,69.3C192,75,211,53,230,64C249.6,75,269,117,288,160C307.2,203,326,245,346,261.3C364.8,277,384,267,403,240C422.4,213,442,171,461,165.3C480,160,499,192,518,181.3C537.6,171,557,117,576,90.7C595.2,64,614,64,634,96C652.8,128,672,192,691,192C710.4,192,730,128,749,106.7C768,85,787,107,806,138.7C825.6,171,845,213,864,213.3C883.2,213,902,171,922,133.3C940.8,96,960,64,979,90.7C998.4,117,1018,203,1037,245.3C1056,288,1075,288,1094,261.3C1113.6,235,1133,181,1152,138.7C1171.2,96,1190,64,1210,96C1228.8,128,1248,224,1267,224C1286.4,224,1306,128,1325,96C1344,64,1363,96,1382,133.3C1401.6,171,1421,213,1430,234.7L1440,256L1440,320L1430.4,320C1420.8,320,1402,320,1382,320C1363.2,320,1344,320,1325,320C1305.6,320,1286,320,1267,320C1248,320,1229,320,1210,320C1190.4,320,1171,320,1152,320C1132.8,320,1114,320,1094,320C1075.2,320,1056,320,1037,320C1017.6,320,998,320,979,320C960,320,941,320,922,320C902.4,320,883,320,864,320C844.8,320,826,320,806,320C787.2,320,768,320,749,320C729.6,320,710,320,691,320C672,320,653,320,634,320C614.4,320,595,320,576,320C556.8,320,538,320,518,320C499.2,320,480,320,461,320C441.6,320,422,320,403,320C384,320,365,320,346,320C326.4,320,307,320,288,320C268.8,320,250,320,230,320C211.2,320,192,320,173,320C153.6,320,134,320,115,320C96,320,77,320,58,320C38.4,320,19,320,10,320L0,320Z"
    // ];
    final i = math.Random().nextInt(PATHS.length);
    writeSvgPathDataToPath(PATHS[i], PathWriter(path: svgData));
  }
}

class Bubble {
  /// Bubble animations
  late Animation<double> positionAnimation;

  /// Bubble animations
  late Animation<double> opacityAnimation;

  /// Bubble animations
  late Animation<double> sizeAnimation;

  /// Bubble animation controller
  late AnimationController controller;
  late TickerProvider provider;

  /// X position
  double initialX = 0;

  /// Starting color
  Color initialColor = Colors.blueGrey;

  /// Current color
  Color get color => initialColor.withAlpha(opacityAnimation.value.toInt());

  /// Current X position
  double get x => initialX;

  /// Current Y position
  double get y => positionAnimation.value;

  /// Current size
  double get size => sizeAnimation.value;

  /// Setup animations
  void init(TickerProvider provider) {
    this.provider = provider;
    controller = AnimationController(
      vsync: provider,
      duration: const Duration(milliseconds: 10000),
    );
  }

  /// Clean up
  void dispose() {
    controller.dispose();
  }

  /// Get a random easing method
  Curve randomCurve() {
    switch (math.Random().nextInt(5)) {
      case 0:
        return Curves.ease;
      case 1:
        return Curves.easeInOutSine;
      case 2:
        return Curves.easeInSine;
      case 3:
        return Curves.easeOutSine;
      case 4:
        return Curves.easeInOutQuad;
      case 5:
        return Curves.easeInQuad;
      case 6:
        return Curves.easeOutQuad;
      case 7:
        return Curves.easeInOutExpo;
      case 8:
        return Curves.easeOutExpo;
      case 9:
        return Curves.easeInExpo;
      default:
    }
    return Curves.linear;
  }

  /// Randomize bubble behavior, run at initialization or respawn
  void randomize() {
    controller.duration =
        Duration(milliseconds: math.Random().nextInt(7000) + 3000);
    initialColor = HSLColor.fromAHSL(
        1.0,
        math.Random().nextDouble(),
        math.Random().nextDouble() * 0.3,
        math.Random().nextDouble() * 0.3 + 0.7)
        .toColor();
    initialX = math.Random().nextDouble();
    double initialY = math.Random().nextDouble() * 0.3 + 1.0;
    double finalY = math.Random().nextDouble() * 0.3 + 0.2;
    double initialSize = math.Random().nextDouble() * 0.01;
    double finalSize = math.Random().nextDouble() * 0.1;

    positionAnimation = Tween<double>(begin: initialY, end: finalY)
        .animate(CurvedAnimation(parent: controller, curve: randomCurve()));
    sizeAnimation = Tween<double>(begin: initialSize, end: finalSize).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutSine));
    opacityAnimation = Tween<double>(
        begin: math.Random().nextDouble() * 100 + 155, end: 0)
        .animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutSine));
    positionAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.repeat();
        randomize();
      }
    });
    controller.forward();
  }
}