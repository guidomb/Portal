//
//  Application.swift
//  PortalApplication
//
//  Created by Guido Marucci Blas on 3/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation
import PortalView

public protocol Route: Equatable {
    
    var previous: Self? { get }
    
}

public protocol Navigator: Equatable {
    
    associatedtype RouteType: Route
    
    var baseRoute: RouteType { get }
    
}

public indirect enum Action<RouteType: Route, MessageType> {

    case dismissNavigator(thenSend: Action<RouteType, MessageType>?)
    case navigateToPreviousRoute(preformTransition: Bool)
    case navigate(to: RouteType)
    case sendMessage(MessageType)
    
}

public struct AlertProperties<MessageType> {
    
    public struct Button {
        
        let title: String
        let onTap: MessageType?
        
        public init(title: String, onTap: MessageType? = .none) {
            self.title = title
            self.onTap = onTap
        }
        
    }
    
    public let title: String
    public let text: String
    public let buttons: [Button]
    
    private init(title: String, text: String, buttons: [Button]) {
        self.title = title
        self.text = text
        self.buttons = buttons
    }
    
    public init(title: String, text: String, button: Button) {
        self.init(title: title, text: text, buttons: [button])
    }
    
    public init(title: String, text: String, primary: Button, secondary: Button) {
        self.init(title: title, text: text, buttons: [primary, secondary])
    }
    
}

public struct View<RouteType: Route, MessageType, NavigatorType: Navigator> {
    // TODO declare Navigator constrain when proposal 142 gets implemented
    // https://github.com/apple/swift-evolution/blob/master/proposals/0142-associated-types-constraints.md
    // where NavigatorType.RouteType == RouteType {
    
    public typealias ActionType = Action<RouteType, MessageType>
    
    public enum Content {
        
        case alert(properties: AlertProperties<ActionType>)
        case component(Component<ActionType>)
        
    }
    
    public let navigator: NavigatorType
    public let root: RootComponent<ActionType>
    public let content: Content

    public init(navigator: NavigatorType, root: RootComponent<ActionType>, component: Component<ActionType>) {
        self.init(navigator: navigator, root: root, content: .component(component))
    }
    
    public init(navigator: NavigatorType, root: RootComponent<ActionType>, alert properties: AlertProperties<ActionType>) {
        self.init(navigator: navigator, root: root, content: .alert(properties: properties))
    }
    
    internal init(navigator: NavigatorType, root: RootComponent<ActionType>, content: Content) {
        self.navigator = navigator
        self.root = root
        self.content = content
    }
    
}

public protocol Application {
    
    associatedtype MessageType
    associatedtype StateType
    associatedtype CommandType
    associatedtype RouteType: Route
    associatedtype SubscriptionType: Equatable
    
    // TODO declare Navigator constrain when proposal 142 gets implemented
    // https://github.com/apple/swift-evolution/blob/master/proposals/0142-associated-types-constraints.md
    // associatedtype NavigatorType: Navigator where NavigatorType.RouteType == RouteType
    associatedtype NavigatorType: Navigator
    
    var initialState: StateType { get }
    
    var initialRoute: RouteType { get }
    
    func translateRouteChange(from currentRoute: RouteType, to nextRoute: RouteType) -> MessageType?
    
    func update(state: StateType, message: MessageType) -> (StateType, CommandType?)?
    
    func view(for state: StateType) -> View<RouteType, MessageType, NavigatorType>
    
    func subscriptions(for state: StateType) -> [Subscription<MessageType, RouteType, SubscriptionType>]
    
}

extension Application {
    
    func subscriptions(for state: StateType) -> [Subscription<MessageType, RouteType, SubscriptionType>] {
        return []
    }
    
}

public protocol CommandExecutor {
    
    associatedtype CommandType
    associatedtype MessageType
    
    func execute(command: CommandType, dispatch: @escaping (MessageType) -> Void)
    
}

public protocol ApplicationRenderer {
    
    associatedtype MessageType
    associatedtype RouteType: Route
        
    func render(component: Component<Action<RouteType, MessageType>>, with root: RootComponent<Action<RouteType, MessageType>>)
    
    func present(component: Component<Action<RouteType, MessageType>>, with root: RootComponent<Action<RouteType, MessageType>>, modally: Bool)
    
    func present(alert: AlertProperties<Action<RouteType, MessageType>>)
    
    func dismissCurrentNavigator(completion: @escaping () -> Void)
    
    func rewindCurrentNavigator(completion: @escaping () -> Void)
    
}
