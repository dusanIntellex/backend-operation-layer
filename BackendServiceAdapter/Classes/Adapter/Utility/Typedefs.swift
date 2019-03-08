//
//  Typedefs.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import Foundation

public typealias BackendRequestSuccessCallback = (_ data: Any?,_ statusCode: NSInteger) -> Void
public typealias BackendRequestFailureCallback = (_ error: Error,_ statusCode: NSInteger) -> Void
public typealias FinishCallback = () -> Void
public typealias SuccessCallback = (_ success: Bool) -> Void
public typealias ErrorCallback = (_ error: Error) -> Void
