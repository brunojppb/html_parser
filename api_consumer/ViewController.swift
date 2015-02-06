//
//  ViewController.swift
//  api_consumer
//
//  Created by Bruno Paulino on 1/22/15.
//  Copyright (c) 2015 Bruno Paulino. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UITableViewController, BoletimParamsDelegate {
    
    
    @IBOutlet weak var unidade: UILabel!
    @IBOutlet weak var ano: UILabel!
    @IBOutlet weak var numero_bol: UILabel!
    @IBOutlet weak var matricula: UITextField!
    @IBOutlet weak var senha: UITextField!
    
    
    var bolRequest: BoletimRequest! = BoletimRequest()
    var pdfPath : NSURL?
    var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if firstLoad{
            self.performFirstRequest()
            firstLoad = false
        }
    }
    
    func performFirstRequest(){
        var hud = MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        hud.labelText = "Carregando..."
        Alamofire.request(.GET, bolRequest.pmpbBolURL)
            .response { (req, resp, data, error) -> Void in
                if error == nil{
                    let content = NSData(data: data as NSData)
                    //let html = NSString(data: content, encoding: UInt())
                    let spaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet() //remove o \n da string
                    let htmlParser = TFHpple(HTMLData: content)
                    
                    //lendo as UNIDADES do HTML
                    let unidadePathString = "//select[@name='cd_unidade']/option"
                    self.parseDataReceived(unidadePathString, html: content, labelText: self.unidade, dict: &self.bolRequest.unidade)
                    
                    //lendo ANOS do HTML
                    let anoPathString = "//select[@name='nu_ano']/option"
                    self.parseDataReceived(anoPathString, html: content, labelText: self.ano, dict: &self.bolRequest.ano)
                    
                    //lendo NUMERO DO BOL do HTML
                    let numBolPathString = "//select[@name='nu_bol']/option"
                    self.parseDataReceived(numBolPathString, html: content, labelText: self.numero_bol, dict: &self.bolRequest.boletimNumber)
                    MBProgressHUD.hideHUDForView(self.tableView, animated: true)
                }
        }
    }
    
    //Parser no HTML e gera os parametros da requisicao
    func parseDataReceived(xPath: String!, html: NSData!, labelText: UILabel!, inout dict: [String:String]!){
        let spaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet() //remove spaces and linebreaks da string
        let htmlParser = TFHpple(HTMLData: html)
        let nodes = htmlParser.searchWithXPathQuery(xPath) as NSArray
        if nodes.count <= 0{
            println("NADA ENCONTRADO")
        }
        else{
            let firstNode = nodes[0] as TFHppleElement
            labelText.text = firstNode.content!.stringByTrimmingCharactersInSet(spaceSet)
            dict.removeAll(keepCapacity: true)
            for node in nodes {
                let element = node as TFHppleElement
                var cont = element.content.stringByTrimmingCharactersInSet(spaceSet)
                var value = element.objectForKey("value")
                dict[cont] = value
                //println("Text: \(cont) - Value: \(value)")
                
            }
        }
    }

    @IBAction func consultar(sender: UIButton) {
        let dataNasc = self.senha.text
        let matricula = self.matricula.text!
        let numBol = bolRequest.boletimNumber[self.numero_bol.text!]
        let params = [
            "nu_bol": numBol,
            "nu_militar": matricula,
            "dt_nascimento": dataNasc,
            "fl_avancada": "0"
        ]
        
        println(params)
        var hud = MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        hud.labelText = "Carregando Boletim..."
        Alamofire.request(.GET, self.bolRequest.submitBolURL, parameters: params, encoding: .URL).response {
            (req, resp, data, error) -> Void in
            if error == nil {
                let content = NSData(data: data as NSData)
                let spaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet() //remove o \n da string
                let htmlParser = TFHpple(HTMLData: content)
                let pdfPath = "//a"
                let nodes = htmlParser.searchWithXPathQuery(pdfPath) as NSArray
                if nodes.count > 0{
                    let node = nodes[0] as TFHppleElement
                    let link = node.objectForKey("href")
                    let fileName = split(link, {$0 == "/"}, maxSplit: Int.max, allowEmptySlices: false)
                    let pdfLink = "\(self.bolRequest.pdfURL)\(fileName[fileName.count-1])"
                    println("PDF: \(pdfLink)")
                    //Download PDF File
                    MBProgressHUD.hideHUDForView(self.tableView, animated: true)
                    self.performSegueWithIdentifier("PresentPDF", sender: pdfLink)
                }
            }
        }
    }

    @IBAction func limpar(sender: UIButton) {
        println("Limpar")
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Dismiss Keyboard
        self.senha.becomeFirstResponder()
        self.senha.resignFirstResponder()
        if let identifier = segue.identifier{
            if identifier == "PresentPDF"{
                let navigationController = segue.destinationViewController as UINavigationController
                let pdfController = navigationController.topViewController as PDFViewController
                let pdf = sender! as String
                pdfController.pdfURL = NSURL(string: pdf)
            }
            else if identifier == "Unidade"{
                let controller = segue.destinationViewController as BoletimParamsViewController
                var params = [String]()
                for (key,value) in self.bolRequest.unidade{
                    params.append(key)
                }
                controller.params = params
                controller.tipo = "unidade"
                controller.delegate = self
            }
            else if identifier == "Ano"{
                let controller = segue.destinationViewController as BoletimParamsViewController
                var params = [String]()
                for (key,value) in self.bolRequest.ano{
                    params.append(key)
                }
                controller.params = params
                controller.tipo = "ano"
                controller.delegate = self
            }
            else if identifier == "Numero"{
                let controller = segue.destinationViewController as BoletimParamsViewController
                var params = [String]()
                for (key,value) in self.bolRequest.boletimNumber{
                    params.append(key)
                }
                controller.params = params
                controller.tipo = "numero"
                controller.delegate = self
            }
            
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 3 && indexPath.section == 4{
            return
        }
    }
    
    func didChangeBolParams(paramChanged: String){
        
        let params = [
            "bol_atual": "",
            "cd_unidade": self.bolRequest.unidade[self.unidade.text!]!,
            "nu_ano": self.bolRequest.ano[self.ano.text!]!,
            "nu_bol": self.bolRequest.boletimNumber[self.numero_bol.text!]!,
            "nu_militar": "",
            "dt_nascimento": ""]
        
        if paramChanged == "unidade"{
            let hud = MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
            hud.labelText = "Atualizando..."
            Alamofire.request(.GET, self.bolRequest.pmpbBolURL, parameters: params, encoding: .URL).response {
                (req, resp, data, error) -> Void in
                if error == nil {
                    println("Request: \(req)")
                    let content = NSData(data: data as NSData)
                    let spaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet() //remove o \n da string
                    
                    //lendo ANOS do HTML
                    let anoPathString = "//select[@name='nu_ano']/option"
                    self.parseDataReceived(anoPathString, html: content, labelText: self.ano, dict: &self.bolRequest.ano)
                    
                    //lendo NUMERO DO BOL do HTML
                    let numBolPathString = "//select[@name='nu_bol']/option"
                    self.parseDataReceived(numBolPathString, html: content, labelText: self.numero_bol, dict: &self.bolRequest.boletimNumber)
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
            }
        }
        else if paramChanged == "ano"{
            let hud = MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
            hud.labelText = "Atualizando..."
            Alamofire.request(.GET, self.bolRequest.pmpbBolURL, parameters: params, encoding: .URL).response {
                (req, resp, data, error) -> Void in
                if error == nil {
                    println("Request: \(req)")
                    let content = NSData(data: data as NSData)
                    let spaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet() //remove o \n da string
                    
                    //lendo NUMERO DO BOL do HTML
                    let numBolPathString = "//select[@name='nu_bol']/option"
                    self.parseDataReceived(numBolPathString, html: content, labelText: self.numero_bol, dict: &self.bolRequest.boletimNumber)
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
            }
        }
        
    }
    
    //MARK: BoletimParams Delegate
    func didSelectParam(tipo: String, param: String) {
        switch tipo{
            case "unidade":
                self.unidade.text = param

            case "ano":
                self.ano.text = param

            case "numero":
                self.numero_bol.text = param
        
            default:
                break
        }
        didChangeBolParams(tipo)
    }
}

