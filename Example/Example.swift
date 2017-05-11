//
//  Example.swift
//  Example
//
//  Created by Guido Marucci Blas on 3/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit
import PortalApplication
import PortalView

enum Message {
    
    case applicationStarted
    case replaceContent
    case goToRoot
    case routeChanged(to: Route)
    case increment
    case tick(Date)
    case ping(Date)
    case pong(String)
    case stateLoaded(State?)
    
}

enum Command {
    
    case loadStoredState
    
}

enum Navigator: PortalApplication.Navigator {
    
    case main
    case modal
    case other
    
    var baseRoute: Route {
        switch self {
        case .main:
            return .root
        case .modal:
            return .modal
        case .other:
            return .root
        }
    }
    
}

enum Route: PortalApplication.Route {
    
    case root
    case modal
    case detail
    case landscape
    
    var previous: Route? {
        switch self {
        case .root:
            return .none
        case .detail:
            return .root
        case .modal:
            return .root
        case .landscape:
            return .root
        }
    }
    
}

enum State {
    
    case uninitialized
    case started(date: Date?, showAlert: Bool)
    case replacedContent
    case detailedScreen(counter: UInt)
    case modalScreen(counter: UInt)
    case landscapeScreen(text: String, counter: UInt)
    
}

enum IgniteSubscription: Equatable {
    
    case foo
    
}

final class ExampleSubscriptionManager: PortalApplication.SubscriptionManager {
    
    func add(subscription: IgniteSubscription, dispatch: @escaping (ExampleApplication.Action) -> Void) {
        
    }
    
    func remove(subscription: IgniteSubscription) {
        
    }
    
}

final class ExampleCommandExecutor: PortalApplication.CommandExecutor {
    
    let loadState: () -> State?
    
    init(loadState: @escaping () -> State?) {
        self.loadState = loadState
    }
    
    func execute(command: Command, dispatch: @escaping (ExampleApplication.Action) -> Void) {
        switch command {
            
        case .loadStoredState:
            dispatch(.sendMessage(.stateLoaded(loadState())))
            
        }
    }
    
}

final class ExampleApplication: PortalApplication.Application {
    
    typealias Action = PortalApplication.Action<Route, Message>
    typealias View = PortalApplication.View<Route, Message, Navigator>
    typealias Subscription = PortalApplication.Subscription<Message, Route, IgniteSubscription>
    
    var initialState: State { return .uninitialized }
    
    var initialRoute: Route { return .root }
    
    func translateRouteChange(from currentRoute: Route, to nextRoute: Route) -> Message? {
        print("Route change '\(currentRoute)' -> '\(nextRoute)'")
        return .routeChanged(to: nextRoute)
    }
    
