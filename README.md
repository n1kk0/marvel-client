# marvel_client
![Flutter Tests](https://github.com/n1kk0/marvel-client/workflows/Flutter/badge.svg)

## Production envrironment
https://marvel.techmeup.io

## Development environment
### Prerequisites
Install Dart and Flutter https://flutter.dev/docs/get-started/install

### Dependencies (optionnal)
Install the API Proxy: https://github.com/n1kk0/marvel_proxy

### Run
Then use VS.Code with the `.vscode` directory configuration.

### Architecture
* data
  * sources: APIs, device I/Os, AuthProviders, ...
  * models: domain models objects
  * providers: view models with state
* ui
  * screens: Web pages
  * views: composite UI contents
  * widgets: unit elements of UI
