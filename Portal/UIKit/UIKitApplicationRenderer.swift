//
//  UIKitApplication.swift
//  Portal
//
//  Created by Guido Marucci Blas on 3/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//
// swiftlint:disable file_length

import UIKit

public final class UIKitApplicationRenderer<
    MessageType,
    RouteType,
    NavigatorType: Equatable,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: ApplicationRenderer

    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    public typealias ActionType = Action<RouteType, MessageType>
    public typealias CustomComponentRendererFactory = (ContainerController) -> CustomComponentRendererType
    public typealias ViewType = View<RouteType, MessageType, NavigatorType>

    internal typealias InternalActionType = InternalAction<RouteType, MessageType>
    internal typealias Dispatcher = (InternalActionType) -> Void
    
    public var isDebugModeEnabled: Bool {
        set {
            forwardee.isDebugModeEnabled = newValue
        }
        get {
            return forwardee.isDebugModeEnabled
        }
    }
    
    public var mailbox: Mailbox<ActionType> {
        return forwardee.mailbox
    }
    
    internal var internalMailbox: Mailbox<InternalActionType> {
        return forwardee.internalMailbox
    }
    
    fileprivate let forwardee: MainThreadUIKitApplicationRenderer<
        MessageType,
        RouteType,
        NavigatorType,
        CustomComponentRendererType>

    internal init(
        window: UIWindow,
        layoutEngine: LayoutEngine = YogaLayoutEngine(),
        rendererFactory: @escaping CustomComponentRendererFactory,
        dispatch: @escaping Dispatcher) {
        self.forwardee = MainThreadUIKitApplicationRenderer(
            window: window,
            layoutEngine:
            layoutEngine,
            rendererFactory: rendererFactory
        )
        internalMailbox.subscribe(subscriber: dispatch)
    }
    
    public func render(view: ViewType, completion: @escaping () -> Void) {
        switch renderingAction(for: view) {
            
        case .skipRendering:
            completion()
            
        case .presentAlert(let properties):
            executeInMainThread(self.forwardee.present(alert: properties, completion: completion))
            
        case .executeRendering(let rendering):
            DispatchQueue.main.async {
                rendering()
                completion()
            }
            
        }
    }
    
    public func present(view: ViewType, completion: @escaping () -> Void) {
        executeInMainThread(self.forwardee.present(view: view, completion: completion))
    }
    
    public func presentModal(view: ViewType, completion: @escaping () -> Void) {
        executeInMainThread(self.forwardee.presentModal(view: view, completion: completion))
    }
    
    public func dismissCurrentNavigator(completion: @escaping () -> Void) {
        executeInMainThread(self.forwardee.dismissCurrentNavigator(completion: completion))
    }
    
    public func rewindCurrentNavigator(completion: @escaping () -> Void) {
        executeInMainThread(self.forwardee.rewindCurrentNavigator(completion: completion))
    }
    
}

fileprivate extension UIKitApplicationRenderer {
    
    fileprivate var visibleController: ComponentController<MessageType, RouteType, CustomComponentRendererType>? {
        return forwardee.window.visibleController
    }
    
    fileprivate func executeInMainThread(_ code: @escaping @autoclosure () -> Void) {
        if Thread.isMainThread {
            code()
        } else {
            DispatchQueue.main.async { code() }
        }
    }
    
    fileprivate func renderingAction(for view: ViewType) -> ComponentRenderingAction<ActionType> {
        switch view.content {
            
        case .component(let component):
            if let action = renderingAction(for: component, with: view.root) {
                return action
            } else {
                return .executeRendering({ self.forwardee.setRootController(for: view) })
            }
            
        case .alert(properties: let properties):
            return .presentAlert(properties: properties)
            
        }
    }
    
    fileprivate func renderingAction(
        for component: Component<ActionType>,
        with rootComponent: RootComponent<ActionType>) -> ComponentRenderingAction<ActionType>? {
        
        switch (visibleController, rootComponent) {
            
        case (.some(.single(let controller)), .simple):
            // It is really important to calculate change set
            // off the main thread. This could be a computationally
            // intensive task and we don't want to block the main
            // thread while doing it.
            let patch = controller.calculatePatch(for: component)
            return .executeRendering({ controller.render(patch: patch) })
            
        case (.some(.navigationController(let navigationController)), .stack(let navigationBar)):
            guard !navigationController.isPopingTopController else {
                // We can safely skip rendering this view because the navigation
                // controller is in the middle of poping the top view controller
                // and it does not make any sense to update a view that it is
                // being destroyed.
                print("Rendering skipped because controller is being poped")
                return .skipRendering
            }
            let topController = navigationController.topController
            // It is really important to calculate change set
            // off the main thread. This could be a computationally
            // intensive task and we don't want to block the main
            // thread while doing it.
            let patch = topController.calculatePatch(for: component)
            return .executeRendering({
                topController.render(patch: patch)
                // TODO apply diff to navigation bar
                navigationController.render(navigationBar: navigationBar, inside: topController.navigationItem)
            })
            
        default:
            return .none
        }
    }

}

