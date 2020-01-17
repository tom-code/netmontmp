//
//  main.swift
//  ext1Extension
//
//  Created by tom on 1/11/20.
//  Copyright © 2020 tom. All rights reserved.
//

import Foundation
import NetworkExtension
import os.log

var listener: NSXPCListener?

class C1 : NSObject{
    var currentConnection: NSXPCConnection?
    var listener: NSXPCListener?

    func listen() {
        let machServiceName = "YPY967TA2M.org.tom.ext1.Extension"
        os_log("Starting XPC listener for mach service %@", machServiceName)

        let newListener = NSXPCListener(machServiceName: machServiceName)
        newListener.delegate = self
        newListener.resume()
        listener = newListener
    }

    func log(msg: String) {
        let proxy = currentConnection?.remoteObjectProxy
        let app = proxy as? AppCommunication
        app?.log(message: msg)
        os_log("did log?")
    }
}


extension C1: NSXPCListenerDelegate {
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        os_log("delegate listener 2")
        
        newConnection.exportedInterface = NSXPCInterface(with: ProviderCommunication.self)
        newConnection.exportedObject = self
        
        newConnection.remoteObjectInterface = NSXPCInterface(with: AppCommunication.self)
        
        currentConnection = newConnection
        currentConnection?.resume()
        return true
    }
}

extension C1: ProviderCommunication {
    func register(_ completionHandler: @escaping (Bool) -> Void) {
        os_log("App registered")
        completionHandler(true)
    }
}


var l = C1()
autoreleasepool {
    NEProvider.startSystemExtensionMode()
    l.listen()
}

os_log("ext starting")

dispatchMain()
