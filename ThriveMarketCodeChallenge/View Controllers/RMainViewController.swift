//
//  RMainViewController.swift
//  ThriveMarketCodeChallenge
//
//  Created by Alfredo Alba on 3/14/18.
//  Copyright © 2018 Carlos Alba. All rights reserved.
//

import UIKit

class RMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var myList: [RList] = [RList]()
    private var myTableView: UITableView!
    private let listClient = RListDataSource.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Construction of TableView
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Call to API
        listClient.getList { (result, errorList) in
            if errorList == nil {
                self.myList = result!
                self.myTableView.reloadData()
            } else {
                // In case of Faile
                let alert = UIAlertController(title: "Not Found",
                                              message: "Try again Later",
                                              preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = NSURL(string: kListURL + myList[indexPath.row].listPermalink)
        UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath as IndexPath)
        cell.textLabel!.text = myList[indexPath.row].listTitle
        
        // Dinamic Height
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.font = UIFont(name: "Helvetica", size: 17.0)
        
        let constraintSize = CGSize(width: 280.0, height: Double(MAXFLOAT))
        let labelSize: CGSize = myList[indexPath.row].listTitle.boundingRect(with: constraintSize,     options: .usesLineFragmentOrigin,
           attributes: [NSAttributedStringKey.font: cell.textLabel!.font], context: nil).size

        cell.textLabel!.frame.size = labelSize
        
        // Placeholder
        cell.imageView?.image = UIImage(named:"placeholder-Reddit")

        // Create URL from string
        let url = NSURL(string: myList[indexPath.row].listImageURL)!

        // Download task:
        let task = URLSession.shared.dataTask(with: url as URL) { (responseData, responseUrl, error) -> Void in
            if let data = responseData {

                // Execute in thread
                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: data)
                    cell.layoutSubviews()
                }
            }
        }

        // Run task
        task.resume()
        
        return cell
    }
}

