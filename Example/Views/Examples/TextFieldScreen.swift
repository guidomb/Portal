//
//  TextFieldExample.swift
//  PortalExample
//
//  Created by Argentino Ducret on 8/31/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum TextFieldScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view() -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Text Field")),
            component: container(
                children: [
                    textField(
                        properties: properties {
                            $0.text = "Example"
                            $0.placeholder = "Insert text..."
                        },
                        style: textFieldStyleSheet { base, textField in
                            base.backgroundColor = .white
                            textField.textSize = 20
                            textField.textColor = .blue
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
