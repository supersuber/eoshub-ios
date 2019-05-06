//
//  RexFlowController.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation

class RexFlowController: FlowController, RexFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .rex }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: RexViewController.self)
        guard let vc = UIStoryboard(name: "Rex", bundle: nil).instantiateViewController(withIdentifier: "RexViewController") as? RexViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goToLend(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = RexLendFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func goToBorrow(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = RexBorrowFlowController(configure: config)
        fc.start(animated: true)
    }
    
}

protocol RexFlowEventDelegate: FlowEventDelegate {
    func goToLend(from nc: UINavigationController)
    func goToBorrow(from nc: UINavigationController)
}
