//
//  common.swift
//  ext1
//
//  Created by tom on 13/01/2020.
//  Copyright © 2020 tom. All rights reserved.
//

import Foundation


@objc protocol AppCommunication {
    func promptUser(aboutFlow flowInfo: [String: String], responseHandler: @escaping (Bool) -> Void)
    func log(message: String)
}

@objc protocol ProviderCommunication {
    func register(_ completionHandler: @escaping (Bool) -> Void)
}