    func update(state: State, message: Message) -> (State, Command?)? {
        switch (state, message) {
            
        case (.uninitialized, .applicationStarted):
            return (.uninitialized, .loadStoredState)
            
        case (.uninitialized, .stateLoaded(.none)):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.uninitialized, .stateLoaded(.some(let loadedState))):
            return (loadedState, .none)
            
        case (.started, .replaceContent):
            return (.replacedContent, .none)
            
        case (.started, .routeChanged(.modal)):
            return (.modalScreen(counter: 0), .none)
            
        case (.started, .routeChanged(.detail)):
            return (.detailedScreen(counter: 0), .none)
            
        case (.started, .routeChanged(.landscape)):
            return (.landscapeScreen(text: "Hello!", counter: 0), .none)
            
        case (.started, .tick(let date)):
            return (.started(date: date, showAlert: false), .none)
            
        case (.replacedContent, .goToRoot):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.detailedScreen, .routeChanged(.root)):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.detailedScreen(let counter), .increment):
            return (.detailedScreen(counter: counter + 1), .none)
            
        case (.detailedScreen(let counter), .ping(_)):
            return (.detailedScreen(counter: counter + 1), .none)
            
        case (.modalScreen, .routeChanged(.root)):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.modalScreen(let counter), .routeChanged(.detail)):
            return (.detailedScreen(counter: counter + 5), .none)
            
        case (.modalScreen(let count), .increment):
            return (.modalScreen(counter: count + 1), .none)
            
        case (.modalScreen, .routeChanged(.landscape)):
            return (.landscapeScreen(text: "Modal after modal!", counter: 0), .none)
            
        case (.landscapeScreen, .routeChanged(.root)):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.landscapeScreen, .tick(_)):
            return (.landscapeScreen(text: "Tick tock!", counter: 0), .none)
            
        case (.landscapeScreen(let text, let count), .increment):
            return (.landscapeScreen(text: text, counter: count + 1), .none)
        
        case (.started(let date, _), .pong(let text)):
            print("PONG -> \(text)")
            return (.started(date: date, showAlert: true), .none)
            
        case (_, .pong(let text)):
            print("PONG -> \(text)")
            return (state, .none)
            
        default:
            return .none
            
        }
        
    }
    
    func view(for state: State) -> View {
        switch state {
            
        case .started(_, true):
            return View(
                navigator: .main,
                root: .stack(exampleNavigationBar(title: "Root")),
                alert: AlertProperties(
                    title: "Hello!",
                    text: "This is an alert",
                    button: AlertProperties<Action>.Button(title: "OK")
                )
            )
            
        case .started(let date, false):
            return View(
                navigator: .main,
                root: .stack(exampleNavigationBar(title: "Root")),
                component: container(
                    children: [
                        button(
                            text: "Replace content",
                            onTap: .sendMessage(.replaceContent),
                            style: buttonStyleSheet { base, button in
                                base.backgroundColor = .red
                                button.textColor = .white
                            },
                            layout: layout() {
                                $0.margin = .by(edge: edge() {
                                    $0.top = 30
                                })
                            }
                        ),
                        button(
                            text: "Present modal",
                            onTap: .navigate(to: .modal),
                            style: buttonStyleSheet { base, button in
                                base.backgroundColor = .green
                                button.textColor = .white
                            }
                        ),
                        button(
                            text: "Present detail",
                            onTap: .navigate(to: .detail),
                            style: buttonStyleSheet { base, button in
                                base.backgroundColor = .blue
                                button.textColor = .white
                            }
                        ),
                        button(
                            text: "Present modal landscape",
                            onTap: .navigate(to: .landscape),
                            style: buttonStyleSheet { base, button in
                                base.backgroundColor = .green
                                button.textColor = .white
                            }
                        ),
                        touchable(
                            gesture: .tap(message: .navigate(to: .modal)),
                            child: container(
                                children: [],
                                style: styleSheet() {
                                    $0.backgroundColor = .yellow
                                },
                                layout: layout() {
                                    $0.width = Dimension(value: 50)
                                    $0.height = Dimension(value: 50)
                                }
                            )
                        ),
                        label(text: date?.description ?? "Unknown date"),
                        segmented(
                            segments: ZipList(
                                left: [segment(title: "First", onTap: .sendMessage(.pong("First")))],
                                center: segment(title: "Second", onTap: .sendMessage(.pong("Second"))),
                                right: [segment(title: "Third", onTap: .sendMessage(.pong("Third")))]
                            )
                        ),
                        myCustomComponent(layout: layout() {
                            $0.width = Dimension(value: 100)
                            $0.height = Dimension(value: 100)
                        })
                    ],
                    style: styleSheet() {
                        $0.backgroundColor = .gray
                    },
                    layout: layout() {
                        $0.flex = flex() {
                            $0.grow = .one
                        }
                    }
                )
            )
            
        case .replacedContent:
            return View(
                navigator: .main,
                root: .stack(exampleNavigationBar(title: "Root")),
                component: container(
                    children: [
                        label(text: "Button pressed"),
                        button(
                            text: "Go back",
                            onTap: .sendMessage(.goToRoot),
                            style: buttonStyleSheet { base, button in
                                base.backgroundColor = .green
                                button.textColor = .white
                            }
                        )
                    ],
                    style: styleSheet() {
                        $0.backgroundColor = .red
                    },
                    layout: layout() {
                        $0.flex = flex() {
                            $0.grow = .one
                        }
                    }
                )
            )
            
            
        case .detailedScreen(let counter):
            return View(
                navigator: .main,
                root: .stack(exampleNavigationBar(title: "Detail")),
                component: container(
                    children: [
                        button(text: "Go back!", onTap: .navigateToPreviousRoute(preformTransition: true)),
                        label(text: "Count \(counter)"),
                        button(text: "Increment!", onTap: .sendMessage(.increment)),
                        label(text: "Detail screen!")
                    ],
                    style: styleSheet() {
                        $0.backgroundColor = .green
                    },
                    layout: layout() {
                        $0.flex = flex() {
                            $0.grow = .one
                        }
                        $0.justifyContent = .flexEnd
                    }
                )
            )
            
        case .modalScreen(let counter):
            let modalButtonStyleSheet = buttonStyleSheet { base, button in
                base.backgroundColor = .green
                button.textColor = .white
            }
            return View(
                navigator: .modal,
                root: .stack(exampleNavigationBar(title: "Modal")),
                component: container(
                    children: [
                        label(text: "Modal screen"),
                        button(
                            text: "Close and present detail",
                            onTap: .dismissNavigator(thenSend: .navigate(to: .detail)),
                            style: modalButtonStyleSheet
                        ),
                        button(
                            text: "Close",
                            onTap: .dismissNavigator(thenSend: .none),
                            style: modalButtonStyleSheet
                        ),
                        label(text: "Counter \(counter)"),
                        button(
                            text: "Increment!",
                            onTap: .sendMessage(.increment),
                            style: modalButtonStyleSheet
                        ),
                        button(
                            text: "Present modal landscape",
                            onTap: .navigate(to: .landscape),
                            style: buttonStyleSheet { base, button in
                                base.backgroundColor = .green
                                button.textColor = .white
                            }
                        ),
                    ],
                    style: styleSheet() {
                        $0.backgroundColor = .red
                    },
                    layout: layout() {
                        $0.flex = flex() {
                            $0.grow = .one
                        }
                    }
                )
            )
            
        case .landscapeScreen(let text, let count):
            let modalButtonStyleSheet = buttonStyleSheet { base, button in
                base.backgroundColor = .green
                button.textColor = .white
            }
            return View(
                navigator: .other,
                root: .simple,
                orientation: .landscape,
                component: container(
                    children: [
                        button(
                            text: "Close",
                            onTap: .dismissNavigator(thenSend: .none),
                            style: modalButtonStyleSheet
                        ),
                        button(
                            text: "Increment!",
                            onTap: .sendMessage(.increment),
                            style: modalButtonStyleSheet
                        ),
                        label(text: text),
                        label(text: "Count \(count)")
                    ],
                    style: styleSheet() {
                        $0.backgroundColor = .red
                    },
                    layout: layout() {
                        $0.flex = flex() {
                            $0.grow = .one
                        }
                    }
                )
            )
            
        default:
            return View(
                navigator: .main,
                root: .simple,
                component: container(
                    children: [],
                    style: styleSheet() {
                        $0.backgroundColor = .red
                    },
                    layout: layout() {
                        $0.flex = flex() {
                            $0.grow = .one
                        }
                    }
                )
            )
            
        }
    }
    
    func subscriptions(for state: State) -> [Subscription] {
        switch state {
        case .started:
            return [
                .timer(.only(fire: 3, every: 1, unit: .second, tag: "Main") { .sendMessage(.tick($0)) })
            ]
        case .detailedScreen:
            return [
                .timer(.only(fire: 3, every: 1, unit: .second, tag: "Main") { .sendMessage(.tick($0)) }),
                .timer(.only(fire: 10, every: 1, unit: .second, tag: "Detail") { .sendMessage(.ping($0)) })
            ]
//        case .landscapeScreen:
//            return [
//                .timer(.only(fire: 1, every: 1, unit: .millisecond, tag: "BUG!") { .sendMessage(.tick($0)) })
//            ]
        case .modalScreen:
            return [
                .timer(.only(fire: 10, every: 1, unit: .second, tag: "BUG2!") { _ in .sendMessage(.increment) })
            ]
        default:
            return []
        }
    }
    
    fileprivate func exampleNavigationBar(title: String) -> NavigationBar<Action> {
        return navigationBar(
            properties: properties() {
                $0.title = .text(title)
                $0.hideBackButtonTitle = false
                $0.onBack = .navigateToPreviousRoute(preformTransition: false)
                $0.rightButtonItems = [
                    .textButton(title: "Hello", onTap: .sendMessage(.pong("Hello!"))),
                ]
            },
            style: navigationBarStyleSheet(){ base, navBar in
                navBar.titleTextColor = .red
                navBar.isTranslucent = false
                navBar.tintColor = .red
                base.backgroundColor = .white
            }
        )
    }
    
}

