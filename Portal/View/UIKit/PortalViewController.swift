//
//  PortalViewController.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalViewController<
    MessageType,
    RouteType: Route,
    CustomComponentRendererType: UIKitCustomComponentRenderer>: UIViewController
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    public typealias ActionType = Action<RouteType, MessageType>
    public typealias RendererFactory = (ContainerController) ->
        UIKitComponentRenderer<MessageType, RouteType, CustomComponentRendererType>

    internal typealias InternalActionType = InternalAction<RouteType, MessageType>

    public var component: Component<ActionType>
    public let mailbox: Mailbox<ActionType>
    public var orientation: SupportedOrientations = .all
    
    internal let internalMailbox = Mailbox<InternalActionType>()
    
    fileprivate var disposers: [String : () -> Void] = [:]
    
    private let createRenderer: RendererFactory
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientation.uiInterfaceOrientation
    }
    
    public init(component: Component<ActionType>, factory createRenderer: @escaping RendererFactory) {
        self.component = component
        self.createRenderer = createRenderer
        self.mailbox = internalMailbox.filterMap { message in
            if case .action(let action) = message {
                return action
            } else {
                return .none
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposers.values.forEach { $0() }
    }
    
    public override func loadView() {
        super.loadView()
    }
    
    public override func viewDidLoad() {
        // Not really sure why this is necessary but some users where having
        // issues when pushing controllers into Portal's navigation controller.
        // For some reason the pushed controller's view was being positioned
        // at {0,0} instead at {0, statusBarHeight + navBarHeight}. What was
        // even weirder was that this did not happend for all users.
        // This setting seems to fix the issue.
        edgesForExtendedLayout = []
        render()
    }
    
    public func render() {
        // For some reason we need to calculate the view's frame
        // when updating a contained controller's view whos
        // parent is a navigation controller because if not the view
        // does not take into account the navigation and status bar in order
        // to sets its visible size.
        view.frame = calculateViewFrame()
        let renderer = createRenderer(self)
        let componentMailbox = renderer.render(component: component)
        componentMailbox.forwardMap(to: internalMailbox) { .action($0) }
    }
    
}

extension PortalViewController: ContainerController {
    
    public func registerDisposer(for identifier: String, disposer: @escaping () -> Void) {
        disposers[identifier] = disposer
    }
    
}

fileprivate extension PortalViewController {
    
    fileprivate var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    /// The bounds of the container view used to render the controller's component
    /// needs to be calcuated using this method because if the component is redenred
    /// on the viewDidLoad method for some reason UIKit reports the controller's view bounds
    /// to be equal to the screen's frame. Which does not take into account the status bar
    /// nor the navigation bar if the controllers is embeded inside a navigation controller.
    ///
    /// Also the supported orientation should be taken into account in order to define the bound's
    /// width and height. The supported orientation has higher priority to the device's orientation
    /// unless the supported orientation is all.
    ///
    /// The funny thing is that if you ask for the controller's view bounds inside viewWillAppear
    /// the bounds are properly set but the component needs to be rendered cannot be rendered in
    /// viewWillAppear because some views, like UITableView have unexpected behavior.
    ///
    /// - Returns: The view bounds that should be used to render the component's view
    fileprivate func calculateViewFrame() -> CGRect {
        var bounds = UIScreen.main.bounds
        if isViewInLandscapeOrientation() {
            // We need to check if the bounds has already been swapped.
            // After the device has been effectively been set in landscape mode
            // either by rotation the device of by forcing the supported orientation
            // UIKit returns the bounds size already swapped but the first time we
            // are forcing a landscape orientation we need to swap them manually.
            if bounds.size.width < bounds.height {
                bounds.size = bounds.size.swapped()
            }
            if let navBarBounds = navigationController?.navigationBar.bounds {
                bounds.size.width -= statusBarHeight + navBarBounds.size.height
                bounds.origin.x += statusBarHeight + navBarBounds.size.height
            }
        } else if let navBarBounds = navigationController?.navigationBar.bounds {
            // FIXME There is a bug that needs to be solved regarding the status
            // bug. When a modal landscape controller is being presented on top
            // of a portrait navigation controller, because in landscape mode the 
            // status bar is not present, UIKit decides to hide the status bar before
            // performing the transition animation to present the modal controller.
            //
            // This has the effect of making the view bounds bigger because the 
            // status bar is not visible anymore and because we do not perform
            // a re-layout, the view endups being moved to the new origin and
            // a black space appears at the bottom of the view.
            //
            // A possible solution would be to detect when a modal landscape
            // controller is being presented and then re-render the view which
            // would trigger a calculation of the layout that would take 
            // into account the update view's bounds.
            bounds.size.height -= statusBarHeight + navBarBounds.size.height
            bounds.origin.y += statusBarHeight + navBarBounds.size.height
        }
        return bounds
    }
    
    fileprivate func isViewInLandscapeOrientation() -> Bool {
        switch orientation {
        case .landscape:
            return true
        case .portrait:
            return false
        case .all:
            return UIDevice.current.orientation.isLandscape
        }
    }
    
}

fileprivate extension CGSize {

    func swapped() -> CGSize {
        return CGSize(width: height, height: width)
    }
    
}
