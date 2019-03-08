//
//  Constants.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import Foundation

#if DEBUG
    let SERVER_URL = "http://test2018.iumeet.com/api/"
    let COMMON_HEADERS = ["Client-Type" : "ios", "accept": "application/json"]

#else
    let SERVER_URL = "http://test2018.iumeet.com/api/"
    let COMMON_HEADERS = ["Client-Type" : "ios", "accept": "application/json"]
#endif
