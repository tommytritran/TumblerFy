//
//  PhotosViewController.swift
//  TumblerFy
//
//  Created by Tommy Tran on 07/09/2018.
//  Copyright © 2018 Tommy Tran. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var posts: [[String: Any]] = []
    var refreshControl = UIRefreshControl()

    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(PhotosViewController.didPullForRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        tableView.delegate = self
        tableView.dataSource = self
        fetchPicture()
        self.tableView?.rowHeight = 400.0
        
    }
    @objc func didPullForRefresh(_ pullForRefresh: UIRefreshControl){
        fetchPicture()
    }
    func fetchPicture(){
        // Network request snippet
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                self.alertHandler()
                print(error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            
        }
        
        task.resume()
    }

    
    func alertHandler(){
        let alert = UIAlertController(title:"Network error", message: "could not load movies", preferredStyle:UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: {(action) in self.fetchPicture()}))
        
        self.present(alert, animated: true,completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        if let photos = post["photos"] as? [[String: Any]] {
            // 1.
            let photo = photos[0]
            // 2.
            let originalSize = photo["original_size"] as! [String: Any]
            // 3.
            let urlString = originalSize["url"] as! String
            // 4.
            let url = URL(string: urlString)
            cell.photoImageView.af_setImage(withURL: url!)
            
        }

        return cell
    }
    


}
