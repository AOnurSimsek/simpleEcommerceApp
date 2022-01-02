//
//  GroceryCollectionViewCell.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 29.12.2021.
//

import UIKit
import SDWebImage

class GroceryCollectionViewCell: UICollectionViewCell {

    static let identifier : String = "GroceryCollectionViewCell"
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var indexPath : IndexPath?
    var presenter : GroceryListPresenter!
    var model : GroceryListResponseModel? {
        didSet{
            guard let unwrappedModel = model else { return }
            setCellValues(model: unwrappedModel)
            if unwrappedModel.cartCount > 0 {
                UIView.animate(withDuration: 1.0){
                    self.hideMinusAndLabel(true)
                }
            }
            else if unwrappedModel.cartCount == 0 {
                UIView.animate(withDuration: 1.0){
                    self.hideMinusAndLabel(false)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initCellUI()
    }
    
    func setCellValues(model: GroceryListResponseModel){
        priceLabel.text = "\(model.currency ?? "") \(model.price ?? 0.0)"
        nameLabel.text = model.name
        countLabel.text = String(model.cartCount)
        productImageView.sd_setImage(with: URL(string: model.imageUrl ?? "a"), placeholderImage: UIImage(named: ""))
    }
    
    func initCellUI(){
        priceLabel.textColor = .appMainBlue
        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLabel.textAlignment = .left
        
        nameLabel.textColor = .appTextGray
        nameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        nameLabel.textAlignment = .left
        
        countLabel.textColor = .black
        countLabel.backgroundColor = .appLightBlue
        
        plusButton.backgroundColor = .appMainGray
        plusButton.setTitleColor(.blue, for: .normal)
        plusButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        plusButton.layer.cornerRadius = 3
        plusButton.layer.maskedCorners = [.layerMinXMaxYCorner
                                          ,.layerMinXMinYCorner]
        plusButton.layer.borderWidth = 1
        plusButton.layer.borderColor = UIColor.appBorderGray.cgColor
        
        minusButton.backgroundColor = .appMainGray
        minusButton.setTitleColor(.blue, for: .normal)
        minusButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        minusButton.layer.cornerRadius = 3
        minusButton.layer.maskedCorners = [.layerMaxXMaxYCorner
                                          ,.layerMaxXMinYCorner]
        minusButton.layer.borderWidth = 1
        minusButton.layer.borderColor = UIColor.appBorderGray.cgColor
        
        productImageView.layer.borderColor = UIColor.appBorderGray.cgColor
        productImageView.layer.borderWidth = 1
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 5
        productImageView.layer.masksToBounds = true
    }
    
    func hideMinusAndLabel(_ open: Bool){
        if open {
            minusButton.isHidden = false
            countLabel.isHidden = false
        }
        else {
            minusButton.isHidden = true
            countLabel.isHidden = true
        }
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        //tag = 0 for plus | tag = 1 for minus
        guard let unwrappedModel = model, let index = indexPath else { print("error") ;return }
        
        switch sender.tag {
        case 0:
            presenter.checkStock(model: unwrappedModel, index: index)            
        case 1:
            presenter.subtractProductFromCart(model: unwrappedModel, indexPath: index)
        default:()
        }
    }
    
    func hideRightButtons(withAnimation: Bool){
        minusButton.isHidden = true
        countLabel.isHidden = true
        if withAnimation {
            UIView.animate(withDuration: 1.0){
            self.layoutIfNeeded()
            }
        }
        else { self.layoutIfNeeded() }
    }
    
    func showRightButtons(withAnimation: Bool){
        minusButton.isHidden = false
        countLabel.isHidden = false
        if withAnimation {
            UIView.animate(withDuration: 1.0){
            self.layoutIfNeeded()
            }
        }
        else { self.layoutIfNeeded() }
    }
        
}
