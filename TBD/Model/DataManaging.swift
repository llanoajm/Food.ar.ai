//
//  DataManaging.swift
//  TBD
//
//  Created by Antonio Llano on 14/02/21.
//

import Foundation

protocol DataManagingDelegate{
    func didUpdateData(_ dataManaging: DataManaging, data: DataModel)
    func didFailWithError(error: Error)
}

//1. Create a URL
//2. Create a URLSession
//3. Give the session a task
//4. Start the task



struct DataManaging{
    let dataURL = "http://192.168.0.19:8081"
    
    var delegate: DataManagingDelegate?
    
    func fetchData(){
        
        
        
        let urlString = dataURL + "/fetch"
        
        
        performRequest(with: urlString, type: "fetch")
    }
    func postData(){
        
       let urlString = dataURL + "/post"
        print(urlString)
        performRequest(with: urlString, type: "post")
        
    }
    
    
    //FETCH Procedure
    func performRequest(with urlString: String, type: String){
        
        //fetches data and URL To create a URLSession, assign a task to the session and carry out the task.
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if type == "fetch"{
                    if let safeData = data{
                        if let data =  self.parseJSON(safeData){
                            
                            self.delegate?.didUpdateData(self, data: data)
                            
                        }
                    }
                }
                else if type  == "post"{
                    print(response)
                }
                
                
                
            }
             task.resume()
        }
        
    }
    func parseJSON(_ userData: Foundation.Data) -> DataModel? {
        
        let decoder = JSONDecoder()
        do {
            
            
            let decodedData = try decoder.decode([UserData].self, from: userData)
            var ids = [String]()
            
            var usernames = [String]()
            var scanned_products = [[String]]()
            
            
            
            for num in 0 ... decodedData.count - 1{
                let id = decodedData[num]._id
                ids.append(id)
                let username = decodedData[num].username
                usernames.append(username)
                let scans = decodedData[num].scans
                scanned_products.append(scans)
                
                
                
                            }
           
                
                
            
                
                
            
            let thisData = DataModel(userIds: ids, usernames: usernames, scanned_products: scanned_products)
            
            
            
            
            
            return thisData
            
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
