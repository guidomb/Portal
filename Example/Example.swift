//
//  Example.swift
//  Example
//
//  Created by Guido Marucci Blas on 3/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit
import Portal

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

enum Navigator: Equatable {
    
    case main
    case modal
    case other
    
}

enum Route: Portal.Route {
    
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

final class ExampleApplication: Portal.Application {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    typealias Subscription = Portal.Subscription<Message, Route, IgniteSubscription>
    
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
            return MainScreen.alert()
            
        case .started(let date, false):
            return MainScreen.mainView(date: date)
            
        case .replacedContent:
            return MainScreen.replacedContent()
            
        case .detailedScreen(let counter):
            return DetailScreen.view(counter: counter)
            
        case .modalScreen(let counter):
            return ModalScreen.view(counter: counter)
            
        case .landscapeScreen(let text, let count):
            return LandscapeScreen.view(text: text, count: count)
            
        default:
            return DefaultScreen.view()
            
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
        case .landscapeScreen:
            return [
                .timer(.only(fire: 1, every: 1, unit: .millisecond, tag: "BUG!") { .sendMessage(.tick($0)) })
            ]
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
                $0.rightButtonItems = [
                    .textButton(title: "Hello", onTap: .sendMessage(.pong("Hello!"))),
                ]
            },
            style: navigationBarStyleSheet(){ base, navBar in
                navBar.titleTextColor = .red
                navBar.isTranslucent = false
                navBar.tintColor = .red
                navBar.separatorHidden = true
                base.backgroundColor = .white
            }
        )
    }
    
}

final class CustomComponentRenderer: UIKitCustomComponentRenderer {
    
    typealias Action = Portal.Action<Route, Message>
    
    static private var cachedController: CustomController?
    
    private let container: ContainerController
    
    init(container: ContainerController) {
        print("Creating custom renderer")
        self.container = container
    }
    
    public func renderComponent(_ componentDescription: CustomComponentDescription, inside view: UIView, dispatcher: @escaping (Action) -> Void) {
        guard componentDescription.identifier == "MyCustomComponent" || componentDescription.identifier == "MyCustomComponent2" else { return }
        
        if componentDescription.identifier == "MyCustomComponent" {
            print("Rendering MyCustomComponent")
            let bundle = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)
            if let customView = bundle?.last as? CustomView {
                customView.onTap = { dispatcher(.sendMessage(.increment)) }
                customView.frame = CGRect(origin: .zero, size: view.frame.size)
                view.addSubview(customView)
            }
        } else {
            print("Rendering MyCustomComponent2")
            if let cachedController = CustomComponentRenderer.cachedController {
                print("Using cached version of the custom controller")
                cachedController.onTap = { dispatcher(.sendMessage(.increment)) }
                view.addSubview(cachedController.view)
            } else {
                print("Creating new instance of custom controller")
                let frame = CGRect(origin: .zero, size: view.frame.size)
                let controller = CustomController(frame: frame, onTap: { dispatcher(.sendMessage(.increment)) })
                container.attachChildController(controller)
                view.addSubview(controller.view)
                
                container.registerDisposer(for: "MyCustomComponent2") {
                    print("Removing custom controller cache")
                    CustomComponentRenderer.cachedController = .none
                }
                CustomComponentRenderer.cachedController = controller
            }
        }
    }
    
}

func myCustomComponent(layout: Layout) -> Component<ExampleApplication.Action> {
    return .custom(CustomComponent(identifier: "MyCustomComponent"), EmptyStyleSheet.default, layout)
}

func myCustomComponent2(layout: Layout) -> Component<ExampleApplication.Action> {
    return .custom(CustomComponent(identifier: "MyCustomComponent"),  EmptyStyleSheet.default, layout)
}

final class CustomController: UIViewController {

    private let frame: CGRect
    private var _onTap: () -> Void
    
    var onTap: () -> Void {
        set {
            self._onTap = newValue
            (self.view as? CustomView)?.onTap = newValue
        }
        get {
            return _onTap
        }
    }
    
    init(frame: CGRect, onTap: @escaping () -> Void) {
        self.frame = frame
        self._onTap = onTap
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let bundle = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)
        if let customView = bundle?.last as? CustomView {
            customView.onTap = self.onTap
            customView.frame = self.frame
            self.view = customView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Custom controller will appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Custom controller did appear")
    }
    
    deinit {
        print("Killing custom controller")
    }
    
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

