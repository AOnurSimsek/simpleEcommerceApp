//
//  GroceryListWebService.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 30.12.2021.
//

import Foundation
import Alamofire
import ObjectMapper

class GroceryListWebService {
    public static func getGroceries(success: @escaping ([GroceryListResponseModel]?) -> Void ){
        let url =  "https://desolate-shelf-18786.herokuapp.com/list"
        AF.request(url, method: .get, parameters: nil).responseJSON { response in
            if response.error == nil {
                guard let data = response.value as? [[String:Any]] else { success(nil) ; return }
                let mappedData : [GroceryListResponseModel] = Mapper().mapArray(JSONArray: data)
                if mappedData.isEmpty{ success(nil)}
                else { success(mappedData) }
            }
            else { success(nil) }
        }
    }
}