final class CustomComponentRenderer: UIKitCustomComponentRenderer {
    
    init(container: UIViewController) {
        print("Creating custom renderer")
    }
    
    func renderComponent(withIdentifier identifier: String, inside view: UIView, dispatcher: (ExampleApplication.Action) -> Void) {
        guard identifier == "MyCustomComponent" else { return }
        
        let bundle = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)
        if let customView = bundle?.last as? UIView {
            view.addSubview(customView)
            customView.frame.origin = .zero
            customView.frame.size = view.frame.size
        }
    }
    
}

func myCustomComponent(layout: Layout) -> Component<ExampleApplication.Action> {
    return .custom(componentIdentifier: "MyCustomComponent", layout: layout)
}





final class ExampleSerializer: StatePersistorSerializer {

    func serialize(state: State) -> Data {
        let name: String
        let properties: [String : Any?]?
        
        switch state {
        case .uninitialized:
            name = "uninitialized"
            properties = .none
            
        case .started(let date, let showAlert):
            name = "started"
            properties = [
                "date": date,
                "showAlert": showAlert
            ]
            
        case .replacedContent:
            name = "replacedContent"
            properties = .none
            
        case .detailedScreen(let counter):
            name = "detailedScreen"
            properties = ["counter" : counter]
        
        case .modalScreen:
            name = "modalScreen"
            properties = .none
        
        case .landscapeScreen:
            name = "landscapeScreen"
            properties = .none
            
        }
        
        let json: [String: Any?] = ["name": name, "properties": properties]
        return (try? JSONSerialization.data(withJSONObject: json, options: [])) ?? Data()
    }
    
