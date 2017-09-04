//
//  BackendExecutorProtocol.swift
//  
//
//  Created by Vladimir Djokanovic on 9/4/17.
//
//

import UIKit

protocol BackendExecutorProtocol {
    
    func executeBackendRequest(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback)
    func downloadFile(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback)
    func uploadFile(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback)
    
    // Task manage
    func cancel()
    func resume()
    func pause()
}
