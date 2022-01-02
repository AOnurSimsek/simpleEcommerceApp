//
//  CartWebService.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 30.12.2021.
//

import Foundation
import Alamofire

class CartWebService {
//https://desolate-shelf-18786.herokuapp.com/checkout
    public static func postGroceries(model: [GroceryListResponseModel], success: @escaping (Bool?) -> Void ){
        var products : [ProductModel] = []
        for index in model {
            if index.cartCount > 0 {
                let newProduct = ProductModel(_id: index.id ?? "", _amount: index.cartCount)
                products.append(newProduct)
            }
        }
        let postModel : CheckOutPostModel =  CheckOutPostModel(_products: products)
        
        let url  = "https://desolate-shelf-18786.herokuapp.com/checkout"
        
        AF.request(url, method: .post, parameters: postModel.toJSON()).response { response in
            if response.error == nil {
                success(true)
            }
            else {
                success(false)
            }
        }
    }
    
}
