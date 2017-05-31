//
//  Progress.swift
//  PortalView
//
//  Created by Cristian Ames on 4/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

public struct ProgressCounter {
    
    public static let initial = ProgressCounter()
    
    public var partial: UInt
    public let total: UInt
    public var progress: Float {
        return Float(partial) / Float(total)
    }
    public var remaining: UInt {
        return total - partial
    }
    
    private init() {
        partial = 0
        total = 1
    }
    
    public init?(partial: UInt, total: UInt) {
        guard partial <= total else { return nil }
        
        self.partial = partial
        self.total = total
    }
    
    public func add(progress: UInt) -> ProgressCounter? {
        return ProgressCounter(partial: partial + progress, total: total)
    }
    
}

public func progress<MessageType>(
    progress: ProgressCounter = ProgressCounter.initial,
    style: StyleSheet<ProgressStyleSheet> = ProgressStyleSheet.defaultStyleSheet,
    layout: Layout = layout()) -> Component<MessageType> {
    return .progress(progress, style, layout)
}

// MARK:- Style sheet

public enum ProgressContentType {
    
    case color(Color)
    case image(Image)
    
}

public struct ProgressStyleSheet {
    
    public static let defaultStyleSheet = StyleSheet<ProgressStyleSheet>(component: ProgressStyleSheet())
    
    public var progressStyle: ProgressContentType
    public var trackStyle: ProgressContentType
    
    public init(
        progressStyle: ProgressContentType = .color(defaultProgressColor),
        trackStyle: ProgressContentType = .color(defaultTrackColor)) {
        self.progressStyle = progressStyle
        self.trackStyle = trackStyle
    }
    
}

public func progressStyleSheet(configure: (inout BaseStyleSheet, inout ProgressStyleSheet) -> ()) -> StyleSheet<ProgressStyleSheet> {
    var base = BaseStyleSheet()
    var custom = ProgressStyleSheet()
    configure(&base, &custom)
    return StyleSheet(component: custom, base: base)
}
