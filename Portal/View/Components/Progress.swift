//
//  Progress.swift
//  PortalView
//
//  Created by Cristian Ames on 4/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

public struct ProgressCounter {
    
    internal static let initial = ProgressCounter()
    
    // sourcery: ignoreInChangeSet
    public var partial: UInt
    // sourcery: ignoreInChangeSet
    public let total: UInt
    
    public var progress: Float {
        return Float(partial) / Float(total)
    }
    
    // sourcery: ignoreInChangeSet
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

public struct ProgressChangeSet {
    
    static func fullChangeSet(
        progress: ProgressCounter,
        style: StyleSheet<ProgressStyleSheet>,
        layout: Layout) -> ProgressChangeSet {
        return ProgressChangeSet(
            progress: .change(to: progress),
            baseStyleSheet: style.base.fullChangeSet,
            progressStyleSheet: style.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let progress: PropertyChange<ProgressCounter>
    let baseStyleSheet: [BaseStyleSheet.Property]
    let progressStyleSheet: [ProgressStyleSheet.Property]
    let layout: [Layout.Property]
    
    var isEmpty: Bool {
        guard case .noChange = progress else { return false }
        return  baseStyleSheet.isEmpty      &&
                progressStyleSheet.isEmpty  &&
                layout.isEmpty
    }
    
    init(
        progress: PropertyChange<ProgressCounter>,
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        progressStyleSheet: [ProgressStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.progress = progress
        self.baseStyleSheet = baseStyleSheet
        self.progressStyleSheet = progressStyleSheet
        self.layout = layout
    }
    
}
