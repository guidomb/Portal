//  ApplicationRunner.swift
//  Portal
//
//  Created by Guido Marucci Blas on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//
// swiftlint:disable file_length
import Foundation

public class ApplicationRunner<
    StateType,
    MessageType,
    CommandType,
    CustomSubscriptionType,
    RouteType,
    NavigatorType,
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
    ApplicationRendererType.MessageType         == MessageType,
    ApplicationRendererType.RouteType           == RouteType,
    ApplicationRendererType.NavigatorType       == NavigatorType,
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

    internal typealias InternalActionType = InternalAction<RouteType, MessageType>
    internal typealias DispatcherFactory = (@escaping (InternalActionType) -> Void) -> ApplicationRendererType

    fileprivate typealias NavigationStateType = NavigationState<RouteType, NavigatorType>
    fileprivate typealias ScreenTransition = (@escaping ScreenTransitionCompletion) -> Void
    fileprivate typealias ScreenTransitionCompletion = () -> Void
    fileprivate typealias RenderTransition = (ApplicationRendererType, @escaping ScreenTransitionCompletion) -> Void
    
    public var log: (String) -> Void = { print($0) }
    
    fileprivate let application: ApplicationType
    fileprivate var renderer: ApplicationRendererType?
    fileprivate let commandExecutor: CommandExecutorType
    fileprivate var currentState: StateType
    fileprivate var navigationState: NavigationStateType?
    fileprivate var middlewares: [Middleware]
    fileprivate var subscriptionsManager: SubscriptionsManager<RouteType, MessageType, CustomSubscriptionManager>?
    fileprivate let messageQueue = OperationQueue()
    
    internal init(
        application: ApplicationType,
        commandExecutor: CommandExecutorType,
        subscriptionManager: CustomSubscriptionManager,
        rendererFactory: DispatcherFactory) {
        
        self.application = application
        self.commandExecutor = commandExecutor
        self.currentState = application.initialState
        self.middlewares = [ { (state, message, _, _) in application.update(state: state, message: message) } ]
        self.subscriptionsManager = SubscriptionsManager(subscriptionManager: subscriptionManager) { [unowned self] in
            self.dispatch(action: $0)
        }
        self.renderer = rendererFactory { [unowned self] in self.internalDispatch(action: $0) }
        self.messageQueue.maxConcurrentOperationCount = 1
    }
    
    public final func dispatch(action: ActionType) {
        internalDispatch(action: .action(action))
    }
    
    public final func execute(command: CommandType) {
        commandExecutor.execute(command: command) { [unowned self] in self.dispatch(action: $0) }
    }
    
    public func registerMiddleware(_ middleware: @escaping Middleware) {
        middlewares.append(middleware)
    }
    
}

internal extension ApplicationRunner {
    
