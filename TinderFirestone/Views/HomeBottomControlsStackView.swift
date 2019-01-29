//
//  HomeBottomControlsStackView.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/15/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {
    
    let refreshButton = createButton(img: #imageLiteral(resourceName: "refresh_circle"))
    let dislikeButton = createButton(img: #imageLiteral(resourceName: "dismiss_circle"))
    let superLikeButton = createButton(img: #imageLiteral(resourceName: "super_like_circle"))
    let likeButton = createButton(img: #imageLiteral(resourceName: "like_circle"))
    let specialButton = createButton(img: #imageLiteral(resourceName: "boost_circle"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].forEach { (button) in
            addArrangedSubview(button)
        }
        
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    static func createButton(img: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
