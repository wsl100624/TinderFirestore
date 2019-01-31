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
        
        setupLayout()
        setupBlurEffectView()
        setupBottomButtons()
    }
        
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
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dismissButton = self.createButtons(image: #imageLiteral(resourceName: "dismiss_down_arrow"), selector: #selector(handleDismiss))
    lazy var favouriteButton = self.createButtons(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDismiss))
    lazy var likeButton = self.createButtons(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleDismiss))
    lazy var dontLikeButton = self.createButtons(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDismiss))
    
    

    fileprivate func createButtons(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill

        return button
    }
    
    
    
    fileprivate func setupBlurEffectView() {
        
        let blurEffect = UIBlurEffect(style: .regular)
        let effectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(effectView)
        effectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupBottomButtons() {
        
        let stackView = UIStackView(arrangedSubviews: [dontLikeButton, favouriteButton, likeButton])
        stackView.distribution = .fillEqually
        stackView.spacing = -20
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    
    @objc fileprivate func handleDismiss() {
        dismiss(animated: true)
    }
    
    fileprivate func setupLayout() {
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        scrollView.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: imageView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: nil, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 25), size: .init(width: 50, height: 50))
        dismissButton.centerYAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        let width = max(view.frame.width + changeY, view.frame.width)
        imageView.frame = CGRect(x: min(0,-changeY/2), y: min(0, -changeY), width: width, height: width)
    }

}
