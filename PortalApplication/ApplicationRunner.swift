
//  ApplicationRunner.swift
//  PortalApplication
//
//  Created by Guido Marucci Blas on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation
import PortalView

public class ApplicationRunner<
    StateType,
    MessageType,
    CommandType,
    CustomSubscriptionType: Equatable,
    RouteType: Route,
    NavigatorType: Navigator,
    ApplicationType: Application,
    ApplicationRendererType: ApplicationRenderer,
    CommandExecutorType: CommandExecutor,
    CustomSubscriptionManager: SubscriptionManager>
    
    where
    
    ApplicationType.StateType                   == StateType,
    ApplicationType.MessageType                 == MessageType,
    ApplicationType.CommandType                 == CommandType,
    ApplicationType.RouteType                   == RouteType,
    ApplicationType.NavigatorType               == NavigatorType,
    ApplicationType.SubscriptionType            == CustomSubscriptionType,
    NavigatorType.RouteType                     == RouteType,
    ApplicationRendererType.MessageType         == MessageType,
    ApplicationRendererType.RouteType           == RouteType,
    CommandExecutorType.MessageType             == Action<RouteType, MessageType>,
    CommandExecutorType.CommandType             == CommandType,
    CustomSubscriptionManager.SubscriptionType  == CustomSubscriptionType,
    CustomSubscriptionManager.RouteType         == RouteType,
    CustomSubscriptionManager.MessageType       == MessageType {
    
    public typealias Transition = (StateType, CommandType?)?
    public typealias NextMiddleware = (StateType, MessageType, CommandType?) -> Transition
    public typealias Middleware = (StateType, MessageType, CommandType?, NextMiddleware) -> Transition
    public typealias ActionType = Action<RouteType, MessageType>
    public typealias ViewType = View<RouteType, MessageType, NavigatorType>
    public typealias DispatcherFactory = (@escaping (ActionType) -> Void) -> ApplicationRendererType

    fileprivate typealias NavigationStateType = NavigationState<RouteType, NavigatorType>
    
    public var log: (String) -> Void = { print($0) }
    
    fileprivate let application: ApplicationType
    fileprivate var renderer: ApplicationRendererType?
    fileprivate let commandExecutor: CommandExecutorType
    fileprivate var currentState: StateType
    fileprivate var navigationState: NavigationStateType?
    fileprivate var middlewares: [Middleware]
    fileprivate var subscriptionsManager: SubscriptionsManager<RouteType, MessageType, CustomSubscriptionManager>?
    fileprivate let dispatchQueue = DispatchQueue(label: "com.syrmo.Portal.ApplicationQueue")
    
    public init(
        application: ApplicationType,
        commandExecutor: CommandExecutorType,
        subscriptionManager: CustomSubscriptionManager,
        rendererFactory: DispatcherFactory) {
        
        self.application = application
        self.commandExecutor = commandExecutor
        self.currentState = application.initialState
        self.middlewares = [{ (s, m, _, _) in application.update(state: s, message: m) }]
        self.subscriptionsManager = SubscriptionsManager(subscriptionManager: subscriptionManager) { [unowned self] in self.dispatch(action: $0) }
        self.renderer = rendererFactory { [unowned self] in self.dispatch(action: $0) }
    }
    
    public final func dispatch(action: ActionType) {
        dispatchQueue.async { self.serialDispatch(action: action) }
    }
    
    public final func execute(command: CommandType) {
        commandExecutor.execute(command: command) { [unowned self] in self.dispatch(action: $0) }
    }
    
    public func registerMiddleware(_ middleware: @escaping Middleware) {
        middlewares.append(middleware)
    }
    
}

internal extension ApplicationRunner {
    
    internal final func serialDispatch(action: ActionType) {
        switch (action, navigationState) {
            
        case (.dismissNavigator(let maybeAction), .some(let navigationState)):
            if let nextNavigationState = navigationState.dismissCurrentNavigator() {
                renderer?.dismissCurrentNavigator {
                    self.dispatchQueue.sync {
                        self.handleNavigatorDismissal(from: navigationState, to: nextNavigationState, action: maybeAction)
                    }
                }
            } else {
                log("Cannot dismiss root navigator")
            }
            
        case (.navigateToPreviousRoute(let performTransition), .some(let navigationState)):
            if let previousRoute = navigationState.currentRoute.previous {
                func handleChangeToPreviousRoute() {
                    handleRouteChange(from: navigationState.currentRoute, to: previousRoute) { view, nextState in
                        self.currentState = nextState
                        self.navigationState = navigationState.navigate(to: previousRoute, using: view.navigator)
                        
                        render(view: view)
                    }
                }
                
                if performTransition {
                    renderer?.rewindCurrentNavigator { self.dispatchQueue.sync(execute: handleChangeToPreviousRoute) }
                } else {
                    handleChangeToPreviousRoute()
                }
            } else {
                log("Cannot change to previous route because there isn't one for current route '\(navigationState.currentRoute)'")
            }
            
        case (.navigate(to: let nextRoute), .some(let navigationState)) where navigationState.currentRoute != nextRoute:
            handleRouteChange(from: navigationState.currentRoute, to: nextRoute) { view, nextState in
                self.currentState = nextState
                self.navigationState = navigationState.navigate(to: nextRoute, using: view.navigator)
                
                let modally = self.navigationState?.currentNavigator != navigationState.currentNavigator
                self.present(view: view, modally: modally)
            }
            
        case (.sendMessage(let message), .some(let navigationState)):
            handle(message: message) { view, nextState in
                if view.navigator == navigationState.currentNavigator {
                    self.currentState = nextState
                    render(view: view)
                } else {
                    self.log("Cannot render current view in a different navigator")
                }
            }
            
        case (.sendMessage(let message), .none):
            handle(message: message) { view, nextState in
                self.currentState = nextState
                self.navigationState = NavigationState(route: application.initialRoute, navigator: view.navigator)
                render(view: view)
            }
            
        case (_, .none):
            log("Cannot handle action '\(action)' if navigation state is not initialized")
            
        default:
            log("Unsupported action '\(action)'")
        }
        
    }
}

