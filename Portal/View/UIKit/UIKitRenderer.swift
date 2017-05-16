//
//  UIKitRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public protocol ContainerController {
    
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
    
    init(container: ContainerController)
    
    func renderComponent(_ componentDescription: CustomComponentDescription, inside view: UIView, dispatcher: @escaping (MessageType) -> Void)
    
}

public struct VoidCustomComponentRenderer<MessageType>: UIKitCustomComponentRenderer {
    
    public init(container: ContainerController) {
        
    }
        
    public func renderComponent(_ componentDescription: CustomComponentDescription, inside view: UIView, dispatcher: @escaping (MessageType) -> Void) {
    
    }
}

public struct UIKitComponentRenderer<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: Renderer
    where CustomComponentRendererType.MessageType == MessageType {
    
    public typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    
    public var isDebugModeEnabled: Bool = false
    
    internal let layoutEngine: LayoutEngine
    internal let rendererFactory: CustomComponentRendererFactory
    
    private let containerView: UIView
    
    public init(
        containerView: UIView,
        layoutEngine: LayoutEngine = YogaLayoutEngine(),
        rendererFactory: @escaping CustomComponentRendererFactory) {
        self.containerView = containerView
        self.rendererFactory = rendererFactory
        self.layoutEngine = layoutEngine
    }
    
    public func render(component: Component<MessageType>) -> Mailbox<MessageType> {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        let renderer = ComponentRenderer(component: component, rendererFactory: rendererFactory)
        let renderResult = renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
        renderResult.view.managedByPortal = true
        layoutEngine.layout(view: renderResult.view, inside: containerView)
        renderResult.afterLayout?()
        
        if isDebugModeEnabled {
            renderResult.view.safeTraverse { $0.addDebugFrame() }
        }
        
        return renderResult.mailbox ?? Mailbox<MessageType>()
    }
    
}

internal typealias AfterLayoutTask = () -> ()

internal struct Render<MessageType> {
    
    let view: UIView
    let mailbox: Mailbox<MessageType>?
    let afterLayout: AfterLayoutTask?
    
    init(view: UIView, mailbox: Mailbox<MessageType>? = .none, executeAfterLayout afterLayout: AfterLayoutTask? = .none) {
        self.view = view
        self.afterLayout = afterLayout
        self.mailbox = mailbox
    }
    
}

internal protocol UIKitRenderer {
    
    associatedtype MessageType
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType>
    
}

extension UIView {
    
    internal func apply(style: BaseStyleSheet) {
        style.backgroundColor   |> { self.backgroundColor = $0.asUIColor }
        style.cornerRadius      |> { self.layer.cornerRadius = CGFloat($0) }
        style.borderColor       |> { self.layer.borderColor = $0.asUIColor.cgColor }
        style.borderWidth       |> { self.layer.borderWidth = CGFloat($0) }
        style.alpha             |> { self.alpha = CGFloat($0) }
        
    }
    
}

extension SupportedOrientations {
    
    var uiInterfaceOrientation: UIInterfaceOrientationMask {
        switch self {
        case .all:
            return .all
        case .landscape:
            return .landscape
        case .portrait:
            return .portrait
        }
    }
    
}
