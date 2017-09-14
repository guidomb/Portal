//
//  Spinner.swift
//  PortalView
//
//  Created by Cristian Ames on 4/21/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

public func spinner<MessageType>(
    style: StyleSheet<SpinnerStyleSheet> = SpinnerStyleSheet.defaultStyleSheet,
    layout: Layout = layout()) -> Component<MessageType> {
    return .spinner(style, layout)
}

public struct SpinnerStyleSheet: AutoPropertyDiffable {
    
    public static let defaultStyleSheet = StyleSheet<SpinnerStyleSheet>(component: SpinnerStyleSheet())
    
    public var color: Color
    
    public init(
        color: Color = .black) {
        self.color = color
    }
    
}

public func spinnerStyleSheet(
    configure: (inout BaseStyleSheet, inout SpinnerStyleSheet) -> Void) -> StyleSheet<SpinnerStyleSheet> {
    var base = BaseStyleSheet()
    var custom = SpinnerStyleSheet()
    configure(&base, &custom)
    return StyleSheet(component: custom, base: base)
}

// MARK: - Change Set

public struct SpinnerChangeSet {
    
    static func fullChangeSet(
        style: StyleSheet<SpinnerStyleSheet>,
        layout: Layout) -> SpinnerChangeSet {
        return SpinnerChangeSet(
            baseStyleSheet: style.base.fullChangeSet,
            spinnerStyleSheet: style.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let baseStyleSheet: [BaseStyleSheet.Property]
    let spinnerStyleSheet: [SpinnerStyleSheet.Property]
    let layout: [Layout.Property]
    
    var isEmpty: Bool {
        return  baseStyleSheet.isEmpty      &&
                spinnerStyleSheet.isEmpty   &&
                layout.isEmpty
    }

    init(
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        spinnerStyleSheet: [SpinnerStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.baseStyleSheet = baseStyleSheet
        self.spinnerStyleSheet = spinnerStyleSheet
        self.layout = layout
    }
    
}
