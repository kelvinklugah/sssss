import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor(red: 0.024, green: 0.063, blue: 0.098, alpha: 1.0)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