    func serialize(message: Message) -> Data {
        let json: [String : Any?]
        switch message {
        case .applicationStarted:
            json = ["applicationStarted": ""]
        case .replaceContent:
            json = ["replaceContent": ""]
        case .goToRoot:
            json = ["goToRoot": ""]
        case .routeChanged(let route):
            let value: Int
            switch route {
            case .root: value = 0
            case .modal: value = 1
            case .detail: value = 2
            case .landscape: value = 3
            }
            json = ["routeChanged": value]
        case .increment:
            json = ["increment": ""]
        case .tick(let date):
            json = ["tick": date.timeIntervalSinceReferenceDate]
        case .ping(let date):
            json = ["ping": date.timeIntervalSinceReferenceDate]
        case .pong(let string):
            json = ["pong": string]
        case .stateLoaded(_):
            json = ["unsupported" : .none]
        }
        return (try? JSONSerialization.data(withJSONObject: json, options: [])) ?? Data()
    }
    
    func deserializeState(from data: Data) -> State? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any?] else {
            return .none
        }
        
        switch (json?["name"] as? String) {
            
        case .some("uninitialized"):
            return .uninitialized
            
        case .some("started"):
            let properties = json?["properties"] as? [String : Any?]
            if let date = properties?["date"] as? Date, let showAlert = properties?["showAlert"] as? Bool {
                return .started(date: date, showAlert: showAlert)
            } else {
                return .none
            }
            
        case .some("replacedContent"):
            return .replacedContent
            
        case .some("detailedScreen"):
            let properties = json?["properties"] as? [String : Any?]
            if let counter = properties?["counter"] as? UInt {
                return .detailedScreen(counter: counter)
            } else {
                return .none
            }
            
        case .some("modalScreen"):
            return .modalScreen(counter: 0)
            
        case .some("landscapeScreen"):
            return .landscapeScreen(text: "Came from the other side!", counter: 0)
            
        default:
            return .none
        }
    }
    
    func deserializeMessage(from data: Data) -> Message? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any?] else {
            return .none
        }
        
        switch json?.keys.first {
        
        case .some("applicationStarted"):
            return .applicationStarted
            
        case .some("replaceContent"):
            return .replaceContent
            
        case .some("goToRoot"):
            return .goToRoot
            
        case .some("routeChanged"):
            switch json?.values.first as? Int {
            case .some(0): return .routeChanged(to: .root)
            case .some(1): return .routeChanged(to: .modal)
            case .some(2): return .routeChanged(to: .detail)
            default: return .none
            }
            
        case .some("increment"):
            return .increment
            
        case .some("tick"):
            if let date = json?.values.first as? TimeInterval {
                return .tick(Date(timeIntervalSinceReferenceDate: date))
            } else {
                return .none
            }
            
        case .some("ping"):
            if let date = json?.values.first as? TimeInterval {
                return .ping(Date(timeIntervalSinceReferenceDate: date))
            } else {
                return .none
            }
            
        case .some("pong"):
            if let string = json?.values.first as? String {
                return .pong(string)
            } else {
                return .none
            }
        
        default:
            return .none
        }
    }
    
}

