//
//  Spinner.swift
//  PortalView
//
//  Created by Cristian Ames on 4/21/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

public func spinner<MessageType>(
    isActive: Bool = false,
    style: StyleSheet<SpinnerStyleSheet> = SpinnerStyleSheet.defaultStyleSheet,
    layout: Layout = layout()) -> Component<MessageType> {
    return .spinner(isActive, style, layout)
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
        isActive: Bool,
        style: StyleSheet<SpinnerStyleSheet>,
        layout: Layout) -> SpinnerChangeSet {
        return SpinnerChangeSet(
            isActive: PropertyChange.change(to: isActive),
            baseStyleSheet: style.base.fullChangeSet,
            spinnerStyleSheet: style.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let isActive: PropertyChange<Bool>
    let baseStyleSheet: [BaseStyleSheet.Property]
    let spinnerStyleSheet: [SpinnerStyleSheet.Property]
    let layout: [Layout.Property]
    
    var isEmpty: Bool {
        guard case .noChange = isActive else { return false }
        return  baseStyleSheet.isEmpty      &&
                spinnerStyleSheet.isEmpty   &&
                layout.isEmpty
    }

    init(
        isActive: PropertyChange<Bool> = .noChange,
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        spinnerStyleSheet: [SpinnerStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.isActive = isActive
        self.baseStyleSheet = baseStyleSheet
        self.spinnerStyleSheet = spinnerStyleSheet
        self.layout = layout
    }
    
}
