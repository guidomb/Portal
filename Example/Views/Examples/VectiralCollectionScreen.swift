//
//  CollectionScreen.swift
//  Portal
//
//  Created by Argentino Ducret on 8/29/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Portal

enum VerticalCollectionScreen {
    
    typealias Action = Portal.Action<Route, Message>
    typealias View = Portal.View<Route, Message, Navigator>
    
    static func view(color: Color, searching: Bool, showFullName: Bool) -> View {
        return View(
            navigator: .main,
            root: .stack(navigationBar()),
            component: container(
                children: [
                    collection(
                        properties: properties(
                            itemsWidth: 150,
                            itemsHeight: 150
                        ) {
                            let items: [CollectionItemProperties<Action>] = (0...1000).map { index in
                                collectionItem(onTap: .none, identifier: "Item \(index)") {
                                    return container(
                                        children: [
                                            label(text: showFullName ? "Item \(index)" : "\(index)")
                                        ],
                                        style: styleSheet { $0.backgroundColor = .red },
                                        layout: layout {
                                            $0.height = Dimension(value: 150)
                                            $0.width = Dimension(value: 150)
                                            $0.alignment = Alignment(items: .center)
                                            $0.justifyContent = .center
                                        }
                                    )
                                }
                            }
                            
                            let refreshState: RefreshState<Action> = searching ? .searching : .idle(searchAction: .sendMessage(.search))
                            
                            let refreshProperties: RefreshProperties<Action> = properties(state: refreshState) {
                                let title = NSAttributedString(string: "Collection refresh")
                                $0.title = title
                            }
                            
                            $0.items = items
                            $0.minimumLineSpacing = 5
                            $0.minimumInteritemSpacing = 5
                            $0.scrollDirection = .vertical
                            $0.refresh = refreshProperties
                        },
                        style: collectionStyleSheet { base, collection in
                            base.backgroundColor = color
                        },
                        layout: layout {
                            $0.flex = flex { $0.grow = .one }
                        }
                    )
                ],
                style: styleSheet() {
                    $0.backgroundColor = .green
                },
                layout: layout() {
                    $0.flex = flex() {
                        $0.grow = .one
                    }
                }
            )
        )
    }
    
    static func navigationBar() -> NavigationBar<Action> {
        return Portal.navigationBar(
            properties: properties() {
                $0.title = .text("Vertical Collection")
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
