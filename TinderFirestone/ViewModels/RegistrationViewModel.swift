//
//  RegistrationViewModel.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/19/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var fullName: String? { didSet { checkFormValidity() } }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    func performRegistration(completion: @escaping (Error?) -> ()) {
        
        bindableIsRegistering.value = true
        
        guard let email = email, let password = password else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if let err = err {
                completion(err)
                return
            }
            
            print("Successful registered user: ", result?.user.uid ?? "")
            self.saveImageToFirebase(completion: completion)
        }
    }
    
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference().child("/images/\(fileName)")
        guard let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) else { return }
        ref.putData(imageData, metadata: nil, completion: { (_, err) in
            if let err = err {
                completion(err)
                return
            }
            
            print("Finished uploding image in storage...")
            ref.downloadURL(completion: { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                
                self.bindableIsRegistering.value = false
        
                let imageURL = url?.absoluteString ?? ""
                self.saveUserInfoToFirestore(imageURL: imageURL, completion: completion)
                
            })
        })
    }
    
    fileprivate func saveUserInfoToFirestore(imageURL: String, completion: @escaping (Error?) ->()) {
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = ["full name": fullName ?? "", "uid": uid, "imageURL1" : imageURL]
        
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
    
}
