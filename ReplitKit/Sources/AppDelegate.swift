import UIKit

  @main
  class AppDelegate: UIResponder, UIApplicationDelegate {
      var window: UIWindow?
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          window = UIWindow(frame: UIScreen.main.bounds)
          let nav = UINavigationController(rootViewController: BrowserViewController())
          nav.setNavigationBarHidden(false, animated: false)
          window?.rootViewController = nav
          window?.makeKeyAndVisible()
          Logger.shared.log("App launched")
          return true
      }
  }
  