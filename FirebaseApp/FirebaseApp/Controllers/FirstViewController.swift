//
//  FirstViewController.swift
//  FirebaseApp
//
//  Created by Евгений Забродский on 30.01.23.
//

import UIKit
import Firebase
import FirebaseStorage

class FirstViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func downloadButton() {
        let storageRef = Storage.storage().reference()
        let riversRef = storageRef.child("Лейбл.png")
        
        let download = riversRef.getData(maxSize: 99999999) { data, error in
            let image = UIImage(data: data!)
            self.imageView.image = image
        }

    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
