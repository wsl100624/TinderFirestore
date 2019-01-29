//
//  UserDetailController.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/28/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit
import SDWebImage

class UserDetailController: UIViewController, UIScrollViewDelegate {
        
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "User Name \n25 \nLike to play basketball"
        label.numberOfLines = 0
        return label
    }()
    
    var cardViewModel: CardViewModel? {
        didSet {
            guard let firstImageURL = cardViewModel?.imageURLs.first, let url = URL(string: firstImageURL) else { return }
            imageView.sd_setImage(with: url)
            infoLabel.attributedText = cardViewModel?.attributedText
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        scrollView.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: imageView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        let width = max(view.frame.width + changeY, view.frame.width)
        imageView.frame = CGRect(x: min(0,-changeY/2), y: min(0, -changeY), width: width, height: width)
    }

}
