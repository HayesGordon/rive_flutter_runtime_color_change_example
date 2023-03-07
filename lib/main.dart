import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rive/math.dart';
import 'package:rive/rive.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const RiveColorChangeApp());
}

/// A demonstration of using a custom Rive render object.
///
///
/// This example is intended to show how to update the color of shapes (fills) at runtime
/// and to ensure the correct opacity (alpha) value is set dependent on animation updates.
///
/// This is not meant to be a complete example of updating all component colors.
/// The code can should be extended/modified to fit your particular needs.
class RiveColorChangeApp extends StatelessWidget {
  const RiveColorChangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ColorChangePage(),
    );
  }
}

class ColorChangePage extends StatefulWidget {
  const ColorChangePage({Key? key}) : super(key: key);

  @override
  State<ColorChangePage> createState() => _ColorChangePageState();
}

class _ColorChangePageState extends State<ColorChangePage> {
  /// We track if the animation is playing by whether or not the controller is
  /// running.
  bool get isPlaying => _controller?.isActive ?? false;

  Artboard? _riveArtboard;
  RiveAnimationController? _controller;

  Future<void> _load() async {
    var file = await RiveFile.asset('assets/opacity_runtime_change.riv');
    var artboard = file.mainArtboard;
    artboard.addController(_controller = SimpleAnimation('Timeline 1'));
    setState(() => _riveArtboard = artboard);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _riveArtboard == null
            ? const SizedBox()
            : RiveColorModifier(
                artboard: _riveArtboard!,
                fit: BoxFit.contain,
                components: [
                  RiveColorComponent(
                    shapeName: 'box-shape-1',
                    fillName: 'box-fill-1',
                    color: Colors.purple,
                  ),
                  RiveColorComponent(
                    shapeName: 'box-shape-2',
                    fillName: 'box-fill-2',
                    color: Colors.green,
                  ),
                ],
              ),
      ),
    );
  }
}

class RiveColorComponent {
  /// The name of the shape (as defined in the editor)
  final String shapeName;

  /// The name of the fill (as defined in the editor)
  final String fillName;

  /// The color to update to
  final Color color;

  Shape? shape;
  Fill? fill;

  RiveColorComponent({
    required this.shapeName,
    required this.fillName,
    required this.color,
  });

  @override
  bool operator ==(covariant RiveColorComponent other) {
    if (identical(this, other)) return true;

    return other.fillName == fillName &&
        other.shapeName == shapeName &&
        other.color == color;
  }

  @override
  int get hashCode {
    return fillName.hashCode ^ shapeName.hashCode ^ color.hashCode;
  }
}

class RiveColorModifier extends LeafRenderObjectWidget {
  final Artboard artboard;
  final BoxFit fit;
  final Alignment alignment;
  final List<RiveColorComponent> components;

  const RiveColorModifier({
    super.key,
    required this.artboard,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.components = const [],
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RiveCustomRenderObject(artboard as RuntimeArtboard)
      ..artboard = artboard
      ..fit = fit
      ..alignment = alignment
      ..components = components;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RiveCustomRenderObject renderObject) {
    renderObject
      ..artboard = artboard
      ..fit = fit
      ..alignment = alignment
      ..components = components;
  }

  @override
  void didUnmountRenderObject(covariant RiveCustomRenderObject renderObject) {
    renderObject.dispose();
  }
}

/// Create a custom Rive render object to tap into the draw method.
class RiveCustomRenderObject extends RiveRenderObject {
  List<RiveColorComponent> _components = [];

  RiveCustomRenderObject(super.artboard);
  List<RiveColorComponent> get components => _components;

  set components(List<RiveColorComponent> value) {
    if (listEquals(_components, value)) {
      return;
    }
    _components = value;

    for (final component in _components) {
      component.shape = artboard.objects.firstWhereOrNull(
        (element) => element is Shape && element.name == component.shapeName,
      ) as Shape?;

      if (component.shape != null) {
        component.fill = component.shape!.fills
            .firstWhereOrNull((element) => element.name == component.fillName);
        if (component.fill == null) {
          throw Exception("Could not find fill named: ${component.fillName}");
        }
      } else {
        throw Exception("Could not find shape named: ${component.shapeName}");
      }
    }
    markNeedsPaint();
  }

  @override
  void draw(Canvas canvas, Mat2D viewTransform) {
    for (final component in _components) {
      if (component.fill == null) return;

      component.fill!.paint.color =
          component.color.withAlpha(component.fill!.paint.color.alpha);
    }

    super.draw(canvas, viewTransform);
  }
}
