//
//  AppDelegate.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 07/11/22.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging
import WellnestBLE
import SwinjectStoryboard
import SDWebImage
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true
        
        registerForPushNotifications()
        
//        SDImageCache.shared.clear(with: .all)
        
        Configuration.ApiUrl = AppConfiguration.baseURLPath
        Configuration.ApiKey = AppConfiguration.apiKey
        Configuration.ApiPassword = AppConfiguration.apiPassword
        
        return true
        
    }
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if granted {
                    
                    //                        let notifCategory = UNNotificationCategory(identifier: "category", actions: [], intentIdentifiers: [], options: [])
                    //                        // #1.2 - Register the notification type.
                    //
                    //                        unCenter.setNotificationCategories([notifCategory])
                    
                } else {
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        guard settings.authorizationStatus == .authorized else {
                            self.showPermissionAlert()
                            return
                        }
                    }
                    return
                }
                
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func showPermissionAlert() {
        UIAlertUtil.alertWith(title: "WARNING", message: "Please enable access to Notifications in the Settings app.", OkTitle: "Settings", cancelTitle: "Cancel", viewController: self.window!.rootViewController!) { (index) in
            if index == 1 {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (_) in })
                }
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let notifData = response.notification.request.content.userInfo as? [String : Any] {
            if let recordingId = Int((notifData["ECGRecordingId"] as? String) ?? "0") {
                if let navigationController = self.window?.rootViewController as? UINavigationController {
                    var viewControllerList = [UIViewController]()
                    
                    var storyboard = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: Initializers.shared.container)
                    let homeVC = storyboard.instantiateViewController(withIdentifier: String.init(describing: HomeViewController.self)) as! HomeViewController
                    viewControllerList.append(homeVC)
                    
                    storyboard = SwinjectStoryboard.create(name: "Recording", bundle: Bundle.main, container: Initializers.shared.container)
                    let recordVC = storyboard.instantiateViewController(withIdentifier: String.init(describing: RecordingPreviewViewController.self)) as! RecordingPreviewViewController
                    recordVC.pageType = .analysisReceived
                    recordVC.recording?.id = recordingId
                    viewControllerList.append(recordVC)
                    
                    navigationController.setViewControllers(viewControllerList, animated: true)
                    
                }
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let nav = window?.rootViewController as? UINavigationController {
            if (nav.visibleViewController?.isKind(of: HomeViewController.self) ?? true) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadEventsHome"), object: nil)
            }
        }
    }
}
extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
        UserDefaults.standard.setFCMToken(fcmToken: fcmToken)
    }
    //  [END refresh_token]
}
