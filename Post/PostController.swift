//
//  PostController.swift
//  Post
//
//  Created by Erik HARTLEY on 1/28/18.
//  Copyright © 2018 Erik HARTLEY. All rights reserved.
//

import Foundation

class PostController {
    
    // MARK: Properties
    var posts = [Post]()
    // its okay to unwrap the url with a bang because if it isnt one then we should crash
    static let baseURL = URL(string: "https://ct-posts.firebaseio.com/posts")!
    // add a json at the end because we need to push our data to the web
    static let getterEndpoint = baseURL.appendingPathExtension("json")
    
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        // gives a default and then checks to see if the reset is the last post and if not then it is the old date instance 
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        // parse the url Parameters and see what they are by entering the url.json on the web
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        // get a query item and flat map it so it will be an array of a string not string: string
        let queryItems = urlParameters.flatMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        // get the components and get the baseURL and set resolving to true
        var urlComponents = URLComponents(url: PostController.baseURL, resolvingAgainstBaseURL: true)
        // append the query item to the components
        urlComponents?.queryItems = queryItems
        // unwrap the url so you can access its properties
        guard let url = urlComponents?.url else {completion() ; return}
        
        let getterEndpoint = url.appendingPathExtension("json")
        var request = URLRequest(url: getterEndpoint)
        request.httpMethod = "GET"
        request.httpBody = nil
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
        
            if let error = error {
                print("Error with fetching: \(error) \(error.localizedDescription) \(#function) \(#file)")
                completion() ; return
            }
            guard let data =  data else {
                print("error fetching data")
                completion() ; return
            }
            do {
                let decoder = JSONDecoder()
                let postsDictionary = try decoder.decode([String:Post].self, from: data)
                let posts: [Post] = postsDictionary.flatMap({ $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch let error {
                NSLog("ERROR decoding: \(error.localizedDescription)")
                completion()
            }
            self.fetchPosts {
                completion()
            }
        }.resume()
        
    }
    func addPost(username: String, text: String, completion: @escaping() -> Void) {
        
        // make a post
        let post = Post(username: username, text: text)
        // create an instance of data to access the post
        var postData: Data
        // create JSONEncoder to encode the post
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
        } catch let error {
            NSLog("ERROR encoding post to be saved: \(error.localizedDescription)")
            completion()
            return
        }
        // make sure the endpoint appends json to be .json
        let postEndpoint = PostController.baseURL.appendingPathExtension("json")
        // make a request and pass in the url that appended json
        var request = URLRequest(url: postEndpoint)
        //declare the type of request
        request.httpMethod = "POST"
        // make sure that the body is of type data and its the encoded post
        request.httpBody = postData
        // make a dataTask with data, response and error
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            // handle the error first
            if let error = error { completion(); NSLog(error.localizedDescription) }
            // unwrap the data and a string that gets data? and .utf8?
            guard let data = data,
                let _ = String(data: data, encoding: .utf8)
                else { NSLog("Data is nil. Unable to verify if data was able to be put to endpoint.");
                    completion()
                    return }

            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    }
}
