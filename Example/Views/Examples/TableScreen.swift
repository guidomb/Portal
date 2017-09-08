//
//  TableScreen.swift
//  Portal
//
//  Created by Argentino Ducret on 9/6/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum TableScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view(color: Color) -> View {
        let items: [TableItemProperties<Action>] = (0...1000).map { index in
            tableItem(height: 50, onTap: .none, selectionStyle: .none) { _ in
                TableItemRender(
                    component: container (
                        children: [
                            container(
                                children: [
                                    label(text: "Cell \(index)")
                                ],
                                style: styleSheet {
                                    $0.backgroundColor = .blue
                                },
                                layout: layout {
                                    $0.flex = flex { $0.grow = .one }
                                    $0.height = Dimension(value: 50)
                                    $0.alignment = alignment { $0.items = .center }
                                    $0.justifyContent = .center
                                    $0.margin = .by(edge: Edge(bottom: 5))
                                }
                            )
                        ],
                        style: styleSheet {
                            $0.backgroundColor = color
                        }
                    ),
                    typeIdentifier: "Cell \(index)"
                )
            }
        }
        
        return View(
            navigator: .main,
            root: .stack(navigationBar()),
            component: table(
                items: items,
                style: tableStyleSheet { base, table in
                    base.backgroundColor = .green
                },
                layout: layout {
                    $0.flex = flex { $0.grow = .one }
                }
            )
        )
    }
    
    static func navigationBar() -> NavigationBar<Action> {
        return Portal.navigationBar(
            properties: properties() {
                $0.title = .text("Table")
                $0.backButtonTitle = "test"
                $0.rightButtonItems = [
                    .textButton(title: "Color!", onTap: .sendMessage(.changeColor)),
                ]
            },
            style: navigationBarStyleSheet() { base, navBar in
                navBar.titleTextColor = .red
                navBar.isTranslucent = false
                navBar.tintColor = .red
                navBar.separatorHidden = true
                base.backgroundColor = .white
            }
        )
    }
    
}
