//
//  HomeViewController.swift
//  TBD
//
//  Created by Antonio Llano on 3/6/21.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    

    

    var user: String!
    let defaults = UserDefaults.standard
    var recentPredictions = [String]()
    var recentScans = [String]()
    var likedScans = ["1"]
    
    @IBOutlet weak var recentsCollectionView: UICollectionView!
    @IBOutlet weak var likedCollectionView: UICollectionView!
    @IBOutlet weak var mockImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recentsCollectionView.delegate = self
        recentsCollectionView.dataSource = self
        
        likedCollectionView.delegate = self
        likedCollectionView.dataSource = self
       
        // Create URL

   
        
        
        
        
        if let items = (self.defaults.array(forKey:"user") as? [String]){
        user = items[0]
        }
       
        if let recentPredictionsStored = (self.defaults.array(forKey: user + "recentPredictions") as? [String]){
            recentPredictions = recentPredictionsStored
        }
        
        print(user!)
        // Do any additional setup after loading the view.
    }
    
    func getMockImage(){
        
        if let items = (defaults.array(forKey: "recentScans") as? [String]){
        recentScans = items
            //mockImgView.image = UIImage(contentsOfFile: recentScans[0])
            
            
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMockImage()
        recentsCollectionView.reloadData()
        likedCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recentsCollectionView{
            return recentScans.count
        }
        return likedScans.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recentsCell = recentsCollectionView.dequeueReusableCell(withReuseIdentifier: "RecentsCell", for: indexPath) as! RecentsCell
        let imgView = self.view.viewWithTag(4) as? UIImageView
        imgView?.image = UIImage(contentsOfFile: recentScans[indexPath.row])
        print("Dequeued cell")

        
        
        if collectionView == likedCollectionView{
            let likedCell = likedCollectionView.dequeueReusableCell(withReuseIdentifier: "LikedCell", for: indexPath) as! LikedCell

            return likedCell
        }
        
        return recentsCell
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
