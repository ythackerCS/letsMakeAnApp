//
//  CustomTabBarSize.swift
//  lettuce
//
//  Created by Yash Thacker on 4/6/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import UIKit

class CustomTabBarSize: UITabBar {
    

//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//         var size = super.sizeThatFits(size)
//         size.width = 50
//         return size
//    }
//    
//    var viecon = tabBarControllerViewController.self
//    var middleButton = UIButton()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupMiddleButton()
//    }
//
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if self.isHidden {
//            return super.hitTest(point, with: event)
//        }
//        
//        let from = point
//        let to = middleButton.center
//
//        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? middleButton : super.hitTest(point, with: event)
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
//    }
//    
//    func setupMiddleButton() {
//       middleButton.frame.size = CGSize(width: 70, height: 60)
//        middleButton.backgroundColor = UIColor(red: 154/255, green: 206/255, blue: 0/255, alpha: 1.0)
//        middleButton.layer.cornerRadius = 10
//        middleButton.layer.masksToBounds = true
//        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 15)
//        middleButton.addTarget(self, action: #selector(self.test), for: .touchUpInside)
//        let imageContainer = UIImageView.init()
//        imageContainer.frame.size = CGSize(width: 45, height: 35)
//        imageContainer.tintColor = UIColor(red: 77/255, green: 108/255, blue: 32/255, alpha: 1.0)
//        imageContainer.center = CGPoint(x: middleButton.frame.width/2, y: middleButton.frame.height/2)
//        imageContainer.image = UIImage(systemName: "plus")
//        middleButton.addSubview(imageContainer)
//        addSubview(middleButton)
//        
//    }
//  
//    @objc func test() {
//        
//    }
}
