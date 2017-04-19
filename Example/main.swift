import UIKit
import PortalApplication

let application = ExampleApplication()
let statePersistor = StatePersistor<Command, ExampleSerializer>(serializer: ExampleSerializer()) { state, message, transition in
    if case .uninitialized = state {
        return false
    }
    if case .stateLoaded(_) = message {
        return false
    }
    return true
}
let commandExecutor = ExampleCommandExecutor {
    statePersistor.restoreState { application.update(state: $0, message: $1)?.0 }
}
let context = UIKitApplicationContext(
    application: application,
    commandExecutor: commandExecutor,
    subscriptionManager: ExampleSubscriptionManager(),
    customComponentRenderer: CustomComponentRenderer()
)


context.registerMiddleware(statePersistor)
context.registerMiddleware(TimeLogger { print("M - Logger: \($0)") })

// Uncomment this line to clear all persisted state
//statePersistor.clear()

PortalUIApplication.start(applicationContext: context) { message in
    switch message {
    case .didFinishLaunching(_, _):
        return .applicationStarted
    default:
        return .none
    }
}
