//
//  UIKitApplication.swift
//  PortalApplication
//
//  Created by Guido Marucci Blas on 3/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit
import PortalView

public final class UIKitApplicationRenderer<
    MessageType,
    RouteType: Route,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: ApplicationRenderer

    where CustomComponentRendererType.MessageType == Action<RouteType, MessageType>  {
    
    public typealias ActionType = Action<RouteType, MessageType>
    public typealias Dispatcher = (Action<RouteType, MessageType>) -> Void
    public typealias CustomComponentRendererFactory = (UIViewController) -> CustomComponentRendererType
    
    public var isDebugModeEnabled: Bool {
        set {
            componentManager.isDebugModeEnabled = newValue
        }
        get {
            return componentManager.isDebugModeEnabled
        }
    }
    
    fileprivate var componentManager: UIKitComponentManager<ActionType, CustomComponentRendererType>
    fileprivate let dispatch: Dispatcher

    public init(window: UIWindow, rendererFactory: @escaping CustomComponentRendererFactory, dispatch: @escaping Dispatcher) {
        self.dispatch = dispatch
        componentManager = UIKitComponentManager(window: window, rendererFactory: rendererFactory)
        componentManager.mailbox.subscribe(subscriber: dispatch)
    }
    
    public func render(component: Component<ActionType>, with root: RootComponent<ActionType>, orientation: SupportedOrientations) {
        executeInMainThread { _ = self.componentManager.render(component: component, with: root, orientation: orientation) }
    }
    
    public func present(component: Component<ActionType>, with root: RootComponent<ActionType>, modally: Bool, orientation: SupportedOrientations, completion: @escaping () -> Void) {
        executeInMainThread {
            self.componentManager.present(component: component, with: root, modally: modally, orientation: orientation, completion: completion)
        }
    }
    
    public func present(alert properties: AlertProperties<ActionType>, completion: @escaping () -> Void) {
        executeInMainThread {
            let alert = UIAlertController(title: properties.title, message: properties.text, preferredStyle: .alert)
            for button in properties.buttons {
                alert.addAction(UIAlertAction(title: button.title, style: .default) { [weak self] _ in
                    guard let action = button.onTap else { return }
                    self?.dispatch(action)
                })
            }
            self.visibleRenderableController?.present(alert, animated: true, completion: completion)

        }
    }
    
    public func dismissCurrentNavigator(completion: @escaping () -> Void) {
        executeInMainThread {
            self.componentManager.dismissCurrentModal(completion: completion)
        }
    }
    
    public func rewindCurrentNavigator(completion: @escaping () -> Void) {
        guard let navigationController = currentNavigationController() else { return }
        
        executeInMainThread {
            navigationController.popTopController(completion: completion)
        }
    }
    
}

fileprivate extension UIKitApplicationRenderer {
    
    fileprivate var visibleRenderableController: UIViewController? {
        return componentManager.visibleController?.renderableController
    }
    
    fileprivate func executeInMainThread(code: @escaping () -> Void) {
        if Thread.isMainThread {
            code()
        } else {
            DispatchQueue.main.async(execute: code)
        }
    }
    
    fileprivate func currentNavigationController() -> PortalNavigationController<ActionType, CustomComponentRendererType>? {
        if case .some(.navigationController(let navigationController)) = componentManager.visibleController {
            return navigationController
        } else {
            return .none
        }
    }
    
}
