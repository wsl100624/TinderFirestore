//
//  CardViewModel.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/15/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit

protocol ProduceCardViewModel {
    func toCardViewModel() -> CardViewModel
}


// View Model should represent the State of the View
class CardViewModel {
    
    // Properties that are View will display
    let imageURLs: [String]
    let attributedText: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(imageNames: [String], attributedText: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageURLs = CardViewModel.deleteEmptyImageURLs(imageNames: imageNames)
        self.attributedText = attributedText
        self.textAlignment = textAlignment
    }
    
    static func deleteEmptyImageURLs(imageNames: [String]) -> [String] {
        var newImageURLs = [String]()
        
        imageNames.forEach { (url) in
            if url != "" {
                newImageURLs.append(url)
            }
        }
        return newImageURLs
    }
    
    // MARK: Reactive Programming
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageURL = imageURLs[imageIndex]
            imageIndexObserver?(imageIndex, imageURL)
        }
    }
    
    var imageIndexObserver: ((Int, String?) ->())?
    
    func goToNextPhoto() {
        imageIndex = min(imageURLs.count - 1, imageIndex + 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}

