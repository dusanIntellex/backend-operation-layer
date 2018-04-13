//
//  Typedefs.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import Foundation

typealias BackendRequestSuccessCallback = (_ data: Any?,_ statusCode: NSInteger) -> Void
typealias BackendRequestFailureCallback = (_ error: Error?,_ statusCode: NSInteger) -> Void
typealias FinishCallback = () -> Void
typealias SuccessCallback = (_ success: Bool) -> Void
