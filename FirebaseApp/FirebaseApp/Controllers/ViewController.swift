//
//  ViewController.swift
//  FirebaseApp
//
//  Created by Евгений Забродский on 28.01.23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var ref: DatabaseReference!
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "users")
        goToNextViewWithoutSignUp()
        keyboardHideAndShow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTF.text = ""
        passwordTF.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
    }

    @IBAction func signInAction(_ sender: Any) {
        guard let email = emailTF.text,
              let password = passwordTF.text,
              email != "",
              password != ""
        else {
            displayWarningLabel(withText: "Info is incorrect")
            return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if let error = error {
                self?.displayWarningLabel(withText: "\(error.localizedDescription)")
            } else if let _ = user {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            } else {
                self?.displayWarningLabel(withText: "No such user")
            }
        }
    }
    
    @IBAction func signUpAction() {
        guard let email = emailTF.text,
              let password = passwordTF.text,
              email != "",
              password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            if let error = error {
                self?.displayWarningLabel(withText: "\(error.localizedDescription)")
            } else {
                guard let user = user else {
                    return
                }
                let userRef = self?.ref.child(user.user.uid)
                userRef?.setValue(["email": user.user.email])
            }
        }
    }
    
    private func displayWarningLabel(withText text: String) {
        errorLabel.text = text
        UIView.animate(withDuration: 5,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            self?.errorLabel.alpha = 1
        }) { [weak self] _ in
            self?.errorLabel.alpha = 0
        }
    }
    
    private func goToNextViewWithoutSignUp() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let _ = user else {
                return
            }
            self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
        }
    }
    
    private func keyboardHideAndShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func kbDidShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    if self.view.frame.origin.y == 0 {
                        self.view.frame.origin.y -= keyboardSize.height / 4
                    }
                }
    }

    @objc func kbDidHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    if self.view.frame.origin.y != 0 {
                        self.view.frame.origin.y += keyboardSize.height / 4
                    }
                }
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

