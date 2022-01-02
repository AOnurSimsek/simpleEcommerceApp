//
//  CartPresenter.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 29.12.2021.
//

import Foundation

protocol CartListDelegate {
    func cartModelEdited(model: [GroceryListResponseModel])
    func cartItemsChanged(item: GroceryListResponseModel, indexPath: IndexPath, countChange: Int)
    func willDisplayAlert(title: String, message:String, withAction: Bool, indexPath: IndexPath?)
    func showLoadingView(_ show: Bool)
    func priceCalculated(_ totalPrice: Double)
    func itemsPosted()
}

typealias CartListPresenterDelegate = CartListDelegate & CartListViewController


class CartListPresenter {
    weak var delegate: CartListPresenterDelegate?
    
    init(_ delegate: CartListPresenterDelegate){
        self.delegate = delegate
    }
    
    func editData(model: [GroceryListResponseModel]){
        var cartModel : [GroceryListResponseModel] = []
        for index in model {
            if index.cartCount > 0 {
                cartModel.append(index)
            }
        }
        delegate?.cartModelEdited(model: cartModel)
    }
    
    func checkStock(model: GroceryListResponseModel, index: IndexPath) {
        guard let unwrappedWStock = model.stock
        else {
            delegate?.displayAlert(title: "Error", message: "An error occured.", withAction: false, indexPath: nil)
            return
        }
        delegate?.showLoadingView(true)
        if model.cartCount+1 <= unwrappedWStock {
            addProductToCart(model: model, indexPath: index)
        }
        else {
            delegate?.showLoadingView(false)
            delegate?.willDisplayAlert(title: "Mini Bakkal", message: "There is not enough product in the stock.", withAction: false, indexPath: nil)
        }
    }
    
    private func addProductToCart(model: GroceryListResponseModel, indexPath: IndexPath){
            model.cartCount += 1
            changeBadge(count: 1)
            delegate?.cartItemsChanged(item: model, indexPath: indexPath, countChange: +1)
            delegate?.showLoadingView(false)
    }
    
    func subtractProductFromCart(model: GroceryListResponseModel, indexPath: IndexPath){
        self.delegate?.showLoadingView(true)
        model.cartCount -= 1
        if model.cartCount == 0 {
            delegate?.willDisplayAlert(title: "Mini Bakkal", message: "Product will be deleted from your cart.", withAction: true, indexPath: indexPath)
        }
        else {
            delegate?.cartItemsChanged(item: model, indexPath: indexPath, countChange: -1)
            changeBadge(count: -1)
        }
        delegate?.showLoadingView(false)
    }
    
    func changeBadge(count: Int){
        NotificationCenter.default.post(name: .cartCountChanged , object: count)
    }
    
    func calculateTotalPrice(model: [GroceryListResponseModel]){
        var totalPrice : Double = 0
        for index in model {
            let price = (index.price ?? 0) * Double(index.cartCount)
            totalPrice += price
        }
        delegate?.priceCalculated(totalPrice)
    }
    
    func  postCart(model: [GroceryListResponseModel]){
        self.delegate?.showLoadingView(true)
        CartWebService.postGroceries(model: model) { didSendIt in
            guard let didSendIt = didSendIt else {
                return
            }
            if didSendIt {
                self.delegate?.itemsPosted()
                self.delegate?.showLoadingView(false)
            }
            else {
                self.delegate?.displayAlert(title: "Error", message: "An error occured during post.", withAction: false, indexPath: nil)
                self.delegate?.showLoadingView(false)
            }
        }
    }
    
}
