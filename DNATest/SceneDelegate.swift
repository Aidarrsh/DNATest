//
//  SceneDelegate.swift
//  DNATest
//
//  Created by Айдар Шарипов on 6/9/25.
//

import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = LoginViewController()
        window?.makeKeyAndVisible()
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "870028129733-e34u6odg1kadji4ob9cb2mejf8kboejj.apps.googleusercontent.com")
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}
