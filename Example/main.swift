import UIKit
import Portal

let context = UIKitApplicationContext(
    application: ExampleApplication(),
    commandExecutor: ExampleCommandExecutor(),
    subscriptionManager: ExampleSubscriptionManager(),
    rendererFactory: CustomComponentRenderer.init
)

//context.registerMiddleware(statePersistor)
context.registerMiddleware(TimeLogger { print("M - Logger: \($0)") })

PortalUIApplication.start(applicationContext: context) { message in
    switch message {
    case .didFinishLaunching(_, _):
        return .applicationStarted
    default:
        return .none
    }
}