fileprivate enum ComponentRenderingAction<MessageType> {
    
    case skipRendering
    case executeRendering(() -> Void)
    case presentAlert(properties: AlertProperties<MessageType>)
    
}

fileprivate enum ComponentController<
    MessageType,
    RouteType,
    CustomComponentRendererType: UIKitCustomComponentRenderer>
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    case navigationController(PortalNavigationController<MessageType, RouteType, CustomComponentRendererType>)
    case single(PortalViewController<MessageType, RouteType, CustomComponentRendererType>)
    
    public var renderableController: UIViewController {
        switch self {
        case .navigationController(let navigationController):
            return navigationController
        case .single(let controller):
            return controller
        }
    }
    
    internal var internalMailbox: Mailbox<InternalAction<RouteType, MessageType>> {
        switch self {
        case .navigationController(let navigationController):
            return navigationController.internalMailbox
        case .single(let controller):
            return controller.internalMailbox
        }
    }
    
}

fileprivate final class MainThreadUIKitApplicationRenderer<
    MessageType,
    RouteType,
    NavigatorType: Equatable,
    CustomComponentRendererType: UIKitCustomComponentRenderer>
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {

    typealias ActionType = Action<RouteType, MessageType>
    typealias InternalActionType = InternalAction<RouteType, MessageType>
    typealias ViewType = View<RouteType, MessageType, NavigatorType>
    typealias ControllerType = PortalViewController<MessageType, RouteType, CustomComponentRendererType>
    typealias CustomComponentRendererFactory = (ContainerController) -> CustomComponentRendererType
    typealias ComponentRenderer = UIKitComponentRenderer<MessageType, RouteType, CustomComponentRendererType>
    typealias NavigatorControllerType = PortalNavigationController<MessageType, RouteType, CustomComponentRendererType>
    typealias ComponentControllerType = ComponentController<MessageType, RouteType, CustomComponentRendererType>

    fileprivate let mailbox: Mailbox<ActionType>
    fileprivate let internalMailbox = Mailbox<InternalActionType>()
    fileprivate let layoutEngine: LayoutEngine
    fileprivate let rendererFactory: CustomComponentRendererFactory
    
    fileprivate var isDebugModeEnabled: Bool = false
    fileprivate var window: WindowManager<MessageType, RouteType, CustomComponentRendererType>
    
    fileprivate var visibleController: ComponentController<MessageType, RouteType, CustomComponentRendererType>? {
        return window.visibleController
    }
    
    init(window: UIWindow, layoutEngine: LayoutEngine, rendererFactory: @escaping CustomComponentRendererFactory) {
        self.window = WindowManager(window: window)
        self.rendererFactory = rendererFactory
        self.layoutEngine = layoutEngine
        self.mailbox = internalMailbox.filterMap { internalAction in
            if case .action(let action) = internalAction {
                return action
            } else {
                return .none
            }
        }
    }
    
    fileprivate func present(alert: AlertProperties<ActionType>, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: alert.title, message: alert.text, preferredStyle: .alert)
        for button in alert.buttons {
            alertController.addAction(UIAlertAction(title: button.title, style: .default) { [weak self] _ in
                guard let action = button.onTap else { return }
                self?.internalMailbox.dispatch(message: .action(action))
            })
        }
        visibleController?.renderableController.present(alertController, animated: true, completion: completion)
    }
    
    fileprivate func currentNavigationController() -> NavigatorControllerType? {
        if case .some(.navigationController(let navigationController)) = visibleController {
            return navigationController
        } else {
            return .none
        }
    }
    
    fileprivate func rootController(
        for view: ViewType,
        contentController: @autoclosure () -> ControllerType) -> ComponentControllerType {
        switch view.root {
            
        case .simple:
            return .single(contentController())
            
        case .stack(let navigationBar):
            let navigationController = NavigatorControllerType(
                layoutEngine: layoutEngine,
                statusBarStyle: navigationBar.style.component.statusBarStyle.asUIStatusBarStyle,
                rendererFactory: rendererFactory
            )
            navigationController.orientation = view.orientation
            navigationController.isDebugModeEnabled = isDebugModeEnabled
            let containedController = contentController()
            navigationController.push(controller: containedController, with: navigationBar, animated: false) { }
            return .navigationController(navigationController)
            
        case .tab:
            fatalError("Root component 'tab' not supported")
        }
    }
    
    fileprivate func controller(
        for component: Component<ActionType>,
        orientation: SupportedOrientations) -> ControllerType {
        
        let controller: ControllerType =  ControllerType(
            component: component,
            layoutEngine: self.layoutEngine,
            customComponentRendererFactory: self.rendererFactory
        )
        controller.orientation = orientation
        
        return controller
    }
    
    fileprivate func setRootController(for view: ViewType) {
        guard case let .component(component) = view.content else {
            fatalError("Cannot set an alert view as root controller")
        }
        
        window.rootController = rootController(
            for: view,
            contentController: controller(for: component, orientation: view.orientation)
        )
        window.rootController?.internalMailbox.forward(to: internalMailbox)
    }
    
}

