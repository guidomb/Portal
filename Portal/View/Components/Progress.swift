//
//  Progress.swift
//  PortalView
//
//  Created by Cristian Ames on 4/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

public struct ProgressCounter: AutoPropertyDiffable {
    
    internal static let initial = ProgressCounter()
    
    private var partial: UInt
    private let total: UInt
    
    public var progress: Float {
        return Float(partial) / Float(total)
    }
    
    private var remaining: UInt {
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

// MARK: - Style sheet

public enum ProgressContentType: AutoEquatable {
    
    case color(Color)
    case image(Image)
    
}

public struct ProgressStyleSheet: AutoPropertyDiffable {
    
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

public func progressStyleSheet(
    configure: (inout BaseStyleSheet, inout ProgressStyleSheet) -> Void) -> StyleSheet<ProgressStyleSheet> {
    var base = BaseStyleSheet()
    var custom = ProgressStyleSheet()
    configure(&base, &custom)
    return StyleSheet(component: custom, base: base)
}

// MARK: Change Set

internal struct ProgressChangeSet {
    
    static func fullChageSet(
        progressCounter: ProgressCounter,
        style: StyleSheet<ProgressStyleSheet>,
        layout: Layout) -> ProgressChangeSet {
        return ProgressChangeSet(
            progressCounter: progressCounter.fullChangeSet,
            baseStyleSheet: style.base.fullChangeSet,
            progressStyleSheet: style.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let progressCounter: [ProgressCounter.Property]
    let baseStyleSheet: [BaseStyleSheet.Property]
    let progressStyleSheet: [ProgressStyleSheet.Property]
    let layout: [Layout.Property]
    
    init(
        progressCounter: [ProgressCounter.Property] = [],
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        progressStyleSheet: [ProgressStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.progressCounter = progressCounter
        self.baseStyleSheet = baseStyleSheet
        self.progressStyleSheet = progressStyleSheet
        self.layout = layout
    }
    
}
