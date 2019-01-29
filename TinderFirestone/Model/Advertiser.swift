//
//  Advertiser.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/15/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit

struct Advertiser: ProduceCardViewModel {
    let title: String
    let brandName: String
    let posterPhotoNames: [String]
    
    func toCardViewModel() -> CardViewModel {
        let attributedText = NSMutableAttributedString(string: title, attributes: [.font : UIFont.systemFont(ofSize: 34, weight: .heavy)])
        attributedText.append(NSAttributedString(string: "\n" + brandName, attributes: [.font : UIFont.systemFont(ofSize: 24, weight: .bold)]))
        
        
        return CardViewModel(imageNames: posterPhotoNames, attributedText: attributedText, textAlignment: .center)

    }
    
    
    
}

