//
//  PackedTransaction.swift
//  eosio-api
//
//  Created by kein on 2018. 7. 6..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

class PackedTransaction: JSONOutput {
    var signatures: [String] = []
    let compression = "none"
    let packedTrx: String
    
    var json: JSON {
        var params = JSON()
        params["signatures"] = signatures
        params["compression"] = "none"
        params["packed_context_free_data"] = ""
        params["packed_trx"] = packedTrx
        
        return params
    }
    
    init(signTxn: SignedTransaction) {
        signatures = signTxn.signatures
        packedTrx = signTxn.digest().hex
    }
    
    
}
