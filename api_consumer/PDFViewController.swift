//
//  PDFViewController.swift
//  api_consumer
//
//  Created by Bruno Paulino on 2/5/15.
//  Copyright (c) 2015 Bruno Paulino. All rights reserved.
//

import Foundation
import UIKit

class PDFViewController : UIViewController, UIWebViewDelegate{
    
    @IBOutlet weak var webView: UIWebView!
    
    var pdfURL : NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("PDF View Controller")
        println("NSURL: \(pdfURL)")
        if let url = pdfURL{
            let request = NSURLRequest(URL: url)
            self.webView.userInteractionEnabled = true
            self.webView.loadRequest(request)
        }
    }
    @IBAction func CloseBol(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UIWebView Delegate
    func webViewDidStartLoad(webView: UIWebView) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
}
