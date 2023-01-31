//
//  TasksTVC.swift
//  FirebaseApp
//
//  Created by Евгений Забродский on 28.01.23.
//

import UIKit
import Firebase
import FirebaseStorage

final class TasksTVC: UITableViewController {
    
    private var user: User!
    private var ref: DatabaseReference!
    private var tasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // наблюдатель за значениями
        ref.observe(.value) { [weak self] snapshot in
            var tasks = [Task]()
            for item in snapshot.children { // вытаскиваем все tasks
                guard let snapshot = item as? DataSnapshot,
                      let task = Task(snapshot: snapshot) else { continue }
                tasks.append(task)
            }
            self?.tasks = tasks
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    @IBAction func signOutButton(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func addToDoButton(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add new task", message: "Add", preferredStyle: .alert)
        alertController.addTextField()
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first,
                  let text = textField.text,
                  let uid = self?.user.uid
            else { return }
            let task = Task(title: text, userId: uid)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef!.setValue(task.convertToDictionary())
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true)

    }
    @IBAction func addImageButton(_ sender: UIBarButtonItem) {
        let storageRef = Storage.storage().reference()
        let riversRef = storageRef.child("dudekab9.jpeg")
        
        guard let imageData = #imageLiteral(resourceName: "dudekab9.jpeg").pngData() else { return }

        
        let uploadTask = riversRef.putData(imageData, metadata: nil) { metadata, error in
            print(metadata)
            print(error)
            
            riversRef.getData(maxSize: 99999999) { data, error in
                let image = UIImage(data: data!)
                print(image)
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let currentTask = tasks[indexPath.row]
        cell.textLabel?.text = currentTask.title
        toggleCompletion(cell, isCompleted: currentTask.completed)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed": isCompleted])
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete { return }
        let task = tasks[indexPath.row]
        // удаление
        task.ref?.removeValue()
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }

}
