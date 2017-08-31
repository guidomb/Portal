//
//  ImageScreen.swift
//  PortalExample
//
//  Created by Argentino Ducret on 8/31/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum ImageScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view() -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Collection")),
            component: container(
                children: [
                    imageView(
                        image: Image.loadImage(named: "test")!,
                        layout: layout {
                            $0.height = Dimension(value: 50)
                            $0.width = Dimension(value: 50)
                        }
                    )
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

