//
//  GroceryListPresenter.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 29.12.2021.
//

import Foundation
import UIKit

protocol GroceryListDelegate {
    func didDataReached(datas: [GroceryListResponseModel])
    func willDisplayAlert(title: String, message: String)
    func cartItemsChanged(item: GroceryListResponseModel, indexPath: IndexPath, countChange: Int )
    func showLoadingView(_ show: Bool)
}

typealias GroceryListPresenterDelegate = GroceryListDelegate & GroceryListViewController

class GroceryListPresenter {
    
    weak var delegate: GroceryListPresenterDelegate?
    
    init(_ delegate: GroceryListPresenterDelegate){
        self.delegate = delegate
    }
    
    func getGroceryData(oldData : [GroceryListResponseModel]?){
        delegate?.showLoadingView(true)
        GroceryListWebService.getGroceries { response in
            //If it is nil , there is an error. Otherwise , success.
            if let unwrappedResponse = response {
                if oldData != nil {
                    let matchedData = self.matchCartCounts(oldData: oldData!, newData: unwrappedResponse)
                    self.delegate?.didDataReached(datas: matchedData)
                }
                else {
                    self.delegate?.didDataReached(datas: unwrappedResponse)
                }
                self.delegate?.didDataReached(datas: unwrappedResponse)
                self.delegate?.showLoadingView(false)
            }
            else {
                self.delegate?.showLoadingView(false)
                self.delegate?.willDisplayAlert(title: "Error", message: "There is an error about Api connection")
            }
        }
    }
    
    func matchCartCounts(oldData: [GroceryListResponseModel], newData: [GroceryListResponseModel]) -> [GroceryListResponseModel]{
        for index in 0...oldData.count-1{
            for secondIndex in 0...newData.count-1{
                if oldData[index].id == newData[secondIndex].id {
                    newData[secondIndex].cartCount = oldData[index].cartCount
                    break
                }
            }
        }
        return newData
    }
    
    func checkStock(model: GroceryListResponseModel, index: IndexPath) {
        guard let unwrappedWStock = model.stock else { delegate?.displayAlert(title: "Error", message: "An error occured.")  ; return}
        delegate?.showLoadingView(true)
        if model.cartCount+1 <= unwrappedWStock {
            addProductToCart(model: model, indexPath: index)
        }
        else {
            delegate?.showLoadingView(false)
            delegate?.displayAlert(title: "Mini Bakkal", message: "There is not enough product in the stock.")
        }
    }
    func addProductToCart(model: GroceryListResponseModel, indexPath: IndexPath){
            model.cartCount += 1
            delegate?.cartItemsChanged(item: model, indexPath: indexPath, countChange: +1)
            delegate?.showLoadingView(false)
    }
    func subtractProductFromCart(model: GroceryListResponseModel, indexPath: IndexPath){
        model.cartCount -= 1
        delegate?.cartItemsChanged(item: model, indexPath: indexPath, countChange: -1)
        delegate?.showLoadingView(false)
    }
    func editBage(count: Int){
        if count == 0 {
            
        }
    }
}
