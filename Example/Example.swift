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
            return (.started(date: .none, showAlert: false), .none)
            
        // MARK:- Started state transitions
            
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
            
        case (.started(let date, _), .pong(let text)):
            print("PONG -> \(text)")
            return (.started(date: date, showAlert: true), .none)
            
        // MARK:- Replaced content state transitions
            
        case (.replacedContent, .goToRoot):
            return (.started(date: .none, showAlert: false), .none)
            
        // MARK:- Detailed screen state transitions
            
        case (.detailedScreen, .routeChanged(.root)):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.detailedScreen(let counter), .increment):
            return (.detailedScreen(counter: counter + 1), .none)
            
        case (.detailedScreen(let counter), .ping(_)):
            return (.detailedScreen(counter: counter + 1), .none)
            
        case (.modalScreen, .routeChanged(.root)):
            return (.started(date: .none, showAlert: false), .none)
            
        // MARK:- Modal screen state transitions
            
        case (.modalScreen(let counter), .routeChanged(.detail)):
            return (.detailedScreen(counter: counter + 5), .none)
            
        case (.modalScreen(let count), .increment):
            return (.modalScreen(counter: count + 1), .none)
            
        case (.modalScreen, .routeChanged(.landscape)):
            return (.landscapeScreen(text: "Modal after modal!", counter: 0), .none)
            
        // MARK:- Landscape screen state transitions
            
        case (.landscapeScreen, .routeChanged(.root)):
            return (.started(date: .none, showAlert: false), .none)
            
        case (.landscapeScreen, .tick(_)):
            return (.landscapeScreen(text: "Tick tock!", counter: 0), .none)
            
        case (.landscapeScreen(let text, let count), .increment):
            return (.landscapeScreen(text: text, counter: count + 1), .none)
            
        // MARK:- Miscelaneus state transitions
            
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
                .timer(.only(fire: 3, every: 1, unit: .second, tag: "Main timer") { .sendMessage(.tick($0)) })
            ]
        case .detailedScreen:
            return [
                .timer(.only(fire: 3, every: 1, unit: .second, tag: "Main timer") { .sendMessage(.tick($0)) }),
                .timer(.only(fire: 10, every: 1, unit: .second, tag: "Detail timer") { .sendMessage(.ping($0)) })
            ]
        case .landscapeScreen:
            return [
                .timer(.only(fire: 1, every: 1, unit: .millisecond, tag: "Landscape timer") { .sendMessage(.tick($0)) })
            ]
        case .modalScreen:
            return [
                .timer(.only(fire: 10, every: 1, unit: .second, tag: "Modal timer") { _ in .sendMessage(.increment) })
            ]
        default:
            return []
        }
    }
    
}
