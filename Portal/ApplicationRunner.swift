
//  ApplicationRunner.swift
//  Portal
//
//  Created by Guido Marucci Blas on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

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
    fileprivate typealias ScreenTransition = (@escaping ScreenTransitionCompletion) -> Void
    fileprivate typealias ScreenTransitionCompletion = () -> Void
    
    public var log: (String) -> Void = { print($0) }
    
    fileprivate let application: ApplicationType
    fileprivate var renderer: ApplicationRendererType?
    fileprivate let commandExecutor: CommandExecutorType
    fileprivate var currentState: StateType
    fileprivate var navigationState: NavigationStateType?
    fileprivate var middlewares: [Middleware]
    fileprivate var subscriptionsManager: SubscriptionsManager<RouteType, MessageType, CustomSubscriptionManager>?
    fileprivate let dispatchQueue = ExecutionQueue()
    
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
        dispatchQueue.enqueue { self.serialDispatch(action: action) }
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
                // When dismissing a navigator we need to stop
                // processing messages until the view transition
                // has been executed to avoid modifying the view
                // in the middle of an animation / transition.
                //
                // By using the `performTransition` method
                // we are wrapping the method that performs the
                // view transition inside a scope that suspend / resumes
                // operations enqueued in the dispatch queue.
                //
                // In this case we need to make sure that `handleNavigatorDismissal`
                // is executed before any other operation that could be waiting for
                // execution inside the dispatch queue.
                let dismissCurrentNavigator = performTransition(renderer?.dismissCurrentNavigator)
                dismissCurrentNavigator {
                    self.handleNavigatorDismissal(from: navigationState, to: nextNavigationState, action: maybeAction)
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
                    // When rewinding a navigator we need to stop
                    // processing messages until the view transition
                    // has been executed to avoid modifying the view
                    // in the middle of an animation / transition.
                    //
                    // By using the `performTransition` method
                    // we are wrapping the method that performs the
                    // view transition inside a scope that suspend / resumes
                    // operations enqueued in the dispatch queue.
                    //
                    // In this case we need to make sure that `rewindCurrentNavigator`
                    // is executed before any other operation that could be waiting for
                    // execution inside the dispatch queue.
                    let rewindCurrentNavigator = self.performTransition(renderer?.rewindCurrentNavigator)
                    rewindCurrentNavigator(handleChangeToPreviousRoute)
                } else {
                    // If we are not perfoming the transition we can assume that `navigateToPreviousRoute`
                    // was dispatched by PortalNavigationController when the back button was pressed while
                    // the pop transition is being executed.
                    //
                    // Because there is no way to know in advance that a controller will be poped (by the time
                    // UIKit notifies that a controller will be presented the animation is already in progress) we 
                    // cannot avoid handling messages that may want to update a view that is being poped. But it is
                    // not a big issue because by the time this message is handled the transtion was executed and
                    // view update executed during the transition are ignored by the renderer.
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
            // When presenting an alert we need to stop
            // processing messages until the view transition
            // has been executed to avoid modifying the view
            // in the middle of an animation / transition.
            //
            // By using the `executeRendererTransition` method
            // we are wrapping the method that performs the
            // view transition inside a scope that suspend / resumes
            // operations enqueued in the dispatch queue.
            executeRendererTransition { renderer, completion in
                renderer.present(alert: properties, completion: completion)
            }
            
        case .component(let component):
            self.renderer?.render(component: component, with: view.root, orientation: view.orientation)
            
        }
    }
    
    fileprivate func present(view: ViewType, modally: Bool) {
        // When presenting a new view we need to stop
        // processing messages until the view transition
        // has been executed to avoid modifying the view
        // in the middle of an animation / transition.
        //
        // By using the `executeRendererTransition` method
        // we are wrapping the method that performs the
        // view transition inside a scope that suspend / resumes
        // operations enqueued in the dispatch queue.
        switch view.content {
            
        case .alert(let properties):
            executeRendererTransition { renderer, completion in
                renderer.present(alert: properties, completion: completion)
            }
            
        case .component(let component):
            executeRendererTransition { renderer, completion in
                renderer.present(
                    component: component,
                    with: view.root,
                    modally: modally,
                    orientation: view.orientation,
                    completion: completion
                )
            }
            
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
            // We need to update the application runner's navigation state
            // to the intermidiate navigation state in order to handle navigator
            // changes acoordindly. For example, this means that if the initial
            // navigation state was the main navigator, then the user presented
            // a modal screen by changing the navigator. When the user sends an
            // action to dismiss the current navigator and then navigate to a route
            // that has an associated view that will result in pushing a view into the main 
            // navigator which happens to have a stack root component, then we need to make
            // sure that the current navigator reflects the 'back' transition in order for the internal
            // presentation mechanisim to work properly. 
            //
            // Otherwise, if we don't update the internal navigation state, the application 
            // runner would think that we are still in a navigation state that is showing a modal and 
            // when the application's view function returns a view that was intended to be pushed to 
            // the navigation stack, because navigators won't match, the view will be presented 
            // as a modal instead of being pushed to the navigation stack associated with the maim navigator.
            //
            // Because `handleNavigatorDismissal` needs to be executed as an 
            // out of band operation in the dispatch queue we can `serialDispatch`
            // directly without having to enqueue any work.
            navigationState = nextNavigationState
            self.serialDispatch(action: .navigate(to: nextRoute))
        } else {
            handleRouteChange(from: currentNavigationState.currentRoute, to: nextNavigationState.currentRoute) { view, nextState in
                self.currentState = nextState
                self.navigationState = nextNavigationState
                
                self.render(view: view)
                
                if let action = action {
                    self.dispatch(action: action)
                }
            }
        }
    }
    
    fileprivate func executeRendererTransition(_ transition: (ApplicationRendererType, @escaping ScreenTransitionCompletion) -> Void) {
        guard let renderer = self.renderer else { return }
        
        dispatchQueue.suspend()
        transition(renderer, {
            self.dispatchQueue.resume()
        })
    }
    
    fileprivate func performTransition(_ maybeTransition: ScreenTransition?) -> (@escaping ScreenTransitionCompletion) -> Void {
        guard let transition = maybeTransition else { return { _ in } }
        
        return { completion in
            self.dispatchQueue.suspend()
            transition({
                self.dispatchQueue.resume(with: completion)
            })
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

fileprivate final class ExecutionQueue {
    
    private let queue = DispatchQueue(label: "me.guidomb.Portal.ApplicationQueue")
    private var outOfBandOperation: (() -> Void)? = .none
    private var operationsCount: UInt = 0
    
    func suspend() {
        queue.suspend()
    }
    
    func resume(with outOfBandOperation: (() -> Void)? = .none) {
        
        switch (self.outOfBandOperation, outOfBandOperation) {
        case (.some(let previousOutOfBandOperation), .some(let currentOutOfBandOperation)):
            self.outOfBandOperation = {
                currentOutOfBandOperation()
                previousOutOfBandOperation()
            }
        case (.none, .some(let currentOutOfBandOperation)):
            self.outOfBandOperation = currentOutOfBandOperation
        default:
            break
        }
        
        if operationsCount == 0 && self.outOfBandOperation != nil {
            enqueue(operation: {})
        }
        
        queue.resume()
    }
    
    func enqueue(operation: @escaping () -> Void) {
        operationsCount += 1
        queue.async {
            self.operationsCount -= 1
            if let oobo = self.outOfBandOperation {
                oobo()
                self.outOfBandOperation = .none
            }
            operation()
        }
    }
    
}

