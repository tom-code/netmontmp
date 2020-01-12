//
//  FilterDataProvider.swift
//  ext1Extension
//
//  Created by tom on 1/11/20.
//  Copyright © 2020 tom. All rights reserved.
//

import NetworkExtension
import os.log


class FilterDataProvider: NEFilterDataProvider {

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter.
        os_log("ext start filter")
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        os_log("ext stop filter")
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        // Add code to determine if the flow should be dropped or not, downloading new rules if required.
        os_log("ext new flow")
        return .allow()
    }
}
