//
//  BoletimRequest.swift
//  api_consumer
//
//  Created by Bruno Paulino on 2/3/15.
//  Copyright (c) 2015 Bruno Paulino. All rights reserved.
//

import Foundation

class BoletimRequest {
    
    var unidade: [String:String]!
    var ano: [String:String]!
    var boletimNumber: [String:String]!
    let pmpbBolURL = "https://intranet.pm.pb.gov.br/webaplication/novo_layout5/bolpm/internet/"
    let submitBolURL = "https://intranet.pm.pb.gov.br/webaplication/novo_layout5/bolpm/internet/bol.php"
    let pdfURL = "https://intranet.pm.pb.gov.br/temp/"
    
    init(){
        boletimNumber = [String:String]()
        ano = [String:String]()
        unidade = [String:String]()
    }
    
    
}
