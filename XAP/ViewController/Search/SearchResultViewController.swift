//
//  SearchResultViewController.swift
//  XAP
//
//  Created by Alex on 20/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {

    @IBOutlet weak var itemCollectionView: UICollectionView!
    @IBOutlet weak var itemCollectionViewLayout: PinterestLayout!
    @IBOutlet weak var searchButton: UIButton!
    
    let images: [UIImage] = [#imageLiteral(resourceName: "tmp1"), #imageLiteral(resourceName: "tmp2"), #imageLiteral(resourceName: "tmp3")]
    
    var viewModel: SearchViewModel!
    
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCollection()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
        if viewModel.category != nil {
            searchButton.isHidden = true
        }
        if(self.items.count == 0){
            self.items = viewModel.items
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupCollection() {
        itemCollectionView.dataSource = self
        itemCollectionView.delegate = self
        itemCollectionView.backgroundColor = .clear
        itemCollectionView.contentInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    }
    
    private func setupLayout() {
        itemCollectionViewLayout.delegate = self
        itemCollectionViewLayout.cellPadding = 5
        itemCollectionViewLayout.numberOfColumns = 2
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
}

extension SearchResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ItemCollectionViewCell
        let item = items[indexPath.item]
        setupCell(cell: cell, indexPath: indexPath, item: item)
        return cell
    }
    
    func setupCell(cell: ItemCollectionViewCell, indexPath: IndexPath, item: Item) {
        var url: URL? = nil
        if item.pictureUrls.count > 0 {
            url = try? APIURL(stringLiteral: item.pictureUrls[0] ?? "").asPhotoURL()
        }
        cell.imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "item_placeholder"))
        cell.item = item
    }
}

extension SearchResultViewController: PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let image = images[indexPath.item % 3]
        
        return image.height(forWidth: withWidth)
    }
    
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let budget = "\(items[indexPath.item].currency.rawValue) \(items[indexPath.item].price)"
        let name = items[indexPath.item].title
        
        let budgetHeight = budget.heightForWidth(width: withWidth - 16, font: UIFont.systemFont(ofSize: 23))
        let nameHeight = name.heightForWidth(width: withWidth - 16, font: UIFont.systemFont(ofSize: 17))
        return budgetHeight + nameHeight + 24
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = XAPStoryboard.homeScene.itemDetailVC()
        vc.viewModel = HomeViewModel()
        vc.item = items[indexPath.item]
        show(vc, sender: nil)
    }
}
