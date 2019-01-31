//
//  SettingsController.swift
//  TinderFirestone
//
//  Created by Will Wang on 1/23/19.
//  Copyright © 2019 Will Wang. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate {
    func didSaveSettings()
}


class CustomImagePickerController: UIImagePickerController {
    
    var imageButton: UIButton?
}

class SettingsController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: SettingsControllerDelegate?
    // instance properties
    lazy var image1Button = createButton(#selector(handleSelectPhoto))
    lazy var image2Button = createButton(#selector(handleSelectPhoto))
    lazy var image3Button = createButton(#selector(handleSelectPhoto))
    
    lazy var header: UIView = {
        let header = UIView()
        
        let padding: CGFloat = 16
        
        header.addSubview(image1Button)
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        
        return header
    }()
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        
        fetchCurrentUser()
    }
    
    fileprivate func fetchCurrentUser() {
        
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print("failed to fetch current user info...", err)
                return
            }
            
            self.user = user
            self.loadUserPhoto()
            
            self.tableView.reloadData()
        }
    }
    
    
    fileprivate func loadUserPhoto() {
        if let imageURL1 = user?.imageURL1, let url = URL(string: imageURL1) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
        }
        
        if let imageURL2 = user?.imageURL2, let url = URL(string: imageURL2) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
        }
        
        if let imageURL3 = user?.imageURL3, let url = URL(string: imageURL3) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
        }
        
    }
    
    
    func createButton(_ selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    @objc func handleSelectPhoto(button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        
        present(imagePicker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[.originalImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        
        ref.putData(uploadData, metadata: nil) { (nil, err) in
            
            if let err = err {
                print("failed to upload image data..", err)
                return
            }
            
            print("Finished upload image data...")
            
            ref.downloadURL(completion: { (url, err) in
                
                hud.dismiss()
                if let err = err {
                    print("failed to retrive download url..", err)
                    return
                }
                
                
                if imageButton == self.image1Button {
                    self.user?.imageURL1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageURL2 = url?.absoluteString
                } else {
                    self.user?.imageURL3 = url?.absoluteString
                }
                
            })
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        if section == 0 {
            return header
        }
        
        let headerLabel = HeaderLabel()
        headerLabel.font = .boldSystemFont(ofSize: 16)
        
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }

        return headerLabel
        
    }
    
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    fileprivate func evaluateMinMax() {
        guard let ageRangeCell = tableView.cellForRow(at: [5, 0]) as? AgeRangeCell else { return }
        let minValue = Int(ageRangeCell.minSlider.value)
        var maxValue = Int(ageRangeCell.maxSlider.value)
        maxValue = max(minValue, maxValue)
        ageRangeCell.maxSlider.value = Float(maxValue)
        ageRangeCell.minLabel.text = "Min \(minValue)"
        ageRangeCell.maxLabel.text = "Max \(maxValue)"
        
        user?.minSeekingAge = minValue
        user?.maxSeekingAge = maxValue
    }
    
    @objc fileprivate func handleMinAgeChanged(slider: UISlider) {
        evaluateMinMax()
    }
    
    @objc fileprivate func handleMaxAgeChanged(slider: UISlider) {
        evaluateMinMax()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChanged), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChanged), for: .valueChanged)
            
            ageRangeCell.minLabel.text = "Min \(user?.minSeekingAge ?? -1)"
            ageRangeCell.maxLabel.text = "Max \(user?.maxSeekingAge ?? -1)"
            ageRangeCell.minSlider.value = Float(user?.minSeekingAge ?? -1)
            ageRangeCell.maxSlider.value = Float(user?.maxSeekingAge ?? -1)
            
            return ageRangeCell
        }
        
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Profession"
            cell.textField.text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Age"
            if let age = user?.age {
                cell.textField.text = String(age)
            }
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
        default:
            cell.textField.placeholder = "Bio"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        } else {
            return 40
        }
    }
    
    @objc fileprivate func handleNameChange(textField: UITextField) {
        self.user?.name = textField.text
    }
    
    @objc fileprivate func handleProfessionChange(textField: UITextField) {
        self.user?.profession = textField.text
    }
    
    @objc fileprivate func handleAgeChange(textField: UITextField) {
        guard let age = textField.text else { return }
        self.user?.age = Int(age)
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))]
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func handleLogout() {
        try? Auth.auth().signOut()
        dismiss(animated: true)
    }

    @objc fileprivate func handleSave() {
        
        view.endEditing(true)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docData: [String: Any] = [
            "uid" : uid,
            "full name" : user?.name ?? "",
            "age" : user?.age ?? -1,
            "profession": user?.profession ?? "",
            "imageURL1" : user?.imageURL1 ?? "",
            "imageURL2" : user?.imageURL2 ?? "",
            "imageURL3" : user?.imageURL3 ?? "",
            "minSeekingAge" : user?.minSeekingAge ?? 10,
            "maxSeekingAge" : user?.maxSeekingAge ?? 100
        ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving Settings"
        hud.show(in: view)
        
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            
            hud.dismiss()
            
            if let err = err {
                print("failed to save data to firestore", err)
                return
            }
            
            self.dismiss(animated: true, completion: {
                print("Finished saving user info into Firestore...")
                self.delegate?.didSaveSettings()
            })
  
        }
    }
}
