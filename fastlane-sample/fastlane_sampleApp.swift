//
//  fastlane_sampleApp.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2021/12/17.
//

import SwiftUI
import Firebase
import GoogleMaps
import FloatingPanel

@main
struct fastlane_sampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        let mapView = GMSMapView(frame: .zero)
        WindowGroup {
            ContentView(mapView: mapView, contentViewModel: ContentViewModel(mapView: mapView)).floatingPanel(delegate: SearchPanelPhoneDelegate(), { proxy in
                FloatingPanelContentView(proxy: proxy)
            })
                .onAppear {
                let db = Firestore.firestore()
                db.collection("users").document("KOLyuInP6CVcM4GfZlmc").getDocument { snapshot, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    print(snapshot?.data() as Any)
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let googleMapsApiKey = KeyManager.getValue(key: "GoogleMapsApiKey") as? String {
            GMSServices.provideAPIKey(googleMapsApiKey)
        }
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error \(error)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var readableToken: String = ""
        for i in 0..<deviceToken.count {
            readableToken += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("Received an APNs device token: \(readableToken)")
    }
}

extension AppDelegate: MessagingDelegate {
    @objc func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase token: \(String(describing: fcmToken))")
         let dataDict:[String: String] = ["token": fcmToken ?? ""]
         NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14, *) {
            completionHandler([[.banner, .list, .sound]])
        } else {
            completionHandler([[.alert, .sound]])
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo
        )
        completionHandler()
    }
}

final class SearchPanelPhoneDelegate: FloatingPanelControllerDelegate {
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        if vc.position == .full {
            print("full")
        }
    }
}

