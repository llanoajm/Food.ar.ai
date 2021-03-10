//
//  TabBarController.swift
//  TBD
//
//  Created by Antonio Llano on 3/6/21.
//

import UIKit

class TabBarController: UITabBarController {

//    var user = "ooo___ooo"
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        if let items = (self.defaults.array(forKey: "user") as? [String]){
        print ("theez  \(items)")
        }
        else{
            print("no")
        }
        super.viewDidLoad()
        let homeVC = self.viewControllers![0] as! HomeViewController
//        homeVC.user = self.user
        // Do any additional setup after loading the view.
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
