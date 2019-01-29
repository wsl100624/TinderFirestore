//
//  Bindable.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/19/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping (T?) ->()) {
        self.observer = observer
    }
}
