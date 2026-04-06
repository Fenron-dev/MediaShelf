import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;

/// A 3D preview widget that renders a Wavefront OBJ file using flutter_cube.
///
/// - Supports mouse/touch drag for rotation.
/// - Supports scroll-wheel / pinch for zoom.
/// - Shows a loading indicator while the model is being loaded.
/// - Falls back to an error icon if the model cannot be rendered.
///
/// [objPath] must be an absolute filesystem path to the .obj file.
/// flutter_cube automatically loads the sibling .mtl file (same basename,
/// same directory) when it exists.
class Obj3dPreview extends StatefulWidget {
  const Obj3dPreview({super.key, required this.objPath});

  final String objPath;

  @override
  State<Obj3dPreview> createState() => _Obj3dPreviewState();
}

class _Obj3dPreviewState extends State<Obj3dPreview> {
  cube.Scene? _scene;
  bool _loaded = false;
  bool _error = false;

  // Rotation state
  double _yaw = 0;
  double _pitch = 15;

  // Zoom state (distance from camera)
  double _zoom = 5;
  static const _minZoom = 1.0;
  static const _maxZoom = 20.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _yaw += details.delta.dx * 0.5;
                _pitch =
                    (_pitch - details.delta.dy * 0.5).clamp(-90.0, 90.0);
              });
              _applyRotation();
            },
            child: Listener(
              onPointerSignal: (event) {
                // Scroll wheel zoom
                if (event is PointerScrollEvent) {
                  setState(() {
                    _zoom = (_zoom + event.scrollDelta.dy * 0.01)
                        .clamp(_minZoom, _maxZoom);
                  });
                  _applyZoom();
                }
              },
              child: cube.Cube(
                onSceneCreated: (scene) {
                  _scene = scene;
                  _setupScene(scene);
                },
              ),
            ),
          ),

          // Loading indicator
          if (!_loaded && !_error)
            const Center(child: CircularProgressIndicator()),

          // Error state
          if (_error)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.view_in_ar_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vorschau nicht verfügbar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _setupScene(cube.Scene scene) {
    scene.camera.zoom = _zoom;

    try {
      scene.world.add(
        cube.Object(
          fileName: widget.objPath,
          isAsset: false, // absolute filesystem path, not a Flutter asset
        )..rotation.setValues(_pitch, _yaw, 0),
      );
      setState(() => _loaded = true);
    } catch (e) {
      setState(() {
        _error = true;
        _loaded = true;
      });
    }
  }

  void _applyRotation() {
    if (_scene == null || _scene!.world.children.isEmpty) return;
    _scene!.world.children.first.rotation.setValues(_pitch, _yaw, 0);
    _scene!.update();
  }

  void _applyZoom() {
    if (_scene == null) return;
    _scene!.camera.zoom = _zoom;
    _scene!.update();
  }
}
