//
//  TxFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class TxFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .tx }
    
    fileprivate var account: AccountInfo!
    fileprivate var filter: [Symbol]!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo, filter: [Symbol]) {
        self.account = account
        self.filter = filter
    }

    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "TxViewController") as? TxViewController else { return }
        
        vc.configure(account: account, filter: filter)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}