extension MainThreadUIKitApplicationRenderer {
    
    fileprivate func present(view: ViewType, completion: @escaping () -> Void) {
        switch view.content {
            
        case .component(let component):
            switch (visibleController, view.root) {
                
            case (.some(.navigationController(let navigationController)), .stack(let navigationBar)):
                let containedController = controller(for: component, orientation: view.orientation)
                navigationController.push(
                    controller: containedController,
                    with: navigationBar,
                    animated: true,
                    completion: completion
                )
                
            default:
                setRootController(for: view)
                completion()
            }
            
        case .alert(let properties):
            present(alert: properties, completion: completion)
        }
    }
    
    fileprivate func presentModal(view: ViewType, completion: @escaping () -> Void) {
        dismissCurrentNavigator {
            guard let presenter = self.visibleController?.renderableController else { return }
            
            switch view.content {
            case .component(let component):
                let controllerToPresent = self.rootController(
                    for: view,
                    contentController: self.controller(for: component, orientation: view.orientation)
                )
                controllerToPresent.internalMailbox.forward(to: self.internalMailbox)
                presenter.present(controllerToPresent.renderableController, animated: true, completion: completion)
                self.window.currentModal = controllerToPresent
                
            case .alert(let properties):
                self.present(alert: properties, completion: completion)
            }
        }
    }
    
    fileprivate func dismissCurrentNavigator(completion: @escaping () -> Void) {
        if let currentModal = window.currentModal {
            currentModal.renderableController.dismiss(animated: true) {
                self.window.currentModal = .none
                completion()
            }
        } else {
            completion()
        }
    }
    
    fileprivate func rewindCurrentNavigator(completion: @escaping () -> Void) {
        guard let navigationController = currentNavigationController() else { return }
        navigationController.popTopController(completion: completion)
    }
    
}

fileprivate struct WindowManager<
    MessageType,
    RouteType,
    CustomComponentRendererType: UIKitCustomComponentRenderer>
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    typealias ComponentControllerType = ComponentController<MessageType, RouteType, CustomComponentRendererType>
    
    fileprivate var rootController: ComponentControllerType? {
        set {
            window.rootViewController = newValue?.renderableController
            _rootController = newValue
        }
        get {
            return _rootController
        }
    }
    
    fileprivate var visibleController: ComponentControllerType? {
        return currentModal ?? rootController
    }
    
    fileprivate var currentModal: ComponentControllerType?
    
    private let window: UIWindow
    private var _rootController: ComponentControllerType?
    
    init(window: UIWindow) {
        self.window = window
        self._rootController = .none
        self.rootController = .none
        self.currentModal = .none
    }
    
}
