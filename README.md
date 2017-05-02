PortalApplication
=================

[![Swift](https://img.shields.io/badge/swift-3-orange.svg?style=flat)](#)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](#)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)

A unidirectional data flow framework to build applications using the [PortalView](https://github.com/guidomb/PortalView) declarative UI library.

**WARNING!: This is still a work-in-progress, although the minimum features are available to create real world applications the API is still under design and some key optimizations are still missing. Use at your own risk.**

## TL; DR;

 * An application framework heavily inspired by the [Elm architecture](https://guide.elm-lang.org/architecture/).
 * Uses [PortalView](https://github.com/guidomb/PortalView) declarative UI library.


All you need to do to have a working application is to implement the `Application` protocol.

```swift
public protocol Application {

    associatedtype MessageType
    associatedtype StateType
    associatedtype CommandType
    associatedtype RouteType: Route
    associatedtype SubscriptionType: Equatable
    associatedtype NavigatorType: Navigator

    var initialState: StateType { get }

    var initialRoute: RouteType { get }

    func translateRouteChange(from currentRoute: RouteType, to nextRoute: RouteType) -> MessageType?

    func update(state: StateType, message: MessageType) -> (StateType, CommandType?)?

    func view(for state: StateType) -> View<RouteType, MessageType, NavigatorType>

    func subscriptions(for state: StateType) -> [Subscription<MessageType, RouteType, SubscriptionType>]

}
```

The application state is updated in a centralized place every time a new message arrives. Messages can be triggered by user actions or as the result of a computation or access to an external system (like a web service o database).

Every time a new messages arrives, the `update` function is called. This function responsibility is to provide the next application's state and return a command to be executed in case side-effects are needed, like fetching data from a web service.

Once a new state has been computed the `view` function will be called to render a new view.

## Installation

### Carthage

Install [Carthage](https://github.com/Carthage/Carthage) first by either using the [official .pkg installer](https://github.com/Carthage/Carthage/releases) for the latest release or If you use [Homebrew](http://brew.sh) execute the following commands:

```
brew update
brew install carthage
```

Once Carthage is installed add the following entry to your `Cartfile`

```
github "guidomb/PortalApplication" "master"
```

### Manual

TODO

## Example

For some examples on how the API looks like and how to use this library check

 * The [example](./Example) target in this repository.
 * The [Voices](https://github.com/guidomb/voices) Twitter client application.

## Documentation

PortalApplication is still a work-in-progress. Documentation will be added as the library matures inside the [Documentation](./Documentation) directory.
You can read the library [overview](./Documentation/Overview.md) to learn more about the main concepts.

## Contribute

### Setup

Install [Carthage](https://github.com/Carthage/Carthage) first, then run

```
git clone git@github.com:guidomb/PortalApplication.git
cd PortalApplication
script/bootstrap
open PortalApplication.xcworkspace
```
