//
//  Typedefs.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import Foundation

typealias BackendRequestSuccessCallback = (_ data: Data?,_ statusCode: NSInteger) -> Void
typealias BackendRequestFailureCallback = (_ error: Error?,_ statusCode: NSInteger) -> Void
typealias FinishCallback = (Void) -> Void
typealias StartCallback = (_ success: Bool) -> Void
