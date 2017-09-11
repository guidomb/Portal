//
//  UIKitCustomComponentRenderer.swift
//  Portal
//
//  Created by Guido Marucci Blas on 9/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//
import UIKit

public protocol ContainerController: class {
    
    var containerView: UIView { get }
    
    func attachChildController(_ controller: UIViewController)
    
    func registerDisposer(for identifier: String, disposer: @escaping () -> Void)
    
}

extension ContainerController where Self: UIViewController {
    
    public var containerView: UIView {
        return self.view
    }
    
    public func attachChildController(_ controller: UIViewController) {
        guard controller.parent == self else { return }
        
        controller.willMove(toParentViewController: self)
        self.addChildViewController(controller)
        controller.didMove(toParentViewController: self)
    }
    
}

public struct CustomComponentDescription {
    
    public let identifier: String
    public let information: [String : Any]
    public let style: StyleSheet<EmptyStyleSheet>
    public let layout: Layout
    
}

public protocol UIKitCustomComponentRenderer {
    
    associatedtype MessageType
    associatedtype RouteType: Route
    
    init(container: ContainerController)
    
    func renderComponent(
        _ componentDescription: CustomComponentDescription,
        inside view: UIView,
        dispatcher: @escaping (Action<RouteType, MessageType>) -> Void)
    
    func apply(
        changeSet: CustomComponentChangeSet,
        inside view: UIView,
        dispatcher: @escaping (Action<RouteType, MessageType>) -> Void)
    
}

public struct VoidCustomComponentRenderer<MessageType, RouteType: Route>: UIKitCustomComponentRenderer {
    
    public init(container: ContainerController) {
        
    }
    
    public func renderComponent(
        _ componentDescription: CustomComponentDescription,
        inside view: UIView,
        dispatcher: @escaping (Action<RouteType, MessageType>) -> Void) {
        
    }
    
    public func apply(
        changeSet: CustomComponentChangeSet,
        inside view: UIView,
        dispatcher: @escaping (Action<RouteType, MessageType>) -> Void) {
        
    }
}
