//
//  Application.swift
//  Portal
//
//  Created by Guido Marucci Blas on 3/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public protocol Route: Equatable {
    
    var previous: Self? { get }
    
}

public indirect enum Action<RouteType: Route, MessageType> {

    case dismissNavigator(thenSend: Action<RouteType, MessageType>?)
    case navigateToPreviousRoute
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

public struct View<RouteType: Route, MessageType, NavigatorType: Equatable> {
    
    public typealias ActionType = Action<RouteType, MessageType>
    
    public enum Content {
        
        case alert(properties: AlertProperties<ActionType>)
        case component(Component<ActionType>)
        
    }
    
    public let navigator: NavigatorType
    public let root: RootComponent<ActionType>
    public let content: Content
    public var orientation: SupportedOrientations = .all
    
    public init(navigator: NavigatorType, root: RootComponent<ActionType>, orientation: SupportedOrientations = .portrait, component: Component<ActionType>) {
        self.init(navigator: navigator, root: root, orientation: orientation, content: .component(component))
    }
    
    public init(navigator: NavigatorType, root: RootComponent<ActionType>,  orientation: SupportedOrientations = .portrait, alert properties: AlertProperties<ActionType>) {
        self.init(navigator: navigator, root: root, orientation: orientation, content: .alert(properties: properties))
    }
    
    internal init(navigator: NavigatorType, root: RootComponent<ActionType>, orientation: SupportedOrientations = .portrait, content: Content) {
        self.navigator = navigator
        self.root = root
        self.content = content
        self.orientation = orientation
    }
    
}

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
    associatedtype NavigatorType: Equatable
    
    typealias ViewType = View<RouteType, MessageType, NavigatorType>
    typealias ActionType = Action<RouteType, MessageType>
    
    var mailbox: Mailbox<ActionType> { get }
    
    func render(view: ViewType, completion: @escaping () -> Void)
    
    func present(view: ViewType, completion: @escaping () -> Void)
    
    func presentModal(view: ViewType, completion: @escaping () -> Void)
    
    func dismissCurrentNavigator(completion: @escaping () -> Void)
    
    func rewindCurrentNavigator(completion: @escaping () -> Void)
    
}

internal enum InternalAction<RouteType: Route, MessageType> {

    case navigateToPreviousRouteAfterPop
    case action(Action<RouteType, MessageType>)
    
}
