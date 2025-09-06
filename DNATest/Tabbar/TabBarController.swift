//
//  TabBarController.swift
//  DNATest
//
//  Created by Айдар Шарипов on 6/9/25.
//


import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    let customButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.frame.size.height = 83
        tabBar.tintColor = .black
        tabBar.backgroundColor = .white
        tabBar.layer.borderColor = UIColor.gray.cgColor
        tabBar.layer.borderWidth = 0.19
        setupTabBar()
    }
    
    func setupTabBar() {
        
        let vc1 = MainViewController()
        vc1.tabBarItem = UITabBarItem(title: "Gifts", image: UIImage(named: "Gifts1")?.withAlignmentRectInsets(.init(top: 10, left: 0, bottom: 0, right: 0)), tag: 0)
        
        let vc2 = UIViewController()
        vc2.tabBarItem = UITabBarItem(title: "Gifts", image: UIImage(named: "Gifts2")?.withAlignmentRectInsets(.init(top: 10, left: 0, bottom: 0, right: 0)), tag: 0)
        
        let vc3 = UIViewController()
        vc3.tabBarItem = UITabBarItem(title: "Events", image: UIImage(named: "Events")?.withAlignmentRectInsets(.init(top: 10, left: 0, bottom: 0, right: 0)), tag: 0)
        
        let vc4 = UIViewController()
        vc4.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(named: "Cart")?.withAlignmentRectInsets(.init(top: 10, left: 0, bottom: 0, right: 0)), tag: 0)
        
        let vc5 = UIViewController()
        vc5.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Profile")?.withAlignmentRectInsets(.init(top: 10, left: 0, bottom: 0, right: 0)), tag: 0)
        
        viewControllers = [vc1, vc2, vc3, vc4, vc5]
    }

    func createVC(vc: UIViewController, itemName: String, itemImage: String) -> UINavigationController {
        
        let item = UITabBarItem(title: itemName, image: UIImage(named: itemImage)?.withAlignmentRectInsets(.init(top: 10, left: 0, bottom: 0, right: 0)), tag: 0)
        
        item.titlePositionAdjustment = .init(horizontal: 0, vertical: 0)
        
        let vc1 = UINavigationController(rootViewController: vc)
        vc1.tabBarItem = item
        
        return vc1
    }
}
