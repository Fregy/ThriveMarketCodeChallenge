//
//  RListDataSource.swift
//  ThriveMarketCodeChallenge
//
//  Created by Alfredo Alba on 3/14/18.
//  Copyright © 2018 Carlos Alba. All rights reserved.
//

import Foundation

final class  RListDataSource {
    
    let processingQueue = OperationQueue()
    
    var listResult : [RList] = [RList]()
    
    static let sharedInstance =  RListDataSource()
    
    fileprivate init() {}
    
    func getList(completion: @escaping (_ results: [RList]?, _ error : NSError?) -> Void) {
        
        RListClient.getListAPI { (result, error) in
            
            if error == nil {
                
                var listResultSearch : [RList] = [RList]()
                
                let listResult = result!["children"] as! [AnyObject]
                
                for element in listResult {
                    
                    let myList = RList()
                    let superElement = element["data"] as! ListJSON
                    
                    if let title = superElement["title"] as? String {
                        myList.listTitle = title
                    }
                    if let image = superElement["thumbnail"] as? String {
                        myList.listImageURL = image
                    }
                    if let permalink = superElement["permalink"] as? String {
                        myList.listPermalink = permalink
                    }
                    
                    listResultSearch.append(myList)
                }
                
                self.listResult = listResultSearch
                
                OperationQueue.main.addOperation({
                    
                    completion(self.listResult, nil)
                })
            } else {
                completion(nil, error)
            }
            
        }
    }
}
