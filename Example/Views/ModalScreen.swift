//
//  ModalScreen.swift
//  PortalExample
//
//  Created by Guido Marucci Blas on 6/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum ModalScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view(counter: UInt) -> View {
        let modalButtonStyleSheet = buttonStyleSheet { base, button in
            base.backgroundColor = .green
            button.textColor = .white
        }
        return View(
            navigator: .modal,
            root: .stack(ExampleApplication.navigationBar(title: "Modal")),
            component: container(
                children: [
                    label(text: "Modal screen"),
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
                    ),
                    button(
                        text: "Close and present detail",
                        onTap: .dismissNavigator(thenSend: .navigate(to: .detail)),
                        style: modalButtonStyleSheet
                    ),
                    button(
                        text: "Close",
                        onTap: .dismissNavigator(thenSend: .none),
                        style: modalButtonStyleSheet
                    ),
                    label(text: "Counter \(counter)"),
                    button(
                        text: "Increment!",
                        onTap: .sendMessage(.increment),
                        style: modalButtonStyleSheet
                    ),
                    button(
                        text: "Present modal landscape",
                        onTap: .navigate(to: .landscape),
                        style: buttonStyleSheet { base, button in
                            base.backgroundColor = .green
                            button.textColor = .white
                        }
                    ),
                    ],
                style: styleSheet() {
                    $0.backgroundColor = .red
                },
                layout: layout() {
                    $0.flex = flex() {
                        $0.grow = .one
                    }
                }
            )
        )
    }
    
}
