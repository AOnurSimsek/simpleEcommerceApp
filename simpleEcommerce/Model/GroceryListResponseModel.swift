//
//  GroceryListResponseModel.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 29.12.2021.
//

import Foundation
import ObjectMapper

class GroceryListResponseModel: Mappable {
    var id: String?
    var name: String?
    var price: Double?
    var currency: String?
    var imageUrl: String?
    var stock: Int?
    var cartCount: Int = 0
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        price <- map["price"]
        currency <- map["currency"]
        imageUrl <- map["imageUrl"]
        stock <- map["stock"]
    }
}
