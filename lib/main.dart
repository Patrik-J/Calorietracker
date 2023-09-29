import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calorie_indicator.dart';
import 'dart:io';
import 'setup.dart';

void main() {
  //  Setup.initSetup();
  runApp(const MyApp());
}

void _addConsumption() {

}

///idk
const double widthConstant = 0.95;
const double heightConstant = 0.25;
const double spacingConstant = 0.05;
double? _userScreenWidth;
double caloriePercentage = 0.4;


///JSON stuff
late File settings;
late File intake;



class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const BasicPage(title: "Calorie Tracker"),//const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


class BasicPage extends StatefulWidget {
  const BasicPage({super.key, required this.title});

  final String title;

  @override
  State<BasicPage> createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {
  int selectedIndex = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),

       */
      /*
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
      ),

       */
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        indicatorColor: Colors.white,
        selectedIndex: selectedIndex,
        backgroundColor: Colors.blueGrey,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_2),
            icon: Icon(Icons.person_2_outlined),
            label: 'Me',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.sports_soccer),
            icon: Icon(Icons.sports_soccer_outlined),
            label: 'Activity',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.multiline_chart),
            icon: Icon(Icons.multiline_chart_outlined),
            label: 'Stats',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
      body: <Widget>[
        /*
        Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text('Page 1'),
        ),
        Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text('Page 2'),
        ),
        Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text('Page 3'),
        ),
        Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text('Page 4'),
        ),
        Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text('Page 5'),
        ),
        
         */
        const HomePage(),
        const MePage(),
        const ActPage(),
        const StatsPage(),
        const SettingsPage()
      ][selectedIndex],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? screenHeight;
  double? screenWidth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
      //userScreenWidth ??= screenWidth;
      _userScreenWidth ??= screenWidth!;
      setState(() {}); // This will trigger a rebuild with the updated values.
    });
  }


  @override
  Widget build(BuildContext context) {
    //screenWidth = null;
    //screenHeight = null;
    if(screenHeight == null || screenWidth == null) {
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: const Text('Error in loading app.\nPlease read further instructions.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), ),
        ),
      );
    } else {
      return Scaffold(

        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.blueGrey,
          systemOverlayStyle: const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black, systemNavigationBarDividerColor: Colors.black, statusBarColor: Colors.blueGrey, statusBarBrightness: Brightness.light),
          title: const Center (
          child: Text(
          'CalorieFit',
          style: TextStyle(
          color: Colors.white,
          fontSize: 30,

      ),
          ),
        ),
        ),

        body: CustomScrollView(
          shrinkWrap: true,
          slivers: <Widget>[

            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Column(

                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: (screenHeight! * spacingConstant)),
                        Container(
                          width: screenWidth! * widthConstant, // Width of the rectangle
                          height: screenHeight! * heightConstant, // Height of the rectangle
                          //color: Colors.blue, // Color of the
                          decoration: BoxDecoration(
                            color: Colors.white, // Color of the rectangle
                            borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                          ),
                          child:  Stack(
                            children: [
                              const Positioned(
                                top: 5,
                                left: 10,
                                child: Text(
                                  'Food consumption',
                                  style: TextStyle(
                                    color: Colors.black, // Text color
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,// Text size
                                  ),

                                ),
                              ),
                              Center(
                                heightFactor: 2,
                                child:
                                CalorieIndicator(
                                  radius: screenHeight! * 0.08,
                                  lineWidth: 20.0,
                                  percent: 0.8,
                                  center: AchievedCalories(style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                  ),),
                                  parts: const [0.2, 0.3, 0.5],
                                  animationDuration: 500,
                                  animation: true,
                                  backgroundColor: Colors.blueGrey,
                                  addAutomaticKeepAlive: false,
                                  animateFromLastPercent: true,
                                  progressColors: const [Colors.red, Colors.green, Colors.yellow],

                                ),
                              ),

                              const Positioned(
                                top: 70,
                                right: 80,
                                child: TextWithColorPoint(text: 'Protein', pointColor: Colors.green,),
                              ),
                              const Positioned(
                                top: 90,
                                right: 80,
                                child: TextWithColorPoint(text: 'Carbs', pointColor: Colors.yellow,),
                              ),
                              const Positioned(
                                top: 110,
                                right: 80,
                                child: TextWithColorPoint(text: 'Fats', pointColor: Colors.red,),
                              ),
                            ],
                          ),

                          ),

                        SizedBox(height: (screenHeight! * spacingConstant)),
                        Container(
                          width: screenWidth! * widthConstant, // Width of the rectangle
                          height: screenHeight! * heightConstant, // Height of the rectangle
                          //color: Colors.blue, // Color of the
                          decoration: BoxDecoration(
                            color: Colors.white, // Color of the rectangle
                            borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                          ),
                          child: const Center(
                            child: Text(
                              'Water consumption',
                              style: TextStyle(
                                color: Colors.black, // Text color
                                fontSize: 20, // Text size
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: (screenHeight! * spacingConstant)),
                        Container(
                          width: screenWidth! * widthConstant, // Width of the rectangle
                          height: screenHeight! * heightConstant, // Height of the rectangle
                          //color: Colors.blue, // Color of the
                          decoration: BoxDecoration(
                            color: Colors.white, // Color of the rectangle
                            borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                          ),
                          child: const Center(
                            child: Text(
                              'Daily activity',
                              style: TextStyle(
                                color: Colors.black, // Text color
                                fontSize: 20, // Text size
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: (screenHeight! * 0.05)),
                      ],
                    );
                  },
                childCount: 1,
              ),


            ),
          ],


        ),
      );
    }
  }
}

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Me Page'),
    );
  }
}

class ActPage extends StatefulWidget {
  const ActPage({super.key});

  @override
  State<ActPage> createState() => _ActPageState();
}

class _ActPageState extends State<ActPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Activity Page'),
    );
  }
}

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Stats Page'),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Settings Page'),
    );
  }
}


class TextWithColorPoint extends StatelessWidget {
  final String text;
  final Color pointColor;

  const TextWithColorPoint({
    super.key,
    required this.pointColor,
    required this.text,
});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TextWithColorPointPainter(text: text, color: pointColor),
    );
  }

}

class TextWithColorPointPainter extends CustomPainter {
  final String text;
  final Color color;

  TextWithColorPointPainter({
    required this.text,
    required this.color
});

  @override
  void paint(Canvas canvas, Size size) {
    const textStyle = TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold);

    final pointPaint = Paint()
      ..color = color
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;



    TextSpan textSpan = TextSpan(text: text, style: textStyle);
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0, 2));

    if(_userScreenWidth == null) throw Exception("_userScreenWidth must not be null");
    final pointX = - _userScreenWidth! * 0.03;
    final pointY = 2 + textPainter.height / 2;
    canvas.drawPoints(PointMode.points, [Offset(pointX, pointY)], pointPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AchievedCalories extends StatelessWidget {
  final TextStyle style;

  AchievedCalories({
    super.key,
    required this.style
});

  late double achieved;
  late double goal;

  @override
  Widget build(BuildContext context) {
    goal = 1200;
    achieved = caloriePercentage * goal;
    return Text(
     style: style,
     '$achieved /\n$goal\nkcal'
    );
  }
}