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

public struct SpinnerStyleSheet {
    
    public static let defaultStyleSheet = StyleSheet<SpinnerStyleSheet>(component: SpinnerStyleSheet())
    
    public var color: Color
    
    public init(
        color: Color = .black) {
        self.color = color
    }
    
}

public func spinnerStyleSheet(
    configure: (inout BaseStyleSheet, inout SpinnerStyleSheet) -> ()) -> StyleSheet<SpinnerStyleSheet> {
    var base = BaseStyleSheet()
    var custom = SpinnerStyleSheet()
    configure(&base, &custom)
    return StyleSheet(component: custom, base: base)
}
