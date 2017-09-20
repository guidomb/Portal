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
    
    static func view(color: Color, searching: Bool, showFullName: Bool) -> View {
        let margin: UInt = 5
        let items: [TableItemProperties<Action>] = (0...1000).map { index in
            tableItem(height: 55, onTap: .none, selectionStyle: .none) { height in
                TableItemRender(
                    component: container (
                        children: [
                            container(
                                children: [
                                    label(text: showFullName ? "Cell \(index)" : "\(index)")
                                ],
                                style: styleSheet {
                                    $0.backgroundColor = .blue
                                },
                                layout: layout {
                                    $0.flex = flex { $0.grow = .one }
                                    $0.height = Dimension(value: height - margin)
                                    $0.alignment = alignment { $0.items = .center }
                                    $0.justifyContent = .center
                                    $0.margin = .by(edge: Edge(bottom: margin))
                                }
                            )
                        ],
                        style: styleSheet {
                            $0.backgroundColor = color
                        },
                        layout: layout {
                            $0.height = Dimension(value: height)
                        }
                    ),
                    typeIdentifier: "Cell \(index)"
                )
            }
        }
        
        let refreshState: RefreshState<Action> = searching ? .searching : .idle(searchAction: .sendMessage(.search))
        
        let refreshProperties: RefreshProperties<Action> = properties(state: refreshState) {
            let title = NSAttributedString(string: "Table refresh")
            $0.title = title
        }
        
        let tableProperties: TableProperties<Action> = properties {
            $0.items = items
            $0.refresh = refreshProperties
        }
        
        return View(
            navigator: .main,
            root: .stack(navigationBar()),
            component: table(
                properties: tableProperties,
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
