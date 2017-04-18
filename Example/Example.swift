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
    
}

enum Command {
    
}

enum Navigator: PortalApplication.Navigator {
    
    case main
    case modal
    
    var baseRoute: Route {
        switch self {
        case .main:
            return .root
        case .modal:
            return .modal
        }
    }
    
}

enum Route: PortalApplication.Route {
    
    case root
    case modal
    case detail
    
    var previous: Route? {
        switch self {
        case .root:
            return .none
        case .detail:
            return .root
        case .modal:
            return .root
        }
    }
    
}

enum State {
    
    case uninitialized
    case started(date: Date?, showAlert: Bool)
    case replacedContent
    case detailedScreen(counter: UInt)
    case modalScreen
    
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
    
    func execute(command: Command, dispatch: @escaping (ExampleApplication.Action) -> Void) {
        
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
            return (.started(date: .none, showAlert: false), .none)
            
        case (.started, .replaceContent):
            return (.replacedContent, .none)
            
        case (.started, .routeChanged(.modal)):
            return (.modalScreen, .none)
            
        case (.started, .routeChanged(.detail)):
            return (.detailedScreen(counter: 0), .none)
            
        case (.started, .tick(let date)):
            return (.started(date: date, showAlert: false), .none)
            
        case (.replacedContent, .goToRoot):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.detailedScreen, .routeChanged(.root)):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.detailedScreen(let counter), .increment):
            return (.detailedScreen(counter: counter + 1), .none)
            
        case (.modalScreen, .routeChanged(.root)):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.modalScreen, .routeChanged(.detail)):
            return (.detailedScreen(counter: 10), .none)
        
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
            
        case .modalScreen:
            return View(
                navigator: .modal,
                root: .simple,
                component: container(
                    children: [
                        label(text: "Modal screen"),
                        button(
                            text: "Close and present detail",
                            onTap: .dismissNavigator(thenSend: .navigate(to: .detail)),
                            style: buttonStyleSheet { base, button in
                                base.backgroundColor = .green
                                button.textColor = .white
                            }
                        ),
                        button(
                            text: "Close",
                            onTap: .dismissNavigator(thenSend: .none),
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
    
    func handleInitialization(of parentController: UIViewController, forComponent componentIdentifier: String) {
        print("Handle initialization of parent controller for component '\(componentIdentifier)'")
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

