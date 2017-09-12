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
        let view = containerView.subviews.first ?? UIView.with(parent: containerView)
        let renderResult = render(changeSet: changeSet, into: view)
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
            let containerView = view ?? UIView()
            containerView.managedByPortal = true
            return apply(changeSet: containerChangeSet, to: containerView)
            
        case .table(let tableChangeSet):
            let table = castOrRelease(view: view, to: TableView.self)
            return table.apply(changeSet: tableChangeSet, layoutEngine: layoutEngine)
            
        case .collection(let collectionChangeSet):
            let collection = castOrRelease(view: view, to: CollectionView.self)
            return collection.apply(changeSet: collectionChangeSet, layoutEngine: layoutEngine)
            
        case .carousel(let carouselChangeSet):
            let carousel = castOrRelease(view: view, to: CarouselView.self)
            return carousel.apply(changeSet: carouselChangeSet, layoutEngine: layoutEngine)
            
        case .touchable(let touchableChangeSet):
            let result = render(changeSet: touchableChangeSet.child, into: view)
            // TODO apply gesture recognizer to result?.view
            return result
            
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
            let containerView = view ?? UIView()
            containerView.managedByPortal = true
            layoutEngine.apply(changeSet: customComponentChangeSet.layout, to: containerView)
            containerView.apply(changeSet: customComponentChangeSet.baseStyleSheet)
            let mailbox: Mailbox<ActionType> = containerView.getMailbox()
            return Render(view: containerView, mailbox: mailbox) {
                let renderer = self.rendererFactory()
                renderer.apply(changeSet: customComponentChangeSet, inside: containerView, dispatcher: mailbox.dispatch)
            }
            
        case .spinner(let spinnerChangeSet):
            let spinner = castOrRelease(view: view, to: UIActivityIndicatorView.self)
            return spinner.apply(changeSet: spinnerChangeSet, layoutEngine: layoutEngine)
            
        case .textView(let textViewChangeSet):
            let textView = castOrRelease(view: view, to: UITextView.self)
            return textView.apply(changeSet: textViewChangeSet, layoutEngine: layoutEngine)
            
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
    
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
        for (subview, childChangeSet) in zip(subviews, changeSet.children) {
            let result = render(changeSet: childChangeSet, into: subview)
            
            if !reuseSubviews || result.view !== subview {
                result.view.managedByPortal = true
                // TODO This should not be added it should replace the current
                // view if needed
                view.addSubview(result.view)
                result.mailbox?.forward(to: mailbox)
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
        to viewType: SpecificView.Type) -> SpecificView {
        
        if view != nil && view is SpecificView {
            return view as! SpecificView //swiftlint:disable:this force_cast
        } else {
            view?.removeFromSuperview()
            let newView = SpecificView()
            return newView
        }
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

internal protocol UIKitRenderer {
    associatedtype MessageType
    associatedtype RouteType: Route

    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<Action<RouteType, MessageType>>

}

extension UIView {

    internal func apply(changeSet: [BaseStyleSheet.Property]) {
        for property in changeSet {
            switch property {

            case .alpha(let alpha):
                alpha |> { self.alpha = CGFloat($0) }

            case .backgroundColor(let backgroundColor):
                backgroundColor |> { self.backgroundColor = $0.asUIColor }

            case .cornerRadius(let cornerRadius):
                cornerRadius |> { self.layer.cornerRadius = CGFloat($0) }

            case .borderColor(let borderColor):
                borderColor |> { self.layer.borderColor = $0.asUIColor.cgColor }

            case .borderWidth(let borderWidth):
                borderWidth |> { self.layer.borderWidth = CGFloat($0) }

            case .contentMode(let contentMode):
                contentMode |> { self.contentMode = $0.toUIViewContentMode }

            case .clipToBounds(let clipToBounds):
                clipToBounds |> { self.clipsToBounds = $0 }

            case .shadow(let shadowChangeSet):
                self.layer.apply(changeSet: shadowChangeSet)
            }
        }
    }

    internal func apply(style: BaseStyleSheet) {
        style.backgroundColor   |> { self.backgroundColor = $0.asUIColor }
        style.cornerRadius      |> { self.layer.cornerRadius = CGFloat($0) }
        style.borderColor       |> { self.layer.borderColor = $0.asUIColor.cgColor }
        style.borderWidth       |> { self.layer.borderWidth = CGFloat($0) }
        style.alpha             |> { self.alpha = CGFloat($0) }
        style.contentMode       |> { self.contentMode = $0.toUIViewContentMode }
        style.clipToBounds      |> { self.clipsToBounds = $0 }
        style.shadow            |> { shadow in
            self.layer.shadowColor = shadow.color.asUIColor.cgColor
            self.layer.shadowOpacity = shadow.opacity
            self.layer.shadowOffset = shadow.offset.asCGSize
            self.layer.shadowRadius = CGFloat(shadow.radius)
            self.layer.shouldRasterize = shadow.shouldRasterize
        }

    }

}

fileprivate let defaultLayer = CALayer()

fileprivate extension CALayer {

    fileprivate func apply(changeSet: [Shadow.Property]?) {
        if let changeSet = changeSet {
            for property in changeSet {
                switch property {

                case .color(let shadowColor):
                    self.shadowColor = shadowColor.asUIColor.cgColor

                case .opacity(let shadowOpacity):
                    self.shadowOpacity = shadowOpacity

                case .offset(let shadowOffset):
                    self.shadowOffset = shadowOffset.asCGSize

                case .radius(let shadowRadius):
                    self.shadowRadius = CGFloat(shadowRadius)

                case .shouldRasterize(let shouldRasterize):
                    self.shouldRasterize = shouldRasterize

                }
            }
        } else {
            self.shadowColor = defaultLayer.shadowColor
            self.shadowOpacity = defaultLayer.shadowOpacity
            self.shadowOffset = defaultLayer.shadowOffset
            self.shadowRadius = defaultLayer.shadowRadius
            self.shouldRasterize = defaultLayer.shouldRasterize
        }
    }

}

fileprivate extension ContentMode {

    var toUIViewContentMode: UIViewContentMode {
        switch self {

        case .scaleToFill:
            return UIViewContentMode.scaleToFill

        case .scaleAspectFill:
            return UIViewContentMode.scaleAspectFill

        case .scaleAspectFit:
            return UIViewContentMode.scaleAspectFit

        }
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

extension Offset {

    internal var asCGSize: CGSize {
        return CGSize(width: CGFloat(x), height: CGFloat(y))
    }

}