    internal final func internalDispatch(action: InternalActionType) {
        messageQueue.addOperation { self.serialDispatch(action: action) }
    }
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    internal final func serialDispatch(action: InternalActionType) {
        switch (action, navigationState) {
            
        case (.action(.dismissNavigator(let maybeAction)), .some(let navigationState)):
            if let nextNavigationState = navigationState.dismissCurrentNavigator() {
                // When dismissing a navigator we need to stop processing messages until the view transition
                // has been executed to avoid modifying the view in the middle of an animation / transition.
                //
                // `performTransition` wraps the `dismissCurrentNavigator` method and adds all the boilerplate
                // logic to avoid sincronization issues
                let dismissCurrentNavigator = performTransition(renderer?.dismissCurrentNavigator)
                dismissCurrentNavigator {
                    // A this point `performTransition` has guaranteed that no other message was processed since
                    // the dismissal transition was executed and that this closure gets executed before any other
                    // message in the queue.
                    self.handleNavigatorDismissal(from: navigationState, to: nextNavigationState, action: maybeAction)
                }
            } else {
                log("Cannot dismiss root navigator")
            }
            
        case (.action(.navigateToPreviousRoute), .some(let navigationState)):
            guard let previousRoute = navigationState.currentRoute.previous else {
                log("Cannot change to previous route because there isn't one for " +
                    "current route '\(navigationState.currentRoute)'")
                return
            }
            
            // When navigating to a previous route we need to stop processing messages until the view transition
            // has been executed to avoid modifying the view in the middle of an animation / transition.
            //
            // `performTransition` wraps the `rewindCurrentNavigator` method and adds all the boilerplate
            // logic to avoid sincronization issues
            let rewindCurrentNavigator = self.performTransition(renderer?.rewindCurrentNavigator)
            rewindCurrentNavigator {
                // A this point `performTransition` has guaranteed that no other message was processed since
                // the dismissal transition was executed and that this closure gets executed before any other
                // message in the queue.
                self.handleRouteChange(from: navigationState.currentRoute, to: previousRoute) { view, nextState in
                    self.currentState = nextState
                    self.navigationState = navigationState.navigate(to: previousRoute, using: view.navigator)
                    
                    self.render(view: view)
                }
            }
            
        case (.action(.navigate(to: let nextRoute)), .some(let navigationState))
            where navigationState.currentRoute != nextRoute:
            handleRouteChange(from: navigationState.currentRoute, to: nextRoute) { view, nextState in
                self.currentState = nextState
                self.navigationState = navigationState.navigate(to: nextRoute, using: view.navigator)
                
                let modally = self.navigationState?.currentNavigator != navigationState.currentNavigator
                self.present(view: view, modally: modally)
            }
            
        case (.action(.sendMessage(let message)), .some(let navigationState)):
            handle(message: message) { view, nextState in
                if view.navigator == navigationState.currentNavigator {
                    self.currentState = nextState
                    render(view: view)
                } else {
                    self.log("Cannot render current view in a different navigator")
                }
            }
            
        case (.action(.sendMessage(let message)), .none):
            handle(message: message) { view, nextState in
                self.currentState = nextState
                self.navigationState = NavigationState(route: application.initialRoute, navigator: view.navigator)
                render(view: view)
            }
            
        // Handling internal actions from here on
            
        case (.navigateToPreviousRouteAfterPop, .some(let navigationState)):
            guard let previousRoute = navigationState.currentRoute.previous else {
                log("Cannot change to previous route because there isn't one " +
                    "for current route '\(navigationState.currentRoute)'")
                return
            }
    
            // `navigateToPreviousRouteAfterPop` is an internal action that can only be
            // dispatched by PortalNavigationController when the back button was pressed while
            // after the pop transition was executed.
            //
            // Because there is no way to know in advance that a controller will be poped (by the time
            // UIKit notifies that a controller will be presented the animation is already in progress) we
            // cannot avoid handling messages that may want to update a view that is being poped. But it is
            // not a big issue because by the time this message is handled the transtion was executed and
            // view update executed during the transition are ignored by the renderer.
            handleRouteChange(from: navigationState.currentRoute, to: previousRoute) { view, nextState in
                self.currentState = nextState
                self.navigationState = navigationState.navigate(to: previousRoute, using: view.navigator)
                
                render(view: view)
            }
        
        case (_, .none):
            log("Cannot handle action '\(action)' if navigation state is not initialized")
            
        default:
            log("Unsupported action '\(action)'")
        }
        
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}

fileprivate extension ApplicationRunner {
    
    fileprivate func render(view: ViewType) {
        executeRendererTransition { $0.render(view: view, completion: $1) }
    }
    
    fileprivate func present(view: ViewType, modally: Bool) {
        if modally {
            executeRendererTransition { $0.presentModal(view: view, completion: $1) }
        } else {
            executeRendererTransition { $0.present(view: view, completion: $1) }
        }
    }
    
    fileprivate func handleRouteChange(
        from currentRoute: RouteType,
        to nextRoute: RouteType,
        updater: (ViewType, StateType) -> Void) {
        if let message = application.translateRouteChange(from: currentRoute, to: nextRoute) {
            handle(message: message, updater: updater)
        } else {
            log("Unsupported route '\(nextRoute)'")
        }
    }
    
    fileprivate func handle(message: MessageType, updater: (ViewType, StateType) -> Void) {
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
        
        func recusivelyApply(
            _ state: StateType,
            _ message: MessageType,
            _ command: CommandType?,
            _ middlewares: [Middleware]) -> Transition {
            guard let middleware = middlewares.first else { return (state, command) }
            
            let remaining = Array(middlewares.dropFirst())
            guard let result = middleware(state, message, command, { recusivelyApply($0, $1, $2, remaining) }) else {
                return .none
            }
            
            return result
        }
        
        return recusivelyApply(currentState, message, .none, middlewares.reversed())
    }
    
    fileprivate func handleNavigatorDismissal(
        from currentNavigationState: NavigationStateType,
        to intermdiateNavigationState: NavigationStateType,
        action: ActionType?) {
        // If the action that needs to be dispatched after the
        // navigator dismissal is a route change request, then we
        // don't make the application's update handle the intermidate
        // transition between the final route and the next navigation
        // state's route.
        if case .some(.navigate(let nextRoute)) = action {
            // We use the final route, `nextRoute`, to get the final state and view
            // but we use the intermeidate navigation state to decide if the final
            // view needs to be presented modally or not.
            //
            // Take the following example:
            //
            //  Route .A has view with navigator X and root component .stack
            //  Route .B has view with navigator Y and root component .simple
            //  Route .C has view with navigator X and root component .stack
            //
            //  1. Application is in route A.
            //  2. User performs interaction that results in route changing to B.
            //  3. Because the view associated with route B has a different navigator than the view associated with
            //  route A, B's view is presented modally.
            //  4. User peforms interaction that sends action `dismissCurrentNavigator(andThen: .navigate(to: .C))`
            //  5. Modal is dismissed and the intermediate navigation state points to .A
            //  6. Because the intermidiate navigation state's navigator is equal to the navigator associated 
            //  with C's view and both A and C view have a .stack root component, C's view is pushed into the
            //  navigation stack.
            //  
            //  In this example the application's update function only needs to handle the following state and
            //  route transition:
            //
            //  A -> B
            //  B -> C
            //
            //  The intermediate transition A -> C does not need to be handled by the application's update
            //  function that the intermeidate navigation state is used here to decided how the final view (in
            //  this case C) is presented by comparing the intermediate navigation state's navigator with the
            //  final view's navigator (in this case A's navigator compared against C's navigator).
            //
            handleRouteChange(from: currentNavigationState.currentRoute, to: nextRoute) { view, nextState in
                let nextNavigationState = intermdiateNavigationState.navigate(to: nextRoute, using: view.navigator)
                self.currentState = nextState
                self.navigationState = nextNavigationState
                
                let modally = intermdiateNavigationState.currentNavigator != nextNavigationState.currentNavigator
                self.present(view: view, modally: modally)
            }
        } else {
            handleRouteChange(
                from: currentNavigationState.currentRoute,
                to: intermdiateNavigationState.currentRoute) { view, nextState in
                    
                self.currentState = nextState
                self.navigationState = intermdiateNavigationState
                
                self.render(view: view)
                
                // We dispatch the actio in-place without going through the
                // dispatch queue to make sure that this action in handled during
                // this update cycle without processing any other messages that
                // could have arrived during the transition.
                action |> { serialDispatch(action: .action($0)) }
            }
        }
    }
    
    fileprivate func executeRendererTransition(_ transition: RenderTransition) {
        guard let renderer = self.renderer else { return }
        
        messageQueue.isSuspended = true
        transition(renderer, {
            self.messageQueue.isSuspended = false
        })
    }
    
    // This method is intended to be used to execute a view controller transition like presenting or dismissing
    // a modal view controller. The reason being that view controller transition are usually animated and UIKit
    // provides a callback block that gets executed once the transition was completed.
    //
    // Because message processing must be sequential, we cannot process messages while executing a view controller
    // transition because that could result in inconsistent application state or miss-rendering issues. Also there
    // are some actions exposed by Portal, like `.dismissNavigator(thenSend: Action<MessageType, RouteType>)` that
    // are designed to be executed atomically; meaning that immediatly after the navigator (view controller) has been
    // dismissed the action indicated by `thenSend` associated value should be dispatched, without processing any other
    // messages that could be waiting in the processing queue.
    //
    // A typical example where rendering issues could happen if transition are not handled properly could be when the
    // user wants to dismiss a modal view controller and push a detail view in the navigation stack of the view
    // controller that presented the modal view controller in the first place. Presenting the detail view should
    // happen right after the modal view controller is dismissed. The problem could arise if message are being
    // dispatched while the modal dismissal transition and the detail view controller transition is being performed.
    //
    // This messages could be dispatched by asincronous processes or a subscription. To avoid loosing message and
    // mantain arraival ordering, because message are processed sequentially in separate queue (or thread) and view
    // controller transitions are executed on the main thread; Portal needs to suspend execution of messages in the
    // processing queue, then tell UIKit (or any other view layer) to execute the transition and once the transition is
    // completed resume processing message.
    //
    // In cases where transitions need to dispatch a message right after the transition has completed, like with
    // `.dismissNavigator(thenSend: Action<MessageType, RouteType>)`, we need to guarantee that the `thenSend` action
    // will be executed right away, no matter if there are pending messages in the queue. In other words, the `thenSend`
    // action has higher priority that any other message in the operation queue waiting to be processed.
    //
    // This methods wraps the transition in a function that receives a transition completion callback and when called
    // suspends the message processing queue, executes the transition and once the transition is completed enqueues
    // the received transition completion callback to be executed with the highest priority and resumes the
    // message processing queue.
    //
    // - Parameter maybeTransition: An optional view transition represented by a function tha receives a function to
    // be executed after the transition has been completed.
    //
    fileprivate func performTransition(
        _ maybeTransition: ScreenTransition?) -> (@escaping ScreenTransitionCompletion) -> Void {
        guard let transition = maybeTransition else { return { _ in } }
        
        return { transitionCompletionCallback in
            self.messageQueue.isSuspended = true
            transition({
                // The transition completion callback needs to have a higher priority in order to be executed
                // off the main thread right after the processing queue is resumed
                let operation = BlockOperation(block: transitionCompletionCallback)
                operation.queuePriority = .veryHigh
                self.messageQueue.addOperation(operation)
                self.messageQueue.isSuspended = false
            })
        }
    }
    
}

fileprivate struct NavigationState<RouteType: Route, NavigatorType: Equatable> {
    
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
// swiftlint:enable file_length
