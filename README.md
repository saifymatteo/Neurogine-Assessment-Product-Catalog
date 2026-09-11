# Product Catalog

A simple Product Catalog app made for the Neurogine Assessment.

## Getting Started

### Pre-requisites

- Flutter v3.44.* (not applicable for Docker)

> Recommended to use [`puro` for easy install with specific Flutter version](https://puro.dev/)

### Running the App

via CLI:

```bash
flutter pub get
flutter run # Choose your platform
```

via VS Code: Simply use the 'Run and Debug' in the VS Code and choose `Dev` profile

via Docker:

```bash
docker compose up -d
docker compose attach web # Allow hot reload / restart from your terminal

docker compose down # To stop and remove the container
```

Wait for few minutes for the Docker to compiles the app and serve the `main.dart.js`. Once done, open `http://localhost:8081/` in your browser.

## Architecture

> Note: This is a first time I'm using Bloc with their suggested architecture. But I'm hoping I got the terminology here correct.

```pattern
lib
 |-- cores                       # All core (utils, network, common)
      |-- network                # Network/API client
      |-- ui                     # Shared UI widgets
 |-- features                    # All features (data, domain, presentation layer)
      |-- feature 1
           |-- data              # Data layer
           |-- domain            # Domain layer
           |-- presentation      # Presentation layer
 |-- models                      # Data models
 |-- dependencies.dart           # All dependencies initialization
 |-- main.dart                   # Flutter entrypoint
```

For **debounce**, I simply using [stream_transform](https://pub.dev/packages/stream_transform) as suggested by Bloc. Implementing it in client-side is the simplest approach with minimal issue rather than on the data layer side.

For `Widget` that started with underscore `_` like `_Content` are meant to be single file used.

### FAQ

- Why the model properties are nullable?
  - Because I don't own the API and not sure what values are actually null vs non-null. By making everything nullable, I can guard against the API itself

## TODO

- [x] Product List page
  - [x] Search feature
  - [x] Pagination
- [x] Product Detail page
- [x] States indicator for each pages
- [x] Error handling for each pages
- [x] Explains the code organization
- [x] Unit tests

## Future Improvements

- Better UI design
- More unit tests
- Localization with ARB

## Extra

I use extra tools for this project:

- [quicktype](https://app.quicktype.io/?l=dart) - bootstrap the API models

Additional package dependencies for convenience:

- [skeletonizer](https://pub.dev/packages/skeletonizer) - shimmer for thumbnails
- [cached_network_image](https://pub.dev/packages/cached_network_image) - displaying images with internal caching mechanism
- [intl](https://pub.dev/packages/intl) - handling currency display
- [very_good_analysis](https://pub.dev/packages/very_good_analysis) - sane default and opinionated linting
- [very_good_infinite_list](https://pub.dev/packages/very_good_infinite_list) - convenience infinite scrolling for load more function
- [flutter_rating_bar](https://pub.dev/packages/flutter_rating_bar) - convenience rating bar product detail

## AI Usage

- Debugging on why `build_runner` is stuck on `Running FreezedGenerator` indefinitely. Caused by zombie `dart.exe` processes holding the build_runner lock
- How to do unit tests with Bloc + Dio as network service. By default, Dio throw exception because of bad response 400.
