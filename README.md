# Bounce

[![pub package](https://img.shields.io/pub/v/bounce.svg)](https://pub.dev/packages/bounce)


This package adds a new `Bounce` widget that applies a tap-triggered bounce animation to Flutter widgets. Depending on the touch location, a tilt effect is also added on the child.

!["Demo of the Bounce plugin"](https://github.com/mrcendre/bounce/raw/main/gifs/demo.gif)

To see examples of the following effect on a device or simulator:

```bash
cd example/
flutter run --release
```

# How to use 

First, add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  bounce: ^<latest-version>
```

Then, wrap your target widget as child of a `Bounce` widget. You may optionally specify additional behavior, such as disabling the tilt effect by adding `tilt: false` to the constructor. The simplest usage of this widget is the following :

```dart

import 'package:bounce/bounce.dart';

...

return Bounce(
        onTap: () {
          // ...
        },
        child: ...)

```

# Custom behavior

## Tilt effect

You may specify the maximum angle applied by the tilt effect using the `tiltAngle`. This angle will be reached when the child widget is tapped at its edges. No tilt is applied when the child is tapped exactly at its center. 

## Scale effect

You may specify the maximum factor applied by the scale effect using the `scaleFactor` parameter.

## Tap delay

To fine tune your user experience, you may want the various effects to animate back for a few milliseconds after the tap has occured. By default, this delay is set to `150` milliseconds.

## Filter quality

The Bounce widget implementation wraps the child with a matrix-based `Transform` widget. On most platforms, it is a good practice to have it set to `FilterQuality.high`, which is the default value. You may specify other `FilterQuality` values directly from the widget's constructor :

```dart
  Bounce(
    filterQuality: FilterQuality.medium,
    child: ...
  )
```

Due to limitations on Safari iOS and if your app targets it, you are responsible for enforcing `filterQuality` to `null` in this specific browser.


## Combination with [`Motion`](https://pub.dev/packages/motion) widgets

Bounce widgets look gorgeous when combined with a [`Motion`](https://pub.dev/packages/motion) widget, like so :

```dart
  Motion(
    child: Bounce(
      child: ...
    )
  )
```

Here is an interaction example :

!["Bounce + Motion example"](https://github.com/mrcendre/bounce/raw/main/gifs/bounce_motion.gif)

_Comparing different tilt angles_

# Issues

If you are having any problem with the Bounce package, you can file an issue on the package repo's [issue tracker](https://github.com/mrcendre/bounce/issues/).

Please make sure that your concern hasn't already been addressed in the 'Closed' section.

# Credits

This package was developed with ♥ by [@mrcendre](https://cendre.me/).