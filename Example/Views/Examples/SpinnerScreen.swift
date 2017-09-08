//
//  SpinnerScreen.swift
//  PortalExample
//
//  Created by Argentino Ducret on 9/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum SpinnerScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view() -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Spinner")),
            component: container(
                children: [
                    createSpinner(isActive: true),
                    createSpinner(isActive: false)
                ],
                style: styleSheet {
                    $0.backgroundColor = .black
                },
                layout: layout {
                    $0.flex = flex() { $0.grow = .one }
                }
            )
        )
    }
    
}

// MARK: - Private Methods

fileprivate extension SpinnerScreen {
    
    fileprivate static func createSpinner(isActive: Bool) -> Component<Action> {
        return spinner(
            isActive: isActive,
            style: spinnerStyleSheet { base, spinner in
                base.backgroundColor = .black
                spinner.color = .red
            },
            layout: layout {
                $0.justifyContent = .center
                $0.alignment = alignment { $0.`self` = .center }
            }
        )
    }
    
}
