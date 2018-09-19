//
//  PhotoDetailsViewController.swift
//  TumblerFy
//
//  Created by Tommy Tran on 14/09/2018.
//  Copyright © 2018 Tommy Tran. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    var image: UIImage!
    
    @IBOutlet weak var photoDetailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoDetailImageView.image = image
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
