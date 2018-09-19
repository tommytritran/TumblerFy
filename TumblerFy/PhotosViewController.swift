//
//  PhotosViewController.swift
//  TumblerFy
//
//  Created by Tommy Tran on 07/09/2018.
//  Copyright © 2018 Tommy Tran. All rights reserved.
//

import UIKit
import AlamofireImage
import SVProgressHUD

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    var posts: [[String: Any]] = []
    var refreshControl = UIRefreshControl()
    var photo: [[String: Any]] = []
    var limit = 5
    var offset = 0
    var isMoreDataLoading = false
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(PhotosViewController.didPullForRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        tableView.delegate = self
        tableView.dataSource = self
        fetchPicture()
        self.tableView?.rowHeight = 350.0
        
    }
    @objc func didPullForRefresh(_ pullForRefresh: UIRefreshControl){
        fetchPicture()
    }
    func fetchPicture(){
        // Network request snippet
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&limit=\(limit)&offset=\(offset)")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .returnCacheDataElseLoad
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                self.alertHandler()
                print(error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts += responseDictionary["posts"] as! [[String: Any]]
                
                self.isMoreDataLoading = false
                self.offset += self.limit
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            
        }
        
        task.resume()
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // ... Code to load more results ...
                fetchPicture()
            }
        }
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
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.section]
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        // Set the avatar
        profileView.af_setImage(withURL: URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        let post = posts[section]
        
        let dateString = post["date"] as! String
        
        
        // Add a UILabel for the date here
        let sectionLabel = UILabel()
        // Use the section number to get the right URL
        sectionLabel.text = dateString
        // let label = ...
        
        sectionLabel.frame = CGRect(x: 50, y: 5, width: 300, height: 50)
        headerView.addSubview(sectionLabel)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! PhotoCell

        let detail = segue.destination as! PhotoDetailsViewController

        detail.image = cell.photoImageView.image
    }
    

}
