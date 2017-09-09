//
//  LabelScreen.swift
//  Portal
//
//  Created by Pablo Giorgi on 9/7/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum LabelScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view() -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Label")),
            component: container(
                children: [
                ],
                style: styleSheet {
                    $0.backgroundColor = .white
                },
                layout: layout {
                    $0.flex = flex() { $0.grow = .one }
                }
            )
        )
    }
    
}

