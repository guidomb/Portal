//
//  TableRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

extension PortalTableView {

    func apply(changeSet: TableChangeSet<ActionType>, layoutEngine: LayoutEngine) -> Render<ActionType> {
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.tableStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)

        return Render<ActionType>(view: self, mailbox: mailbox, executeAfterLayout: .none)
    }

}

fileprivate extension PortalTableView {

    fileprivate func apply(changeSet: [TableProperties<ActionType>.Property]) {
        for property in changeSet {
            switch property {

            case .items(let items):
                setItems(items: items)
                reloadData()

            case .showsHorizontalScrollIndicator(let enabled):
                showsHorizontalScrollIndicator = enabled

            case .showsVerticalScrollIndicator(let enabled):
                showsVerticalScrollIndicator = enabled

            case .refresh(let maybeRefreshProperties):
                if let refreshProperties = maybeRefreshProperties {
                    self.configure(pullToRefresh: refreshProperties)
                } else {
                    self.removePullToRefresh()
                }

            }
        }
    }

    fileprivate func apply(changeSet: [TableStyleSheet.Property]) {
        for property in changeSet {
            switch property {

            case .separatorColor(let color):
                separatorColor = color.asUIColor

            case .refreshTintColor(let refreshTintColor):
                self.scrollView.refreshControl?.tintColor = refreshTintColor.asUIColor

            }
        }
    }

}

extension TableItemSelectionStyle {

    internal var asUITableViewCellSelectionStyle: UITableViewCellSelectionStyle {
        switch self {
        case .none:
            return .none
        case .`default`:
            return .`default`
        case .blue:
            return .blue
        case .gray:
            return .gray
        }
    }

}
