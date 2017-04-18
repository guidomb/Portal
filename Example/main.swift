import UIKit
import PortalApplication

PortalUIApplication.start(
    application: ExampleApplication(),
    commandExecutor: ExampleCommandExecutor(),
    subscriptionManager: ExampleSubscriptionManager(),
    customComponentRenderer: CustomComponentRenderer()) { message in
    switch message {
    case .didFinishLaunching(_, _):
        return .applicationStarted
    default:
        return .none
    }
}
