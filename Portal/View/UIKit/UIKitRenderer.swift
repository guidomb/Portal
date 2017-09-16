//
//  UIKitRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public struct UIKitComponentRenderer<
    MessageType,
    RouteType,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: Renderer

    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {

    public typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    public typealias ActionType = Action<RouteType, MessageType>
    
    typealias TableView = PortalTableView<MessageType, RouteType, CustomComponentRendererType>
    typealias CollectionView = PortalCollectionView<MessageType, RouteType, CustomComponentRendererType>
    typealias CarouselView = PortalCarouselView<MessageType, RouteType, CustomComponentRendererType>

    public var isDebugModeEnabled = true
    public var debugConfiguration = RendererDebugConfiguration()

    fileprivate let layoutEngine: LayoutEngine
    fileprivate let rendererFactory: CustomComponentRendererFactory
    
    public init(
        layoutEngine: LayoutEngine = YogaLayoutEngine(),
        rendererFactory: @escaping CustomComponentRendererFactory) {
        self.rendererFactory = rendererFactory
        self.layoutEngine = layoutEngine
    }

    public func render(component: Component<ActionType>, into containerView: UIView) -> Mailbox<ActionType> {
        apply(changeSet: component.fullChangeSet, to: containerView)
        return containerView.getMailbox()
    }
    
    public func apply(changeSet: ComponentChangeSet<ActionType>, to containerView: UIView) {
        let rootView = getOrCreateRootView(from: containerView)
        let renderResult = render(changeSet: changeSet, into: rootView)
        if rootView !== renderResult.view {
            containerView.addSubview(renderResult.view)
            renderResult.mailbox?.forward(to: containerView.getMailbox())
        }
        layoutEngine.executeLayout(for: containerView)
        renderResult.afterLayout?()
        
        if isShowViewFrame {
            renderResult.view.safeTraverse { $0.addDebugFrame() }
        }
    }
    
}

extension UIKitComponentRenderer {
    
    var isShowViewChangeAnimation: Bool {
        return isDebugModeEnabled &&  debugConfiguration.showViewChangeAnimation
    }
    
