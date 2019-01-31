//
//  CardView.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/15/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit
import SDWebImage

protocol CardViewDelegate {
    func didTapInfoButton(cardViewModel: CardViewModel)
}

class CardView: UIView {

    var delegate: CardViewDelegate?
    
    var cardViewModel: CardViewModel! {
        didSet {
            let firstImageURL = cardViewModel.imageURLs.first ?? ""
            if let url = URL(string: firstImageURL) {
                imageView.sd_setImage(with: url)
            }
            
            informationLabel.attributedText = cardViewModel.attributedText
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            if cardViewModel.imageURLs.count > 1 {
                (0..<cardViewModel.imageURLs.count).forEach { (index) in
                    if cardViewModel.imageURLs[index] != "" {
                        let barView = UIView()
                        barView.layer.cornerRadius = 2
                        barView.backgroundColor = barDeselectedColor
                        barStackView.addArrangedSubview(barView)
                        barStackView.arrangedSubviews.first?.backgroundColor = .white
                    }
                }
            } else {
                barStackView.isHidden = true
            }
            
            setupImageIndexObserver()
        }
    }
    
    fileprivate func  setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [unowned self] (index, imageURL) in
            // [unowned self] is to prevent retain cycle
            guard self.cardViewModel.imageURLs.count > 1 else { return }
            
            guard let imageURL = imageURL else { return }
            if let url = URL(string: imageURL) {
                self.imageView.sd_setImage(with: url)
            }
            
            self.barStackView.arrangedSubviews.forEach({ (view) in
                view.backgroundColor = self.barDeselectedColor
            })
            
            self.barStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
        
    // Configurations
    fileprivate let threshold: CGFloat = 100
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    
    fileprivate let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    fileprivate let gradientLayer = CAGradientLayer()
    
    fileprivate let informationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .heavy)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate let infoButton: UIButton = {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleShowInfo), for: .touchUpInside)
        return button
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func handleShowInfo() {
        delegate?.didTapInfoButton(cardViewModel: self.cardViewModel)
    }
    
    fileprivate func setupLayout() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        addSubview(imageView)
        imageView.fillSuperview()
        
        setupIndicatorBarStackView()
        
        setupGradientLayer()
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 0))
        
        addSubview(infoButton)
        infoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
    }
    
    fileprivate let barStackView = UIStackView()
    
    fileprivate func setupIndicatorBarStackView() {
        addSubview(barStackView)
        barStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 5, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 3))
        barStackView.spacing = 4
        barStackView.distribution = .fillEqually
    }
    
    fileprivate func setupGradientLayer() {
        
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.2]
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = self.frame
    }
    
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            ()
        }
    }
    
    var imageIndex = 0
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldGoAdvance = tapLocation.x > frame.width / 2 ? true : false
        
        if shouldGoAdvance {
            cardViewModel.goToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: nil)
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        
        let rotationTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold

        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            
            if shouldDismissCard {
                self.frame = CGRect(x: 600 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
            } else {
                self.transform = .identity
            }
            
        }) { (_) in
//            self.transform = .identity
            if shouldDismissCard {
                self.removeFromSuperview()
            }
//            self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.width, height: self.superview!.frame.height)

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
