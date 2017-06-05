//
//  Timer.swift
//  Portal
//
//  Created by Guido Marucci Blas on 4/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public enum TimerUnit {
    
    case millisecond
    case second
    case minute
    
}

public enum TimerRepeat: Equatable {
    
    public static func ==(lhs: TimerRepeat, rhs: TimerRepeat) -> Bool {
        switch (lhs, rhs) {
        case (.forever, .forever):
            return true
        case (.times(let a), .times(let b)):
            return a == b
        default:
            return false
        }
    }
    
    case forever
    case times(UInt)
    
}

public struct Timer<MessageType, RouteType: Route>: Equatable {
    
    public static func ==<MessageType, RouteType: Route>(lhs: Timer<MessageType, RouteType>, rhs: Timer<MessageType, RouteType>) -> Bool {
        return lhs.value == rhs.value && lhs.unit == rhs.unit && lhs.repeats == rhs.repeats && lhs.tag == rhs.tag
    }
    
    public static func every<MessageType, RouteType: Route>(
        _ value: Double,
        unit: TimerUnit,
        tag: String? = .none,
        transform: @escaping (Date) -> Action<RouteType, MessageType>) -> Timer<MessageType, RouteType> {
        return Timer<MessageType, RouteType>(
            every: value,
            unit: unit,
            repeats: .forever,
            tag: tag,
            transform: transform
        )
    }
    
    public static func only<MessageType, RouteType: Route>(
        fire times: UInt,
        every value: Double,
        unit: TimerUnit,
        tag: String? = .none,
        transform: @escaping (Date) -> Action<RouteType, MessageType>) -> Timer<MessageType, RouteType> {
        return Timer<MessageType, RouteType>(
            every: value,
            unit: unit,
            repeats: .times(times),
            tag: tag,
            transform: transform
        )
    }
    
    let value: Double
    let unit: TimerUnit
    let repeats: TimerRepeat
    let transform: (Date) -> Action<RouteType, MessageType>
    let tag: String?
    
    var valueInSeconds: Double {
        switch unit {
        case .minute:
            return value * 60.0
        case .second:
            return value
        case .millisecond:
            return value / 1000.0
        }
    }
    
    init(every value: Double, unit: TimerUnit, repeats: TimerRepeat, tag: String?, transform: @escaping (Date) -> Action<RouteType, MessageType>) {
        self.value = value
        self.unit = unit
        self.repeats = repeats
        self.transform = transform
        self.tag = tag
    }
    
}

public final class TimerSubscriptionManager<MessageType, RouteType: Route>: SubscriptionManager {
    
    private struct ActiveTimer {
        
        let platformTimer: Foundation.Timer
        let timer: Portal.Timer<MessageType, RouteType>
        var counter: UInt = 0
        
        init(platformTimer: Foundation.Timer, timer: Portal.Timer<MessageType, RouteType>) {
            self.platformTimer = platformTimer
            self.timer = timer
        }
        
    }
    
    private var activeTimers: [UUID : ActiveTimer] = [:]
    
    public func add(subscription: Timer<MessageType, RouteType>, dispatch: @escaping (Action<RouteType, MessageType>) -> Void) {
        guard !activeTimers.values.contains(where: { $0.timer == subscription }) else { return }
        
        let uuid = UUID()
        let timer = Foundation.Timer(timeInterval: subscription.valueInSeconds, repeats: true) { timer in
            guard var activeTimer = self.activeTimers[uuid] else { return }
            dispatch(subscription.transform(Date()))
            activeTimer.counter += 1
            if case .times(let repeatTime) = activeTimer.timer.repeats, repeatTime == activeTimer.counter {
                timer.invalidate()
            } else {
                self.activeTimers[uuid] = activeTimer
            }
        }
        activeTimers[uuid] = ActiveTimer(platformTimer: timer, timer: subscription)
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    public func remove(subscription: Timer<MessageType, RouteType>) {
        guard let (uuid, activeTimer) = activeTimers.first(where: { $1.timer == subscription }) else { return }
        
        activeTimer.platformTimer.invalidate()
        activeTimers.removeValue(forKey: uuid)
    }
    
}
