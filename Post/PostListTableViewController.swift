//
//  PostListTableViewController.swift
//  Post
//
//  Created by Erik HARTLEY on 1/29/18.
//  Copyright © 2018 Erik HARTLEY. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    let postController = PostController()

    @IBAction func saveButtonTapped(_ sender: Any) {
        presentNewPostAlert()
    }
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)

        var usernameTextField: UITextField?
        var messageTextField: UITextField?

        alertController.addTextField { (usernameField) in
            usernameField.placeholder = "Display name"
            usernameTextField = usernameField
        }

        alertController.addTextField { (messageField) in

            messageField.placeholder = "What would you like to say..."
            messageTextField = messageField
        }

        let postAction = UIAlertAction(title: "Post", style: .default) { (action) in

            guard let username = usernameTextField?.text, !username.isEmpty,
                let text = messageTextField?.text, !text.isEmpty else {

                    self.presentErrorAlert()
                    return
            }

            self.postController.addPost(username: username, text: text, completion: {
                self.reloadTableView()
            })

        }
        alertController.addAction(postAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "You seem to have forgotten to enter in a correct message", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(Date(timeIntervalSince1970: post.timestamp))"

        return cell
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
