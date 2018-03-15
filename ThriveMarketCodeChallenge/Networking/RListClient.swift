//
//  RListClient.swift
//  ThriveMarketCodeChallenge
//
//  Created by Alfredo Alba on 3/14/18.
//  Copyright © 2018 Carlos Alba. All rights reserved.
//

import Foundation

let kListURL = "https://www.reddit.com"
let kTrendingURL = "/r/all/hot.json"

typealias ListJSON = [String: AnyObject]

struct RListClient {
    
    static func getListAPI(_ completion : @escaping (_ results: ListJSON?, _ error : NSError?) -> Void) {
        
        let url = URL(string: kListURL + kTrendingURL)
        
        let session = URLSession.shared
        
        guard let unwrappedURL = url else { print("Error unwrapping URL"); return }
        
        let postData = NSData(data: "{}".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: url! ,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.httpBody = postData as Data
        
        let dataTask = session.dataTask(with: unwrappedURL) { (data, response, error) in
            
            do {
                // checking we are getting the right information
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? ListJSON,
                    let _ = resultsDictionary["data"]else {
                        
                        let APIError = NSError(domain: "Reddit", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"The resource you requested could not be found."])
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                        return
                }
                
                completion(resultsDictionary["data"] as? ListJSON , nil)
            } catch {
                print("Could not get data. \(error), \(error.localizedDescription)")
            }
        }
        dataTask.resume()
    }
}
