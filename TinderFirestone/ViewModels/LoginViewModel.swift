//
//  LoginViewModel.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/27/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit
import Firebase

class LoginViewModel {
    
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsLoggingIn = Bindable<Bool>()
    
    var email: String? { didSet {checkFormValidity()} }
    var password: String? { didSet {checkFormValidity()} }
    
    func performLogin(completion: @escaping (Error?) -> ()) {
        
        bindableIsLoggingIn.value = true
        
        guard let email = email, let password = password else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                completion(err)
            }
            completion(nil)
        }
    }
    
    func checkFormValidity() {
        let isFormValid = email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
}
