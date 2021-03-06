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
        let textViewProperties: TextViewProperties = properties {
            $0.text = .regular("This is a TextView!")
            $0.isScrollEnabled = false
        }
        
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Text View")),
            component: container(
                children: [
                    textView(
                        properties: textViewProperties,
                        style: textViewStyleSheet { base, textView in
                            base.backgroundColor = .white
                            textView.textColor = .red
                            textView.textAlignment = .center
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