fileprivate extension ApplicationRunner {
    
    fileprivate func render(view: ViewType) {
        switch view.content {
            
        case .alert(let properties):
            self.renderer?.present(alert: properties)
            
        case .component(let component):
            self.renderer?.render(component: component, with: view.root, orientation: view.orientation)
            
        }
    }
    
    fileprivate func present(view: ViewType, modally: Bool) {
        switch view.content {
            
        case .alert(let properties):
            self.renderer?.present(alert: properties)
            
        case .component(let component):
            self.renderer?.present(component: component, with: view.root, modally: modally, orientation: view.orientation)
            
        }
    }
    
    fileprivate func handleRouteChange(from currentRoute: RouteType, to nextRoute: RouteType, updater:(ViewType, StateType) -> Void) {
        if let message = application.translateRouteChange(from: currentRoute, to: nextRoute) {
            handle(message: message, updater: updater)
        } else {
            log("Unsupported route '\(nextRoute)'")
        }
    }
    
    fileprivate func handle(message: MessageType, updater:(ViewType, StateType) -> Void) {
        if let (nextState, maybeCommand) = applyMiddlewares(for: message) {
            let view = application.view(for: nextState)
            
            updater(view, nextState)
            
            let nextSubscriptions = application.subscriptions(for: nextState)
            subscriptionsManager?.manage(subscriptions: nextSubscriptions)
            
            if let command = maybeCommand {
                execute(command: command)
            }
        } else {
            log("Unsupported message '\(message)' for state '\(currentState)'")
        }
    }
    
    fileprivate func applyMiddlewares(for message: MessageType) -> Transition {
        
        func recusivelyApply(_ state: StateType, _ message: MessageType, _ command: CommandType?, _ middlewares: [Middleware]) -> Transition {
            guard let middleware = middlewares.first else { return (state, command) }
            
            let remaining = Array(middlewares.dropFirst())
            guard let result = middleware(state, message, command, { recusivelyApply($0, $1, $2, remaining) }) else {
                return .none
            }
            
            return result
        }
        
        return recusivelyApply(currentState, message, .none, middlewares.reversed())
    }
    
    fileprivate func handleNavigatorDismissal(from currentNavigationState: NavigationStateType, to nextNavigationState: NavigationStateType, action: ActionType?) {
        // If the action that needs to be dispatched after the
        // navigator dismissal is a route change request, then we
        // don't make the application's update handle the intermidate
        // transition between the final route and the next navigation
        // state's route.
        if case .some(.navigate(let nextRoute)) = action {
            self.navigationState = nextNavigationState
            self.dispatch(action: .navigate(to: nextRoute))
        } else {
            self.handleRouteChange(from: currentNavigationState.currentRoute, to: nextNavigationState.currentRoute) { view, nextState in
                self.currentState = nextState
                self.navigationState = nextNavigationState
                
                self.render(view: view)
                
                if let action = action {
                    self.dispatch(action: action)
                }
            }
        }
    }
    
}

fileprivate struct NavigationState<RouteType: Route, NavigatorType: Navigator> {
    // TODO declare Navigator constrain when proposal 142 gets implemented
    // https://github.com/apple/swift-evolution/blob/master/proposals/0142-associated-types-constraints.md
    // where NavigatorType.RouteType == RouteType {
    
    private var rootNavigator: NavigatorType
    private var rootRoute: RouteType
    
    private var modalNavigator: NavigatorType?
    private var modalRoute: RouteType?
    
    var currentNavigator: NavigatorType {
        return modalNavigator ?? rootNavigator
    }
    
    var currentRoute: RouteType {
        return modalRoute ?? rootRoute
    }
    
    fileprivate init(route: RouteType, navigator: NavigatorType) {
        self.rootRoute = route
        self.rootNavigator = navigator
    }
    
    func dismissCurrentNavigator() -> NavigationState? {
        guard modalNavigator != nil else { return nil }
        
        var nextState = self
        nextState.modalRoute = .none
        nextState.modalNavigator = .none
        return nextState
    }
    
    func navigate(to nextRoute: RouteType, using navigator: NavigatorType) -> NavigationState {
        var nextState = self
        if currentNavigator != navigator {
            nextState.modalNavigator = navigator
        }
        
        if nextState.modalNavigator != nil {
            nextState.modalRoute = nextRoute
        } else {
            nextState.rootNavigator = navigator
            nextState.rootRoute = nextRoute
        }
        
        return nextState
    }
}
