//
//  BoletimParamsViewController.swift
//  api_consumer
//
//  Created by Bruno Paulino on 2/5/15.
//  Copyright (c) 2015 Bruno Paulino. All rights reserved.
//

import Foundation
import UIKit

protocol BoletimParamsDelegate{
    func didSelectParam(tipo: String, param: String)
}

class BoletimParamsViewController: UITableViewController {
    
    var params: [String]!
    var delegate:BoletimParamsDelegate!
    var tipo:String!
    let cellIdentifier = "ParamCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.params = self.params.sorted{
            let index = advance($0.startIndex, 0)
            return $1[index] < $0[index]
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    //MARK: TableView DataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = params[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return params.count
    }
    
    //MARK: TableView Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let param = params[indexPath.row]
        self.delegate.didSelectParam(self.tipo, param: param)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
}
