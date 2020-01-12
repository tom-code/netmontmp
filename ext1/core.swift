//
//  core.swift
//  ext1
//
//  Created by tom on 1/11/20.
//  Copyright © 2020 tom. All rights reserved.
//

import Foundation
import SystemExtensions
import NetworkExtension
import os.log

@objc protocol AppCommunication {
    func promptUser(aboutFlow flowInfo: [String: String], responseHandler: @escaping (Bool) -> Void)
    func log(message: String)
}

@objc protocol ProviderCommunication {

    func register(_ completionHandler: @escaping (Bool) -> Void)
}


class Loader : NSObject {
    lazy var extensionBundle: Bundle = {
        let extensionsDirectoryURL = URL(fileURLWithPath: "Contents/Library/SystemExtensions", relativeTo: Bundle.main.bundleURL)
        let extensionURLs: [URL]
        do {
            extensionURLs = try FileManager.default.contentsOfDirectory(at: extensionsDirectoryURL,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: .skipsHiddenFiles)
        } catch let error {
            fatalError("Failed to get the contents of \(extensionsDirectoryURL.absoluteString): \(error.localizedDescription)")
        }
        guard let extensionURL = extensionURLs.first else {
            fatalError("Failed to find any system extensions")
        }

        guard let extensionBundle = Bundle(url: extensionURL) else {
            fatalError("Failed to create a bundle with URL \(extensionURL.absoluteString)")
        }

        return extensionBundle
    }()
    
    var currentConnection: NSXPCConnection?

    func start() {
        guard let extensionIdentifier = extensionBundle.bundleIdentifier else {
            return
        }
        let activationRequest = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: extensionIdentifier, queue: .main)
        activationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }

    var callback :(String)->Void? = {def in }
    func updater(closure: @escaping (String)->Void) {
        callback = closure
    }

    
    func configure() {
        let manager = NEFilterManager.shared()
        manager.loadFromPreferences(completionHandler: {loadError in
            if let error = loadError {
                os_log("Failed to load the filter configuration: %@", error.localizedDescription)
            } else {
                os_log("config loaded")
                let providerConfiguration = NEFilterProviderConfiguration()
                providerConfiguration.filterSockets = true
                providerConfiguration.filterPackets = false
                manager.providerConfiguration = providerConfiguration
                
                manager.isEnabled = true
                manager.saveToPreferences { err in
                    os_log("filter saved?")
                    
                    if let error = err {
                        os_log("Failed to enable filter: %@", error.localizedDescription)
                        return
                    }
                }
            }
        })
    }
    
    func register() {
        os_log("reg1")
        //Thread.sleep(forTimeInterval: 3)
        os_log("reg2")
        let machServiceName = extensionMachServiceName(from: extensionBundle)
        let currentConnection = NSXPCConnection(machServiceName: machServiceName, options: [])
        
        currentConnection.exportedInterface = NSXPCInterface(with: AppCommunication.self)
        currentConnection.exportedObject = self
        currentConnection.remoteObjectInterface = NSXPCInterface(with: ProviderCommunication.self)


        
        currentConnection.resume()

        let prov = currentConnection.remoteObjectProxyWithErrorHandler({ registerError in
            os_log("Failed to register with the provider: %@", registerError.localizedDescription)
            self.currentConnection?.invalidate()
            self.currentConnection = nil
            //completionHandler(false)
        })
        let p = prov as? ProviderCommunication
        p?.register({suc in
            os_log("c1 b")
            self.configure()
        })
        
        os_log("reg4")
        
    }

    private func extensionMachServiceName(from bundle: Bundle) -> String {

        guard let networkExtensionKeys = bundle.object(forInfoDictionaryKey: "NetworkExtension") as? [String: Any],
            let machServiceName = networkExtensionKeys["NEMachServiceName"] as? String else {
                fatalError("Mach service name is missing from the Info.plist")
        }

        return machServiceName
    }

}

extension Loader: AppCommunication {
    func promptUser(aboutFlow flowInfo: [String: String], responseHandler: @escaping (Bool) -> Void) {
    }
    func log(message: String) {
        os_log("here log")
        callback(message)
    }
}



extension Loader: OSSystemExtensionRequestDelegate {

    // MARK: OSSystemExtensionActivationRequestDelegate

    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
os_log("reuest1")
        guard result == .completed else {
            os_log("Unexpected result %d for system extension request", result.rawValue)
            return
        }
        configure()
        register()
    }

    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {

        os_log("System extension request failed: %@", error.localizedDescription)
    }

    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {

        os_log("Extension %@ requires user approval", request.identifier)
    }

    func request(_ request: OSSystemExtensionRequest,
                 actionForReplacingExtension existing: OSSystemExtensionProperties,
                 withExtension extension: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {

        os_log("Replacing extension %@ version %@ with version %@", request.identifier, existing.bundleShortVersion, `extension`.bundleShortVersion)
        return .replace
    }
}
