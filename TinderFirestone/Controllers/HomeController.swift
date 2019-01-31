//
//  HomeController.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/15/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD


class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
    
    
    func didTapInfoButton(cardViewModel: CardViewModel) {
        let userDetailController = UserDetailController()
        userDetailController.cardViewModel = cardViewModel
        present(userDetailController, animated: true)
    }
    
    let topStackView = HomeTopControlStackView()
    let cardDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    fileprivate let hud = JGProgressHUD(style: .dark)

    var cardViewModels = [CardViewModel]()
    
    fileprivate var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        setupLayout()
        
        fetchCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser == nil {
            let registrationController = RegistrationController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
            present(navController, animated: true)
            
        }
    }
    
    func didFinishLogin() {
        fetchCurrentUser()
    }
    
    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "Loading..."
        hud.show(in: view)
        
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print("failed to fetch users: ", err)
                self.hud.dismiss()
                return
            }
            
            self.user = user
            self.fetchUsersFromFirestore()
        }
        
    }
    
    //MARK: Fileprivate
    @objc fileprivate func handleRefresh() {
        fetchUsersFromFirestore()
    }
    
    @objc fileprivate func handleSettings() {
        let settingController = SettingsController()
        settingController.delegate = self
        let navController = UINavigationController(rootViewController: settingController)
        present(navController, animated: true)
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    
    fileprivate func fetchUsersFromFirestore() {
        guard let minAge = user?.minSeekingAge, let maxAge = user?.maxSeekingAge else { return }
        
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        
        query.getDocuments { (snapshot, err) in
            self.hud.dismiss()
            if let err = err {
                print("failed to fetch users: ", err)
                return
            }
            
            snapshot?.documents.forEach({ (docSnapshot) in
                let userDictionary = docSnapshot.data()
                
                let user = User(dictionary: userDictionary)
                if user.uid != Auth.auth().currentUser?.uid {
                    self.setupCardFromUser(user: user)
                }
            })
        }
    }
    
    fileprivate func setupCardFromUser(user: User) {
        let cardView = CardView()
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
    }
    
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardDeckView, bottomControls])
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardDeckView)
    }
    
    

}

