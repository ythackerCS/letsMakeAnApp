//
//  tabBarControllerViewController.swift
//  lettuce
//
//  Created by Yash Thacker on 4/5/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import UIKit

class tabBarControllerViewController: UITabBarController, UITabBarControllerDelegate{

    let middleButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        addStoreObj()
        
        self.delegate = self
//        UITabBar.appearance().backgroundColor = UIColor(red: 56/255, green: 81/255, blue: 62/255, alpha: 1.0)
//        UITabBar.appearance().tintColor = UIColor(red: 56/255, green: 81/255, blue: 62/255, alpha: 1.0)
//        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 77/255, green: 108/255, blue: 32/255, alpha: 1.0)
        UITabBar.appearance().tintColor = UIColor(red: 144/255, green: 206/255, blue: 158/255, alpha: 1.0)
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1.0)
        
        for items in self.tabBar.items!{
            items.imageInsets = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
            items.badgeColor = UIColor.systemRed
//            items.badgeValue = "1"
        }
        
        
        //how to do raised tab bar:https://equaleyes.com/blog/2017/09/04/the-common-raised-center-button-problems-in-tabbar/
        middleButton.frame.size = CGSize(width: 70, height: 50)
//        middleButton.backgroundColor = UIColor(red: 154/255, green: 206/255, blue: 0/255, alpha: 1.0)
        middleButton.backgroundColor = UIColor(red: 144/255, green: 206/255, blue: 158/255, alpha: 1.0)
        middleButton.layer.cornerRadius = 10
        middleButton.layer.masksToBounds = true
        middleButton.center = CGPoint(x: tabBar.frame.width / 2, y: 20)
        let imageContainer = UIImageView.init()
        imageContainer.frame.size = CGSize(width: 45, height: 35)
//        imageContainer.tintColor = UIColor(red: 77/255, green: 108/255, blue: 32/255, alpha: 1.0)
//        imageContainer.tintColor = UIColor.white
        imageContainer.tintColor = UIColor.systemBackground
        imageContainer.center = CGPoint(x: middleButton.frame.width/2, y: middleButton.frame.height/2)
        imageContainer.image = UIImage(systemName: "plus")
        middleButton.addSubview(imageContainer)
        middleButton.addTarget(self, action: #selector(test), for: .touchUpInside)
        tabBar.addSubview(middleButton)
        
        tabBar.bringSubviewToFront(middleButton)
        
    }
    
    
//    func addStoreObj() {
//        var store = CustomTabBarSize()
//        store.delegate2 = self // IMPORTANT
//        self.view.addSubview(store)
//    }
//
//    func didPressButton(button:UIButton) {
//        self.performSegue(withIdentifier: "showEvent", sender: nil)
//    }
//
    
    //https://stackoverflow.com/questions/30505165/uiview-touch-event-in-controller add gesture to view
    @objc func test(){
        self.performSegue(withIdentifier: "showEvent", sender: tabBarControllerViewController.self)
    }
    
//    func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//           if tabBar.isHidden {
//               return tabBar.hitTest(point, with: event)
//           }
//
//           let from = point
//           let to = middleButton.center
//
//           return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? middleButton : super.hitTest(point, with: event)
//       }

}
