//
//  ViewController.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 29.12.2021.
//

import UIKit

class GroceryListViewController: UIViewController {
    
    @IBOutlet weak var groceryCollectionView: UICollectionView!
    
    var presenter : GroceryListPresenter?
    var groceryModels : [GroceryListResponseModel] = []
    var groceryModelsFromCart : [GroceryListResponseModel]?
    var badgeCount : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(cartCaountChanged(_:)), name: .cartCountChanged, object: nil)
        presenter = GroceryListPresenter(self)
        setCollectionView()
        setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if groceryModelsFromCart  != nil {
            presenter?.getGroceryData(oldData: groceryModelsFromCart!)
        }
        else {
            presenter?.getGroceryData(oldData: nil)
        }
    }
    
    func setNavigationBar(){
        
        let shoppingCartButton : UIButton = {
           let x = UIButton()
            x.addTarget(self, action: #selector(cartButtonPrerssed), for: .touchUpInside)
            x.layer.cornerRadius = x.frame.width/2
            x.setImage(UIImage(named: "cart"), for: .normal)
           return x
        }()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(
                customView: shoppingCartButton)
        self.navigationItem.rightBarButtonItem?.setBadge(text: "0")
        self.navigationItem.rightBarButtonItem?.tintColor = .black
        self.title = "Mini Bakkal"
    }
    
    func displayAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true)
    }
    
    @objc func cartButtonPrerssed(){
        let cartListViewController : CartListViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CartListViewController") as! CartListViewController
        cartListViewController.groceryModels = groceryModels
        LoadingView.shared.startLoadingView(vc: cartListViewController)
        navigationController?.pushViewController(cartListViewController, animated: false)
    }
    
    @objc func cartCaountChanged(_ notification: NSNotification){
        if let badgeValue = notification.object as? Int{
            if badgeValue == 0 {
                self.badgeCount = 0
                self.navigationItem.rightBarButtonItem?.setBadge(text: String(badgeValue))
            }
            else {
                self.badgeCount += badgeValue
                self.navigationItem.rightBarButtonItem?.setBadge(text: String(badgeCount))
            }
        }
    }
    
}

//MARK: - CollectionView

extension GroceryListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setCollectionView(){
        groceryCollectionView.delegate = self
        groceryCollectionView.dataSource = self
        groceryCollectionView.register(GroceryCollectionViewCell.nib, forCellWithReuseIdentifier: GroceryCollectionViewCell.identifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groceryModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroceryCollectionViewCell.identifier, for: indexPath) as! GroceryCollectionViewCell
        cell.presenter = presenter
        cell.model = groceryModels[indexPath.row]
        cell.indexPath = indexPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/3.3, height: 210)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
    }
}

//MARK: - Delegate

extension GroceryListViewController: GroceryListDelegate {
    
    func didDataReached(datas: [GroceryListResponseModel]) {
        groceryModels = datas
        DispatchQueue.main.async {
            self.groceryCollectionView.reloadData()
        }
    }
    func willDisplayAlert(title: String, message: String) {
        displayAlert(title: title, message: message)
    }
    func cartItemsChanged(item: GroceryListResponseModel, indexPath: IndexPath, countChange: Int ){
        badgeCount += countChange
        DispatchQueue.main.async {
            self.groceryCollectionView.reloadItems(at: [indexPath])
            self.navigationItem.rightBarButtonItem?.setBadge(text: String(self.badgeCount))
        }
    }
    func showLoadingView(_ show: Bool) {
        if show { LoadingView.shared.startLoadingView() }
        else { LoadingView.shared.stopLoadingView() }
    }
}


