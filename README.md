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

via VS Code: Simply use the 'Run and Debug' in the VS Code

via Docker:

```bash
docker compose up -d
```

## Architecture

> Note: This is a first time I'm using Bloc with their suggested architecture. But I'm hoping I got the terminology here correct.

```pattern
lib
 |-- cores                  # All core (utils, network, common)
 |-- features               # All features (data, domain, presentation layer)
 |-- models                 # Data models
 |-- dependencies.dart      # All dependencies initialization
 |-- main.dart              # Flutter entrypoint
```

### FAQ

- Why the model properties are nullable?
  - Because I don't own the API and not sure what values are actually null vs non-null. By making everything nullable, I can guard against the API itself

## TODO

- [ ] Product List page
  - [ ] Search feature
  - [ ] Pagination
- [ ] Product Detail page
- [ ] States indicator for each pages
- [ ] Explains the code organization

## AI Usage

For debugging on why `build_runner` is stuck on `Running FreezedGenerator` indefinitely. Caused by zombie `dart.exe` processes holding the build_runner lock
