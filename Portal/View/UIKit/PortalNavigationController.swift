//
//  PortalNavigationController.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalNavigationController<
    MessageType,
    RouteType,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: UINavigationController, UINavigationControllerDelegate
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    public typealias CustomComponentRendererFactory = (ContainerController) -> CustomComponentRendererType
    public typealias ContentControllerType = PortalViewController<MessageType, RouteType, CustomComponentRendererType>
    public typealias ActionType = Action<RouteType, MessageType>
    
    internal typealias InternalActionType = InternalAction<RouteType, MessageType>
    
    public let mailbox: Mailbox<ActionType>
    
    public var isDebugModeEnabled: Bool = false
    public var orientation: SupportedOrientations = .all
    
    internal let internalMailbox = Mailbox<InternalActionType>()
    
    public var topController: ContentControllerType? {
        return self.topViewController as? ContentControllerType
    }
    
    public private(set) var isPopingTopController = false

    fileprivate let layoutEngine: LayoutEngine
    fileprivate let rendererFactory: CustomComponentRendererFactory
    fileprivate var disposers: [String : () -> Void] = [:]
    fileprivate var currentNavigationBarOnBack: InternalActionType? = .none

    private let statusBarStyle: UIStatusBarStyle
    private var pushingViewController = false
    private var onControllerDidShow: (() -> Void)? = .none
    private var onPop: (() -> Void)? = .none
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch orientation {
        case .all:
            return .all
        case .landscape:
            return .landscape
        case .portrait:
            return .portrait
        }
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    init(layoutEngine: LayoutEngine,
         statusBarStyle: UIStatusBarStyle = .`default`,
         rendererFactory: @escaping CustomComponentRendererFactory) {
        self.rendererFactory = rendererFactory
        self.statusBarStyle = statusBarStyle
        self.layoutEngine = layoutEngine
        self.mailbox = internalMailbox.filterMap { message in
            if case .action(let action) = message {
                return action
            } else {
                return .none
            }
        }
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposers.values.forEach { $0() }
    }
    
    public func push(controller: ContentControllerType, with navigationBar: NavigationBar<ActionType>, animated: Bool,
                     completion: @escaping () -> Void) {
        pushingViewController = true
        onControllerDidShow = completion
        pushViewController(controller, animated: animated)
        render(navigationBar: navigationBar, inside: controller.navigationItem)
        controller.mailbox.forwardMap(to: internalMailbox) { .action($0) }
    }
    
    public func popTopController(completion: @escaping () -> Void) {
        onPop = completion
        popViewController(animated: true)
    }
    
    public func render(navigationBar: NavigationBar<ActionType>, inside navigationItem: UINavigationItem) {
        configureOnBackAction(for: navigationBar.properties)
        self.navigationBar.apply(style: navigationBar.style)
        
        if let leftButtonItems = navigationBar.properties.leftButtonItems {
            navigationItem.leftBarButtonItems = leftButtonItems.map(render)
        } else if let backButtonTitle = navigationBar.properties.backButtonTitle {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)
        }
        navigationItem.rightBarButtonItems = navigationBar.properties.rightButtonItems.map { $0.map(render) }
        
        if navigationBar.style.component.separatorHidden {
            self.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
            self.navigationBar.shadowImage = UIImage()
        }
        
        if let title = navigationBar.properties.title {
            let renderer = NavigationBarTitleRenderer(
                navigationBarTitle: title,
                navigationItem: navigationItem,
                navigationBarSize: self.navigationBar.bounds.size,
                rendererFactory: { self.rendererFactory(self) }
            )
            renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled) |> { navigationBarMailbox in
                navigationBarMailbox.forwardMap(to: internalMailbox) { .action($0) }
            }
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController, animated: Bool) {
        if pushingViewController {
            pushingViewController = false
        } else if !pushingViewController && topViewController != .none {
            // If a controller is not being pushed and the top view controller
            // is not nil then the navigation controller is poping the top view controller.
            // In which case the `onBack` message should be dispatched.
            //
            // The reason we need 'onControllerDidShow' is due to the fact that UIKit is calling
            // navigationController(didShow:,animated:) method twice. Apparently only when the pushed
            // controller is the first controller in the navigation stack.
            //
            // navigationController(willShow:,animated:) seems to be called only once so I decided to place
            // the logic to decide wether to dispatch the onBack message here but the message MUST be dispatched
            // in navigationController(didShow:,animated:) because that is when UIKit guarantees that transition
            // animation was completed. If you do things while being on a transition weird things happen or the 
            // app can crash. 
            //
            // To sumarize DO NOT dispatch a message inside this delegate's method. Do not trust UIKit.
            isPopingTopController = true
            if let onPop = self.onPop {
                onControllerDidShow = onPop
            } else if let action = currentNavigationBarOnBack {
                onControllerDidShow = { self.internalMailbox.dispatch(message: action) }
            } else {
                onControllerDidShow = .none
            }
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     didShow viewController: UIViewController, animated: Bool) {
        onControllerDidShow?()
        onControllerDidShow = .none
        onPop = .none
        isPopingTopController = false
    }
    
}

extension PortalNavigationController: ContainerController {
    
    public func registerDisposer(for identifier: String, disposer: @escaping () -> Void) {
        disposers[identifier] = disposer
    }
    
}

fileprivate extension PortalNavigationController {
    
    fileprivate func render(buttonItem: NavigationBarButton<ActionType>) -> UIBarButtonItem {
        switch buttonItem {
            
        case .textButton(let title, let message):
            let button = UIBarButtonItem(title: title)
            button.onTap(dispatch: .action(message), to: internalMailbox)
            return button
            
        case .imageButton(let icon, let message):
            let button = UIBarButtonItem(icon: icon)
            button.onTap(dispatch: .action(message), to: internalMailbox)
            return button
            
        }
    }
    
    fileprivate func configureOnBackAction(for properties: NavigationBarProperties<ActionType>) {
        switch properties.onBack {
        case .some(.navigateToPreviousRoute):
            currentNavigationBarOnBack = .navigateToPreviousRouteAfterPop
        case .some(let onBack):
            currentNavigationBarOnBack = .action(onBack)
        default:
            currentNavigationBarOnBack = .navigateToPreviousRouteAfterPop
        }
    }
    
}

fileprivate var messageDispatcherAssociationKey = 0

fileprivate extension UIBarButtonItem {
    
    fileprivate convenience init(title: String) {
        self.init(title: title, style: .plain, target: nil, action: nil)
    }
    
    fileprivate convenience init(icon: Image) {
        self.init(image: icon.asUIImage, style: .plain, target: nil, action: nil)
    }
    
    fileprivate func onTap<MessageType>(dispatch message: MessageType, to mailbox: Mailbox<MessageType>) {
        let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, dispatcher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.target = dispatcher
        self.action = dispatcher.selector
    }
    
}
