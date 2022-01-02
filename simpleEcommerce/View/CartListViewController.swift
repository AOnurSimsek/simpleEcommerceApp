//
//  CartListViewController.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 1.01.2022.
//

import UIKit

class CartListViewController: UIViewController {
    
    @IBOutlet weak var cartListTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var confirmCartButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var presenter : CartListPresenter?
    var groceryModels : [GroceryListResponseModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CartListPresenter(self)
        setNavigationBar()
        setTableView()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.editData(model: groceryModels)
    }
    
    func setNavigationBar(){
        self.title = "Cart"

        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteButtonPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = .red
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeButtonPressed))
        self.navigationItem.rightBarButtonItem?.tintColor = .appMainBlue
    }
    
    func setUI(){
        bottomView.backgroundColor = .appLightBlue
        
        confirmCartButton.backgroundColor = .appMainBlue
        confirmCartButton.setTitle("Confirm Cart", for: .normal)
        confirmCartButton.layer.cornerRadius = 8
        confirmCartButton.layer.masksToBounds = true
        confirmCartButton.layer.shadowColor = UIColor.appTextGray.cgColor
        confirmCartButton.layer.shadowOffset = CGSize(width: 5, height: 10)
        confirmCartButton.layer.shadowRadius = 10
        confirmCartButton.layer.shadowOpacity = 0.6
        confirmCartButton.clipsToBounds = false
    }
    
    @objc func deleteButtonPressed(){
        displayAlert(title: "Mini Bakkal", message: "All products will be deleted from cart.", withAction: true, indexPath: nil)
    }
    @objc func closeButtonPressed(){
        if let rootVC = navigationController?.viewControllers.first as? GroceryListViewController {
            if groceryModels.isEmpty { rootVC.groceryModelsFromCart = nil }
            else { rootVC.groceryModelsFromCart = self.groceryModels }
        }
        navigationController?.popToRootViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func displayAlert(title: String, message: String, withAction: Bool, indexPath: IndexPath?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default ) { action in
            if indexPath != nil {
                self.groceryModels[indexPath!.row].cartCount += 1
                self.cartListTableView.reloadRows(at: [indexPath!], with: .none)
            }
        }
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { action in
            if indexPath != nil {
                self.groceryModels.remove(at: indexPath!.row)
                self.presenter?.changeBadge(count: -1)
                self.presenter?.calculateTotalPrice(model: self.groceryModels)
            }
            else {
                self.groceryModels.removeAll()
                self.presenter?.changeBadge(count: 0)
                self.presenter?.calculateTotalPrice(model: [])
            }
            self.cartListTableView.reloadData()
        }
        if withAction { alertController.addAction(deleteButton) }
        alertController.addAction(okButton)
        self.present(alertController, animated: true)
    }
    
    func generateAttributedStringForCartTotalPrice(totalPrice: Double, currency: String) -> NSMutableAttributedString{
        let firstString = "Toplam: "
        let secondString = currency + " " + String(format: "%.2f", totalPrice)
        
        let firstAttString = NSMutableAttributedString(string: firstString)
        firstAttString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .regular), range: NSRange(location: 0, length: firstString.count))

        let secondAttString = NSMutableAttributedString(string: secondString)
        secondAttString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24, weight: .bold), range: NSRange(location: 0, length: secondString.count))
        
        firstAttString.append(secondAttString)
        return firstAttString
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        presenter?.postCart(model: groceryModels)
    }
    

}

extension CartListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setTableView(){
        cartListTableView.delegate = self
        cartListTableView.dataSource = self
        cartListTableView.register(CartTableViewCell.nib, forCellReuseIdentifier: CartTableViewCell.identifier)
        cartListTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 130, right: 0)
        cartListTableView.separatorInset = UIEdgeInsets.zero
        cartListTableView.isHidden = true
        cartListTableView.tableFooterView = UIView()
        cartListTableView.bounces = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as! CartTableViewCell
        cell.model = groceryModels[indexPath.row]
        cell.presenter = presenter
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    
}

extension CartListViewController: CartListDelegate {

    func cartItemsChanged(item: GroceryListResponseModel, indexPath: IndexPath, countChange: Int) {
        self.groceryModels[indexPath.row] = item
        presenter?.calculateTotalPrice(model: self.groceryModels)
        DispatchQueue.main.async {
            self.cartListTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func willDisplayAlert(title: String, message:String, withAction:Bool, indexPath: IndexPath?){
        displayAlert(title: title, message: message, withAction: withAction, indexPath: indexPath)
    }
    
    func cartModelEdited(model: [GroceryListResponseModel]) {
        groceryModels = model
        presenter?.calculateTotalPrice(model: model)
        DispatchQueue.main.async {
            self.cartListTableView.isHidden = false
            self.cartListTableView.reloadData()
            LoadingView.shared.stopLoadingView()
        }
    }
    
    func showLoadingView(_ show: Bool) {
        if show { LoadingView.shared.startLoadingView() }
        else { LoadingView.shared.stopLoadingView() }
    }
    
    func priceCalculated(_ totalPrice: Double){
        self.totalPriceLabel.attributedText = generateAttributedStringForCartTotalPrice(totalPrice: totalPrice, currency: groceryModels.first?.currency ??  "" )
    }
    
    func itemsPosted() {
        groceryModels = []
        displayAlert(title: "Mini Bakkal", message: "Cart confirmed successfuly", withAction: false, indexPath: nil)
        presenter?.calculateTotalPrice(model: groceryModels)
        presenter?.changeBadge(count: 0)
        DispatchQueue.main.async {
            self.cartListTableView.reloadData()
        }
    }


}
