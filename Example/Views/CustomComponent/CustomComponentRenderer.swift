//
//  CustomComponentRenderer.swift
//  PortalExample
//
//  Created by Guido Marucci Blas on 6/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

final class CustomComponentRenderer: UIKitCustomComponentRenderer {
    
    typealias Action = Portal.Action<Route, Message>
    
    static private var cachedController: CustomController?
    
    private let container: ContainerController
    
    init(container: ContainerController) {
        print("Creating custom renderer")
        self.container = container
    }
    
    public func renderComponent(_ componentDescription: CustomComponentDescription, inside view: UIView, dispatcher: @escaping (Action) -> Void) {
        
    }
    
    func apply(changeSet: CustomComponentChangeSet, inside view: UIView, dispatcher: @escaping (Action) -> Void) {
        print("Applying change set for custom component")
        guard changeSet.newCustomComponent.identifier == "MyCustomComponent" || changeSet.newCustomComponent.identifier == "MyCustomComponent2" else { return }
        
        if changeSet.newCustomComponent.identifier == "MyCustomComponent" {
            print("Rendering MyCustomComponent")
            let bundle = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)
            if let customView = bundle?.last as? CustomView {
                customView.onTap = { dispatcher(.sendMessage(.increment)) }
                customView.frame = CGRect(origin: .zero, size: view.frame.size)
                view.addSubview(customView)
            }
        } else {
            print("Rendering MyCustomComponent2")
            if let cachedController = CustomComponentRenderer.cachedController {
                print("Using cached version of the custom controller")
                cachedController.onTap = { dispatcher(.sendMessage(.increment)) }
                view.addSubview(cachedController.view)
            } else {
                print("Creating new instance of custom controller")
                let frame = CGRect(origin: .zero, size: view.frame.size)
                let controller = CustomController(frame: frame, onTap: { dispatcher(.sendMessage(.increment)) })
                container.attachChildController(controller)
                view.addSubview(controller.view)
                
                container.registerDisposer(for: "MyCustomComponent2") {
                    print("Removing custom controller cache")
                    CustomComponentRenderer.cachedController = .none
                }
                CustomComponentRenderer.cachedController = controller
            }
        }
    }
    
}

func myCustomComponent(layout: Layout) -> Component<ExampleApplication.Action> {
    return .custom(CustomComponent(identifier: "MyCustomComponent"), EmptyStyleSheet.default, layout)
}

func myCustomComponent2(layout: Layout) -> Component<ExampleApplication.Action> {
    return .custom(CustomComponent(identifier: "MyCustomComponent"),  EmptyStyleSheet.default, layout)
}
