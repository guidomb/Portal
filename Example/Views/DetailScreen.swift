//
//  DetailScreen.swift
//  PortalExample
//
//  Created by Guido Marucci Blas on 6/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum DetailScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view(counter: UInt) -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Detail")),
            component: container(
                children: [
                    button(text: "Go back!", onTap: .navigateToPreviousRoute),
                    label(text: "Count \(counter)"),
                    button(text: "Increment!", onTap: .sendMessage(.increment)),
                    label(text: "Detail screen!"),
                    myCustomComponent2(layout: layout() {
                        $0.width = Dimension(value: 100)
                        $0.height = Dimension(value: 100)
                    })
                ],
                style: styleSheet() {
                    $0.backgroundColor = .green
                },
                layout: layout() {
                    $0.flex = flex() {
                        $0.grow = .one
                    }
                    $0.justifyContent = .flexEnd
                }
            )
        )
    }
    
}
