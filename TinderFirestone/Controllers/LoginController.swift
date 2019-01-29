//
//  LoginController.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/27/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

protocol LoginControllerDelegate {
    func didFinishLogin()
}

class LoginController: UIViewController {
    
    var delegate: LoginControllerDelegate?
    
    let gradientLayer = CAGradientLayer()
    
    let goToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back to register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(handleGoToRegister), for: .touchUpInside)
        
        return button
    }()
    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Email"
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightGray
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.isEnabled = false
        
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    fileprivate let hud = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        
        setupLayout()
        
        setupViewModelObserver()
    }
    
    // To handle screen rotation
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    let loginViewModel = LoginViewModel()
    fileprivate func setupViewModelObserver() {
        
        loginViewModel.bindableIsFormValid.bind { [unowned self] (isFormValid) in
            
            guard let isFormValid = isFormValid else { return }
            if isFormValid {
                self.loginButton.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1)
                self.loginButton.setTitleColor(.white, for: .normal)
                self.loginButton.isEnabled = true
            } else {
                self.loginButton.backgroundColor = .lightGray
                self.loginButton.setTitleColor(.darkGray, for: .normal)
                self.loginButton.isEnabled = false
            }
        }
        
        loginViewModel.bindableIsLoggingIn.bind { [unowned self] (isLoggingIn) in
            guard let isLoggingIn = isLoggingIn else { return }
            
            if isLoggingIn {
                self.hud.textLabel.text = "Logging in..."
                self.hud.show(in: self.view)
            } else {
                self.hud.dismiss()
            }
        }
    }
    
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == emailTextField {
            loginViewModel.email = textField.text
        } else {
            loginViewModel.password = textField.text
        }
    }
    
    
    @objc fileprivate func handleLogin() {
        loginViewModel.performLogin { (err) in
            self.hud.dismiss()
            if let err = err {
                print("failed to login in...", err)
                return
            }
            self.dismiss(animated: true, completion: {
                
                self.delegate?.didFinishLogin()
            })
        }
        
    }
    
    fileprivate func setupLayout() {
        
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 40, bottom: 0, right: 40))
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(goToRegisterButton)
        goToRegisterButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
    }
    
    @objc fileprivate func handleGoToRegister() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9921568627, green: 0.3450980392, blue: 0.3725490196, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1)
        
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0,1]
        gradientLayer.frame = view.bounds

        view.layer.addSublayer(gradientLayer)
    }
    


}
