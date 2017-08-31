//
//  TextViewScreen.swift
//  PortalExample
//
//  Created by Argentino Ducret on 8/31/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum TextViewScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view() -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Collection")),
            component: container(
                children: [
                    textView(
                        text: "This is a text view!",
                        style: textViewStyleSheet { base, textView in
                            base.backgroundColor = .white
                            textView.textColor = .red
                            textView.textAligment = .center
                            textView.textFont = Font(name: "Helvetica")
                            textView.textSize = 18
                    })
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

