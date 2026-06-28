import UIKit

  @main
  class AppDelegate: UIResponder, UIApplicationDelegate {

      var window: UIWindow?

      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          window = UIWindow(frame: UIScreen.main.bounds)
          let loginVC = LoginViewController()
          let nav = UINavigationController(rootViewController: loginVC)
          nav.setNavigationBarHidden(true, animated: false)
          window?.rootViewController = nav
          window?.makeKeyAndVisible()
          Logger.shared.log("App launched")
          return true
      }
  }
  