# Rive Flutter Runtime Color Change Example
This example demonstrates how you can make use of a custom Rive render object to dynamically change the color of components at runtime - while also respecting their opacity (alpha values) during animation.

## Example

This example changes the color of two shapes, by specifying the correct shape and fill names (as defined in the editor).

Example code:

```dart
RiveColorModifier(
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
```
Note that the **shape** and **fill** names need to be specified in order to find them at runtime.

![CleanShot 2023-03-07 at 14 24 24](https://user-images.githubusercontent.com/13705472/223434984-ce839e80-03d9-4f8b-aeee-8308975b3300.png)

https://user-images.githubusercontent.com/13705472/223434324-5bcc0d61-302f-4501-b978-68bd12eaa4f4.mp4
