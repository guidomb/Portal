Portal
======

[![Build Status](https://www.bitrise.io/app/35802d5e71a76792/status.svg?token=Lk2FPQhMq_PaxQDKN47dRA&branch=master)](https://www.bitrise.io/app/35802d5e71a76792)
[![Swift](https://img.shields.io/badge/swift-4-orange.svg?style=flat)](#)
[![GitHub release](https://img.shields.io/github/release/guidomb/Portal.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](#)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)

A (potentially) cross-platform, unidirectional data flow framework to build applications using a declarative and immutable UI API.

**WARNING!: This is still a work-in-progress, although the minimum features are available to create real world applications the API is still under design and some key optimizations are still missing. Use at your own risk.**

## TL; DR;

 * An application framework heavily inspired by the [Elm architecture](https://guide.elm-lang.org/architecture/).
 * Declarative API inspired by Elm and React.
 * 100% in Swift and decoupled from UIKit which makes it (potentially) cross-platform.
 * Uses facebook's [Yoga](https://github.com/facebook/yoga). A cross-platform layout engine that implements Flexbox which is used by ReactNative.
 * Leverage the Swift compiler in order to have a strongly type-safe API.



All you need to do to have a working application is to implement the `Application` protocol.

```swift
public protocol Application {

    associatedtype MessageType
    associatedtype StateType
    associatedtype CommandType
    associatedtype RouteType: Route
    associatedtype SubscriptionType: Equatable
    associatedtype NavigatorType: Equatable

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

Here is a sneak peak of the API but you can also check [this examples](https://github.com/guidomb/Portal#example) or read the library [documentation](./Documentation/View.md) to learn more about the main concepts.

```swift
enum Message {

  case like
  case goToDetailScreen

}

let component: Component<Message> = container(
  children: [
    label(
      text: "Hello Portal!",
      style: labelStyleSheet() { base, label in
          base.backgroundColor = .white
          label.textColor = .red
          label.textSize = 12
      },
      layout: layout() {
          $0.flex = flex() {
              $0.grow = .one
          }
          $0.justifyContent = .flexEnd
      }
    )
    button(
      properties: properties() {
          $0.text = "Tap to like!"
          $0.onTap = .like
      }
    )
    button(
      properties: properties() {
          $0.text = "Tap to got to detail screen"
          $0.onTap = .goToDetailScreen
      }
    )
  ]
)
```

## Installation

### Carthage

Install [Carthage](https://github.com/Carthage/Carthage) first by either using the [official .pkg installer](https://github.com/Carthage/Carthage/releases) for the latest release or If you use [Homebrew](http://brew.sh) execute the following commands:

```
brew update
brew install carthage
```

Once Carthage is installed add the following entry to your `Cartfile`

```
github "guidomb/Portal" "master"
```

### Manual

TODO

## Example

For some examples on how the API looks like and how to use this library check

 * The [example](./Example) target in this repository.
 * The [Voices](https://github.com/guidomb/voices) Twitter client application.

## Documentation

Portal is still a work-in-progress. Documentation will be added as the library matures inside the [Documentation](./Documentation) directory.
You can read the library [overview](./Documentation/Overview.md) to learn more about the main concepts.

## Contribute

### Setup

Install [Carthage](https://github.com/Carthage/Carthage) first, then run

```
git clone git@github.com:guidomb/Portal.git
cd Portal
script/bootstrap
open Portal.xcodeproj
```

If you want to know how the project is doing, what features are in the pipeline for the next milestone and whare are the ideas that already in the backlog, check [this repo's project](https://github.com/guidomb/Portal/projects/1)
