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
    
    public var isDebugModeEnabled: Bool {
        set {
            componentManager.isDebugModeEnabled = newValue
        }
        get {
            return componentManager.isDebugModeEnabled
        }
    }
    
    fileprivate var currentModal: UIViewController? = .none
    fileprivate var componentManager: UIKitComponentManager<ActionType, CustomComponentRendererType>
    fileprivate let dispatch: Dispatcher

    public init(window: UIWindow, customComponentRenderer: CustomComponentRendererType, dispatch: @escaping Dispatcher) {
        self.dispatch = dispatch
        componentManager = UIKitComponentManager(window: window, customComponentRenderer: customComponentRenderer)
        componentManager.mailbox.subscribe(subscriber: dispatch)
    }
    
    public func render(component: Component<ActionType>, with root: RootComponent<ActionType>) {
        executeInMainThread { _ = self.componentManager.render(component: component, with: root) }
    }
    
    public func present(component: Component<ActionType>, with root: RootComponent<ActionType>, modally: Bool) {
        executeInMainThread {
            if modally {
                self.currentModal?.dismiss(animated: false, completion: nil)
            }
            
            let presented = self.componentManager.present(component: component, with: root, modally: modally)
            
            if modally {
                self.currentModal = presented
            }
        }
    }
    
    public func present(alert properties: AlertProperties<ActionType>) {
        executeInMainThread {
            let alert = UIAlertController(title: properties.title, message: properties.text, preferredStyle: .alert)
            for button in properties.buttons {
                alert.addAction(UIAlertAction(title: button.title, style: .default) { [weak self] _ in
                    guard let action = button.onTap else { return }
                    self?.dispatch(action)
                })
            }
            self.visibleController?.present(alert, animated: true, completion: nil)
        }
    }
    
    public func dismissCurrentNavigator(completion: @escaping () -> Void) {
        guard let currentModal = self.currentModal else { return }
        
        executeInMainThread {
            currentModal.dismiss(animated: true) {
                self.currentModal = .none
                completion()
            }
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
    
    fileprivate var visibleController: UIViewController? {
        if let modal = self.currentModal {
            return modal
        } else {
            return componentManager.rootController?.renderableController
        }
    }
    
    fileprivate func executeInMainThread(code: @escaping () -> Void) {
        if Thread.isMainThread {
            code()
        } else {
            DispatchQueue.main.async(execute: code)
        }
    }
    
    fileprivate func currentNavigationController() -> PortalNavigationController<ActionType, CustomComponentRendererType>? {
        if let currentModal = self.currentModal as? PortalNavigationController<ActionType, CustomComponentRendererType> {
            return currentModal
        } else if let rootController = componentManager.rootController {
            switch rootController {
                
            case .navigationController(let navigationController):
                return navigationController
                
            default:
                return .none
            }
        }
        return .none
    }
    
}
