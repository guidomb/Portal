//
//  StatePersistor.swift
//  Portal
//
//  Created by Guido Marucci Blas on 4/12/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public protocol StatePersistorSerializer {
    
    associatedtype StateType
    associatedtype MessageType
    
    func serialize(state: StateType) -> Data
    
    func serialize(message: MessageType) -> Data
    
    func deserializeState(from data: Data) -> StateType?
    
    func deserializeMessage(from data: Data) -> MessageType?
    
}

public final class StatePersistor<
    CommandType,
    StatePersistorSerializerType: StatePersistorSerializer>: MiddlewareProtocol {
    
    public typealias StateType = StatePersistorSerializerType.StateType
    public typealias MessageType = StatePersistorSerializerType.MessageType
    public typealias Transition = (StateType, CommandType?)?
    public typealias NextMiddleware = (StateType, MessageType, CommandType?) -> Transition
    public typealias TransitionFilter = (StateType, MessageType, Transition) -> Bool
    
    fileprivate var messagesCount: UInt = 0
    fileprivate let serializer: StatePersistorSerializerType
    fileprivate let messagesFileName = "messages.bin"
    fileprivate let stateFileName = "state.bin"
    fileprivate let shouldPersist: TransitionFilter
    
    private let dispatchQueue = DispatchQueue(label: "com.Portal.StatePersistor")
    
    public init(serializer: StatePersistorSerializerType, shouldPersist: @escaping TransitionFilter = { _ in true }) {
        self.serializer = serializer
        self.shouldPersist = shouldPersist
    }
    
    public func call(
        state: StateType,
        message: MessageType,
        command: CommandType?,
        next: NextMiddleware) -> Transition {
        
        guard let result = next(state, message, command) else { return .none }
        
        if shouldPersist(state, message, result) {
            dispatchQueue.async {
                self.persist(nextState: result.0, command: result.1, message: message)
            }
        }
        
        return result
    }
    
    public func restoreState(apply: @escaping (StateType, MessageType) -> StateType?) -> StateType? {
        print("StatePersistor - Restoring state ...")
        guard
            let baseDirectory = documentsDirectory(),
            let stateData = try? Data(contentsOf: baseDirectory.appendingPathComponent("state.bin")),
            let checkpoint = serializer.deserializeState(from: stateData),
            let messagesData = try? Data(contentsOf: baseDirectory.appendingPathComponent("messages.bin")),
            let messages = parseMessages(from: messagesData)
        else {
            print("StatePersistor - State could not be restored")
            return .none
        }
        
        print("StatePersistor - Previous state checkpoint restored. Applying \(messages.count) messages ...")
        messagesCount = UInt(messages.count)
        return messages.reduce(Optional.some(checkpoint)) { (maybeState, message) in
            maybeState.flatMap { apply($0, message) }
        }
    }
    
    public func clear() {
        guard let baseDirectory = documentsDirectory() else {
            // TODO should we do something about this?
            return
        }
        
        print("StatePersistor - Clearing persisted data ...")
        try? FileManager.default.removeItem(at: baseDirectory / messagesFileName)
        try? FileManager.default.removeItem(at: baseDirectory / stateFileName)
    }
    
}

extension StatePersistor {
    
    fileprivate func persist(nextState: StateType, command: CommandType?, message: MessageType) {
        guard let baseDirectory = documentsDirectory() else {
            // TODO should we do something about this?
            return
        }
        
        do {
            let messagesFile = baseDirectory / messagesFileName
            if messagesCount == 20 {
                print("StatePersistor - Saving checkpoint ...")
                let nextStateData = serializer.serialize(state: nextState)
                try nextStateData.write(to: baseDirectory / stateFileName)
                try Data().write(to: messagesFile)
                messagesCount = 0
            } else {
                let messageData = serializer.serialize(message: message)
                var messageDataSize = messageData.count
                var data = Data()
                data.append(UnsafeBufferPointer(start: &messageDataSize, count: 1))
                data.append(messageData)
                try append(data: data, to: messagesFile)
                messagesCount += 1
                print("StatePersistor - Transition saved. \(messagesCount) in messages journal")
            }
        } catch {
            print("ERROR: State transition could not be persisted")
            clear()
        }
        
    }
    
    fileprivate func append(data: Data, to file: URL) throws {
        guard let outputStream = OutputStream(url: file, append: true) else {
            throw StatePersistorError.unableToOpenFile(file)
        }
        
        outputStream.open()
        let writtenBytes = data.withUnsafeBytes {
            outputStream.write($0, maxLength: data.count)
        }
        if writtenBytes < data.count {
            throw StatePersistorError.writeFailure(data: data, writtenBytes: writtenBytes)
        }
        outputStream.close()
    }
    
    fileprivate func documentsDirectory() -> URL? {
        return try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
    
    fileprivate func parseMessages(from data: Data) -> [MessageType]? {
        var messages: Array<MessageType>? = []
        var currentOffset = 0
        var currentData = data
        
        while currentOffset < data.count {
            // We need to advance the data here because if we do it after
            // parsing the message, in the case of the last message an exception
            // is thrown because data cannot be advanced beyond its limits.
            currentData = data.advanced(by: currentOffset)
            let (messageSize, maybeMessage) = parseMessage(from: currentData)
            if let message = maybeMessage {
                messages?.append(message)
                currentOffset += MemoryLayout<Int>.size + messageSize
            } else {
                messages = .none
                break
            }
        }
        
        return messages
    }
    
    fileprivate func parseMessage(from data: Data) -> (Int, MessageType?) {
        return data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> (Int, MessageType?) in
            let messageSize = pointer.withMemoryRebound(to: Int.self, capacity: 1) { $0.pointee }
            let messagePointer = UnsafeBufferPointer(
                start: pointer.advanced(by: MemoryLayout<Int>.size),
                count: messageSize
            )
            let message = serializer.deserializeMessage(from: Data(buffer: messagePointer))
            return (messageSize, message)
        }
    }
    
}

fileprivate enum StatePersistorError: Error {
    
    case unableToOpenFile(URL)
    case writeFailure(data: Data, writtenBytes: Int)
    
}

fileprivate func /(lhs: URL, rhs: String) -> URL {
    return lhs.appendingPathComponent(rhs)
}
