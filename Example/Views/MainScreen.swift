//
//  MainView.swift
//  PortalExample
//
//  Created by Guido Marucci Blas on 6/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum MainScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func alert() -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Root")),
            alert: AlertProperties(
                title: "Hello!",
                text: "This is an alert",
                button: AlertProperties<Action>.Button(title: "OK")
            )
        )
    }
    
    static func mainView(date: Date?) -> View {
        return view(for:  container(
                children: [
                    button(
                        text: "Replace content",
                        onTap: .sendMessage(.replaceContent),
                        style: buttonStyleSheet { base, button in
                            base.backgroundColor = .red
                            button.textColor = .white
                        },
                        layout: layout() {
                            $0.margin = .by(edge: edge() {
                                $0.top = 30
                            })
                        }
                    ),
                    button(
                        text: "Present modal",
                        onTap: .navigate(to: .modal),
                        style: buttonStyleSheet { base, button in
                            base.backgroundColor = .green
                            button.textColor = .white
                        }
                    ),
                    button(
                        text: "Present detail",
                        onTap: .navigate(to: .detail),
                        style: buttonStyleSheet { base, button in
                            base.backgroundColor = .blue
                            button.textColor = .white
                        }
                    ),
                    button(
                        text: "Present modal landscape",
                        onTap: .navigate(to: .landscape),
                        style: buttonStyleSheet { base, button in
                            base.backgroundColor = .green
                            button.textColor = .white
                        }
                    ),
                    button(
                        text: "Present examples",
                        onTap: .navigate(to: .examples),
                        style: buttonStyleSheet { base, button in
                            base.backgroundColor = .blue
                            button.textColor = .white
                        }
                    ),
                    touchable(
                        gesture: .tap(message: .navigate(to: .modal)),
                        child: container(
                            children: [],
                            style: styleSheet() {
                                $0.backgroundColor = .yellow
                            },
                            layout: layout() {
                                $0.width = Dimension(value: 50)
                                $0.height = Dimension(value: 50)
                            }
                        )
                    ),
                    label(text: date?.description ?? "Unknown date"),
                    segmented(
                        segments: ZipList(
                            left: [segment(title: "First", onTap: .sendMessage(.pong("First")))],
                            center: segment(title: "Second", onTap: .sendMessage(.pong("Second"))),
                            right: [segment(title: "Third", onTap: .sendMessage(.pong("Third")))]
                        )
                    ),
                    myCustomComponent(layout: layout() {
                        $0.width = Dimension(value: 100)
                        $0.height = Dimension(value: 100)
                    })
                ],
                style: styleSheet() {
                    $0.backgroundColor = .gray
                },
                layout: layout() {
                    $0.flex = flex() {
                        $0.grow = .one
                    }
                }
            )
        )
    }
    
    static func replacedContent() -> View {
        return view(for: container(
                children: [
                    label(text: "Button pressed"),
                    button(
                        text: "Go back",
                        onTap: .sendMessage(.goToRoot),
                        style: buttonStyleSheet { base, button in
                            base.backgroundColor = .green
                            button.textColor = .white
                        }
                    )
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
    
    private static func view(for component: Component<Action>) -> View {
        return View(
            navigator: .main,
            root: .stack(ExampleApplication.navigationBar(title: "Root")),
            component: component
        )
    }
    
}