    var isShowViewFrame: Bool {
        return isDebugModeEnabled &&  debugConfiguration.showViewFrame
    }
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    fileprivate func render(changeSet: ComponentChangeSet<ActionType>, into view: UIView?) -> Render<ActionType> {
        switch changeSet {
            
        case .button(let buttonChangeSet):
            let button = castOrRelease(view: view, to: UIButton.self)
            return button.apply(changeSet: buttonChangeSet, layoutEngine: layoutEngine)
            
        case .label(let labelChangeSet):
            let label = castOrRelease(view: view, to: UILabel.self)
            return label.apply(changeSet: labelChangeSet, layoutEngine: layoutEngine)
            
        case .mapView(let mapViewChangeSet):
            let mapView = castOrRelease(view: view, to: PortalMapView.self)
            return mapView.apply(changeSet: mapViewChangeSet, layoutEngine: layoutEngine)
            
        case .imageView(let imageViewChangeSet):
            let imageView = castOrRelease(view: view, to: UIImageView.self)
            return imageView.apply(changeSet: imageViewChangeSet, layoutEngine: layoutEngine)
            
        case .container(let containerChangeSet):
            // We need to make sure that view's type is UIView and not
            // any of it's subclasses because container components
            // cannot be renderer inside a UIButton for example.
            if let containerView = view, type(of: containerView) == UIView.self {
                return apply(changeSet: containerChangeSet, to: containerView)
            } else {
                let containerView = UIView()
                containerView.managedByPortal = true
                return apply(changeSet: containerChangeSet, to: containerView)
            }
            
        case .table(let tableChangeSet):
            let table = castOrRelease(view: view, to: TableView.self) { TableView(renderer: self) }
            return table.apply(changeSet: tableChangeSet, layoutEngine: layoutEngine)
            
        case .collection(let collectionChangeSet):
            let collection = castOrRelease(view: view, to: CollectionView.self) { CollectionView(renderer: self) }
            return collection.apply(changeSet: collectionChangeSet, layoutEngine: layoutEngine)
            
        case .carousel(let carouselChangeSet):
            let carousel = castOrRelease(view: view, to: CarouselView.self) { CarouselView(renderer: self) }
            return carousel.apply(changeSet: carouselChangeSet, layoutEngine: layoutEngine)
            
        case .touchable(let touchableChangeSet):
            return apply(changeSet: touchableChangeSet, to: view)
            
        case .segmented(let segmentedChangeSet):
            let segmented = castOrRelease(view: view, to: UISegmentedControl.self)
            return segmented.apply(changeSet: segmentedChangeSet, layoutEngine: layoutEngine)
            
        case .progress(let progressChangeSet):
            let progress = castOrRelease(view: view, to: UIProgressView.self)
            return progress.apply(changeSet: progressChangeSet, layoutEngine: layoutEngine)
            
        case .textField(let textFieldChangeSet):
            let textField = castOrRelease(view: view, to: UITextField.self)
            return textField.apply(changeSet: textFieldChangeSet, layoutEngine: layoutEngine)
            
        case .custom(let customComponentChangeSet):
            return apply(changeSet: customComponentChangeSet, to: view ?? UIView())
            
        case .spinner(let spinnerChangeSet):
            let spinner = castOrRelease(view: view, to: UIActivityIndicatorView.self)
            return spinner.apply(changeSet: spinnerChangeSet, layoutEngine: layoutEngine)
            
        case .textView(let textViewChangeSet):
            let textView = castOrRelease(view: view, to: UITextView.self)
            return textView.apply(changeSet: textViewChangeSet, layoutEngine: layoutEngine)
            
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
    
    fileprivate func apply(changeSet: TouchableChangeSet<ActionType>, to view: UIView?) -> Render<ActionType> {
        let result = render(changeSet: changeSet.child, into: view)
        
        switch changeSet.gesture {
            
        case .change(to: .tap(let message)):
            let mailbox: Mailbox<ActionType> = result.view.getMailbox()
            let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
            result.view.register(dispatcher: dispatcher)
            result.view.gestureRecognizers?.forEach { result.view.removeGestureRecognizer($0) }
            let recognizer = UITapGestureRecognizer(target: dispatcher, action: dispatcher.selector)
            result.view.addGestureRecognizer(recognizer)
            
        case .noChange:
            break
            
        }
        
        return result
    }
    
    fileprivate func apply(changeSet: CustomComponentChangeSet, to containerView: UIView) -> Render<ActionType> {
        containerView.managedByPortal = true
        layoutEngine.apply(changeSet: changeSet.layout, to: containerView)
        containerView.apply(changeSet: changeSet.baseStyleSheet)
        let mailbox: Mailbox<ActionType> = containerView.getMailbox()
        return Render(view: containerView, mailbox: mailbox) {
            let renderer = self.rendererFactory()
            renderer.apply(changeSet: changeSet, inside: containerView, dispatcher: mailbox.dispatch)
        }
    }
    
    fileprivate func apply(changeSet: ContainerChangeSet<ActionType>, to view: UIView) -> Render<ActionType> {
        var afterLayoutTasks = [AfterLayoutTask]()
        afterLayoutTasks.reserveCapacity(changeSet.childrenCount)
        let reuseSubviews = view.subviews.count == changeSet.childrenCount
        let subviews: [UIView?]
        
        if reuseSubviews {
            subviews = view.subviews
        } else {
            view.subviews.forEach { $0.removeFromSuperview() }
            subviews = Array(repeating: .none, count: changeSet.childrenCount)
        }
        
        let mailbox: Mailbox<ActionType> = view.getMailbox()
        for (index, (subview, childChangeSet)) in zip(subviews, changeSet.children).enumerated() {
            let result = render(changeSet: childChangeSet, into: subview)
            
            if !reuseSubviews || result.view !== subview {
                result.view.managedByPortal = true
                result.mailbox?.forward(to: mailbox)
                if reuseSubviews {
                    view.insertSubview(result.view, at: index)
                } else {
                    view.addSubview(result.view)
                }
            }
            
            if isShowViewChangeAnimation && !changeSet.isEmpty {
                result.view.addChangeDebugAnimation()
            }

            if let afterLayoutTask = result.afterLayout {
                afterLayoutTasks.append(afterLayoutTask)
            }
        }
        
        view.apply(changeSet: changeSet.baseStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: view)
        
        return Render(view: view, mailbox: mailbox) {
            afterLayoutTasks.forEach { $0() }
        }
    }
    
    fileprivate func castOrRelease<SpecificView: UIView>(
        view: UIView?,
        to viewType: SpecificView.Type,
        viewFactory: (() -> SpecificView)? = .none) -> SpecificView {
        
        if view != nil && view is SpecificView {
            return view as! SpecificView //swiftlint:disable:this force_cast
        } else {
            view?.removeFromSuperview()
            let newView = viewFactory?() ?? SpecificView()
            return newView
        }
    }
    
    fileprivate func getOrCreateRootView(from containerView: UIView) -> UIView {
        let view: UIView
        if let subview = containerView.subviews.first {
            view = subview
        } else {
            view = UIView()
            containerView.addSubview(view)
            let mailbox: Mailbox<ActionType> = view.getMailbox()
            mailbox.forward(to: containerView.getMailbox())
        }
        return view
    }
    
}

internal typealias AfterLayoutTask = () -> Void

internal struct Render<MessageType> {

    let view: UIView
    let mailbox: Mailbox<MessageType>?
    let afterLayout: AfterLayoutTask?

    init(view: UIView,
         mailbox: Mailbox<MessageType>? = .none,
         executeAfterLayout afterLayout: AfterLayoutTask? = .none) {
        self.view = view
        self.afterLayout = afterLayout
        self.mailbox = mailbox
    }

}
