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
                    label(
                        properties: properties(
                            text: "Modal screen before layout",
                            textAfterLayout: "Modal screen after layout"
                        ),
                        style: labelStyleSheet { base, label in
                            base.backgroundColor = .clear
                            label.textSize = 20
                            label.textColor = .black
                        }
                    ),
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
                    label(
                        properties: properties(
                            text: "Modal screen before layout",
                            textAfterLayout: "Counter \(counter)"
                        ),
                        style: labelStyleSheet { base, label in
                            base.backgroundColor = .clear
                            label.textSize = 20
                            label.textColor = .black
                        }
                    ),
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
