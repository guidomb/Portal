//
//  UIKitApplication.swift
//  Portal
//
//  Created by Guido Marucci Blas on 3/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class UIKitApplicationRenderer<
    MessageType,
    RouteType: Route,
    NavigatorType: Equatable,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: ApplicationRenderer

    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType  {
    
    public typealias ActionType = Action<RouteType, MessageType>
    public typealias Dispatcher = (ActionType) -> Void
    public typealias CustomComponentRendererFactory = (ContainerController) -> CustomComponentRendererType
    public typealias ViewType = View<RouteType, MessageType, NavigatorType>

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
    
    fileprivate let forwardee: MainThreadUIKitApplicationRenderer<MessageType, RouteType, NavigatorType, CustomComponentRendererType>

    public init(window: UIWindow, layoutEngine: LayoutEngine = YogaLayoutEngine(), rendererFactory: @escaping CustomComponentRendererFactory, dispatch: @escaping Dispatcher) {
        self.forwardee = MainThreadUIKitApplicationRenderer(window: window, layoutEngine: layoutEngine, rendererFactory: rendererFactory)
        forwardee.mailbox.subscribe(subscriber: dispatch)
    }
    
    public func render(view: ViewType, completion: @escaping () -> Void) {
        executeInMainThread(self.forwardee.render(view: view, completion: completion))
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
    
    fileprivate func executeInMainThread(_ code: @escaping @autoclosure () -> Void) {
        if Thread.isMainThread {
            code()
        } else {
            DispatchQueue.main.async { code() }
        }
    }

}

public enum ComponentController<MessageType, RouteType: Route, CustomComponentRendererType: UIKitCustomComponentRenderer>
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType  {
    
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
    
    public var mailbox: Mailbox<Action<RouteType, MessageType>> {
        switch self {
        case .navigationController(let navigationController):
            return navigationController.mailbox
        case .single(let controller):
            return controller.mailbox
        }
    }
    
}

fileprivate final class MainThreadUIKitApplicationRenderer<
    MessageType,
    RouteType: Route,
    NavigatorType: Equatable,
    CustomComponentRendererType: UIKitCustomComponentRenderer>
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType  {

    typealias ActionType = Action<RouteType, MessageType>
    typealias ViewType = View<RouteType, MessageType, NavigatorType>
    typealias ControllerType = PortalViewController<MessageType, RouteType, CustomComponentRendererType>
    typealias CustomComponentRendererFactory = (ContainerController) -> CustomComponentRendererType
    typealias ComponentRenderer = UIKitComponentRenderer<MessageType, RouteType, CustomComponentRendererType>
    typealias NavigatorControllerType = PortalNavigationController<MessageType, RouteType, CustomComponentRendererType>
    typealias ComponentControllerType = ComponentController<CustomComponentRendererType.MessageType, CustomComponentRendererType.RouteType, CustomComponentRendererType>

    fileprivate let mailbox = Mailbox<ActionType>()
    fileprivate let layoutEngine: LayoutEngine
    fileprivate let rendererFactory: CustomComponentRendererFactory
    
    fileprivate var isDebugModeEnabled: Bool = false
    fileprivate var window: WindowManager<CustomComponentRendererType.MessageType, CustomComponentRendererType.RouteType, CustomComponentRendererType>
    
    fileprivate var visibleController: ComponentController<MessageType, RouteType, CustomComponentRendererType>? {
        return window.visibleController
    }
    
    init(window: UIWindow, layoutEngine: LayoutEngine, rendererFactory: @escaping CustomComponentRendererFactory) {
        self.window = WindowManager(window: window)
        self.rendererFactory = rendererFactory
        self.layoutEngine = layoutEngine
    }
    
    fileprivate func present(alert: AlertProperties<ActionType>, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: alert.title, message: alert.text, preferredStyle: .alert)
        for button in alert.buttons {
            alertController.addAction(UIAlertAction(title: button.title, style: .default) { [weak self] _ in
                guard let action = button.onTap else { return }
                self?.mailbox.dispatch(message: action)
            })
        }
        visibleController?.renderableController.present(alertController, animated: true, completion: completion)
    }
    
    fileprivate func currentNavigationController() -> PortalNavigationController<MessageType, RouteType, CustomComponentRendererType>? {
        if case .some(.navigationController(let navigationController)) = visibleController {
            return navigationController
        } else {
            return .none
        }
    }
    
    fileprivate func rootController(for view: ViewType, contentController: @autoclosure () -> ControllerType) -> ComponentControllerType {
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
            
        case .tab(_):
            fatalError("Root component 'tab' not supported")
        }
    }
    
    fileprivate func controller(for component: Component<ActionType>, orientation: SupportedOrientations) -> ControllerType {
        
        let controller: ControllerType =  ControllerType(component: component) { container in
            var renderer = ComponentRenderer(
                containerView: container.containerView,
                layoutEngine: self.layoutEngine,
                rendererFactory: { [unowned container] in self.rendererFactory(container) }
            )
            renderer.isDebugModeEnabled = self.isDebugModeEnabled
            return renderer
        }
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
        window.rootController?.mailbox.forward(to: mailbox)
    }
    
}

extension MainThreadUIKitApplicationRenderer: ApplicationRenderer {
    
    fileprivate func render(view: ViewType, completion: @escaping () -> Void) {
        switch view.content {
            
        case .component(let component):
            switch (window.visibleController, view.root) {
                
            case (.some(.single(let controller)), .simple):
                controller.component = component
                controller.render()
                
            case (.some(.navigationController(let navigationController)), .stack(let navigationBar)):
                guard !navigationController.isPopingTopController else {
                    print("Rendering skipped because controller is being poped")
                    return
                }
                guard let topController = navigationController.topController else {
                    // TODO better handle this case
                    return
                }
                topController.component = component
                topController.render()
                navigationController.render(navigationBar: navigationBar, inside: topController.navigationItem)
                
            default:
                setRootController(for: view)
            }
            
            completion()
            // TODO Handle case where window.visibleController.orientation != orientation
            
        case .alert(properties: let properties):
            present(alert: properties, completion: completion)
            
        }
    }
    
    fileprivate func present(view: ViewType, completion: @escaping () -> Void) {
        switch view.content {
            
        case .component(let component):
            switch (visibleController, view.root) {
                
            case (.some(.navigationController(let navigationController)), .stack(let navigationBar)):
                let containedController = controller(for: component, orientation: view.orientation)
                navigationController.push(controller: containedController, with: navigationBar, animated: true, completion: completion)
                
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
                controllerToPresent.mailbox.forward(to: self.mailbox)
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

fileprivate struct WindowManager<MessageType, RouteType: Route, CustomComponentRendererType: UIKitCustomComponentRenderer>
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType  {
    
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

