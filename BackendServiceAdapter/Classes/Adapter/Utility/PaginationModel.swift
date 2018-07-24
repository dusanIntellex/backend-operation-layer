//
//  PaginationModel.swift
//  Virtuzone
//
//  Created by Apple on 12/25/17.
//  Copyright © 2017 Quantox. All rights reserved.
//

import UIKit

public struct PaginationModel: Codable {

    var total:Int?
    var count: Int?
    var perPage: Int?
    var currentPage: Int?
    var totalPages: Int?
    var links:[String]?
   
    /*
    enum CodingKeys: String, CodingKey {
        case total
        case count
        case perPage = "per_page"
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case links
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(total, forKey: .total)
        try container.encode(count, forKey: .count)
        try container.encode(perPage, forKey: .perPage)
        try container.encode(currentPage, forKey: .currentPage)
        try container.encode(totalPages, forKey: .totalPages)
        try container.encode(links, forKey: .links)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        total = try? values.decode(Int.self, forKey: .total)
        count = try? values.decode(Int.self, forKey: .count)
        perPage = try? values.decode(Int.self, forKey: .perPage)
        currentPage = try? values.decode(Int.self, forKey: .currentPage)
        totalPages = try? values.decode(Int.self, forKey: .totalPages)
        links = try? values.decode([String].self, forKey: .links)
    }
 */
    
    var nextPage: Int?{
        get{
            if let currentP = currentPage, let totalP = totalPages{
                return currentP < totalP ? currentP + 1 : nil
            }
            else{
                return nil
            }
        }
    }
}
