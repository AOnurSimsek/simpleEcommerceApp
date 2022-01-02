//
//  CheckOutPostModel.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 29.12.2021.
//

import Foundation
import ObjectMapper

class CheckOutPostModel: Mappable {
    var products:[ProductModel]?
    
    public init(_products:[ProductModel]){
        products = _products
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        products <- map["product"]
    }
}

class ProductModel: Mappable{
    var id: String?
    var amount: Int?
    
    public init(_id: String, _amount: Int){
        id = _id
        amount = _amount
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        amount <- map["amount"]
    }
    
    
}
