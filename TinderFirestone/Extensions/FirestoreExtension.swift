//
//  FirestoreExtension.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/26/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import Firebase

extension Firestore {
    
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> ()) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                completion(nil, err)
                return
            }
            
            guard let userDictionary = snapshot?.data() else { return }
            
            let user = User(dictionary: userDictionary)
            
            completion(user, nil)
        }
    }
    
}
