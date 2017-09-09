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
                    label(
                        properties: properties(
                            text: "This is a label with fixed font size."
                        ),
                        style: labelStyleSheet { _, label in
                            label.textSize = 20
                            label.numberOfLines = 1
                        }
                    ),
                    label(
                        properties: properties(
                            text: "This is a label with fixed font size that won't fit and will be trimmed."
                        ),
                        style: labelStyleSheet { _, label in
                            label.textSize = 20
                            label.numberOfLines = 1
                        }
                    ),
                    label(
                        properties: properties(
                            text: "This is a label with fixed font size that may take multiple lines."
                        ),
                        style: labelStyleSheet { _, label in
                            label.textSize = 20
                            label.numberOfLines = 0
                        }
                    ),
                    label(
                        properties: properties(
                            text: "This is a label with fixed font size that will take more lines lines than allowed, event if multiple lines are allowed, so it will take multiple lines and will be trimmed."
                        ),
                        style: labelStyleSheet { _, label in
                            label.textSize = 20
                            label.numberOfLines = 2
                        }
                    ),
                    container(
                        children: [
                            verticalLabel(
                                text: "1000000",
                                textAfterLayout: "100000",
                                backgroundColor: .red
                            ),
                            verticalLabel(
                                text: "1000000",
                                textAfterLayout: "10000",
                                backgroundColor: .blue
                            ),
                            verticalLabel(
                                text: "1000000",
                                textAfterLayout: "1000",
                                backgroundColor: .green
                            ),
                            verticalLabel(
                                text: "1000000",
                                textAfterLayout: "100000",
                                backgroundColor: .yellow
                            ),
                            verticalLabel(
                                text: "1000000",
                                textAfterLayout: "100000",
                                backgroundColor: .gray
                            ),
                        ],
                        style: styleSheet() {
                            $0.backgroundColor = .blue
                        },
                        layout: layout() {
                            $0.flex = flex() {
                                $0.direction = .row
                            }
                            $0.height = Dimension(value: 100)
                        }
                    )
                ],
                style: styleSheet {
                    $0.backgroundColor = .white
                },
                layout: layout {
                    $0.flex = flex() {
                        $0.grow = .one
                    }
                }
            )
        )
    }
    
    private static func verticalLabel(text: String, textAfterLayout: String, backgroundColor: Color) -> Component<Action> {
        return label(
            properties: properties(
                text: text,
                textAfterLayout: textAfterLayout
            ),
            style: labelStyleSheet { base, label in
                base.backgroundColor = backgroundColor
                label.textSize = 25
                label.numberOfLines = 1
                label.adjustToFitWidth = true
                label.minimumScaleFactor = 0.1
            },
            layout: layout() {
                $0.flex = flex() {
                    $0.grow = .one
                }
                $0.width = Dimension(value: 10)
            }
        )
    }
    
}
