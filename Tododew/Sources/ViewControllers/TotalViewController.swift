//
//  TotalViewController.swift
//  tododew
//
//  Created by 권형주 on 2017. 6. 1..
//  Copyright © 2017년 hyungdew. All rights reserved.
//

import UIKit
import RealmSwift
import PopupDialog
import AMScrollingNavbar

final class TotalViewConroller: UIViewController {
  
  // Basket data
  fileprivate lazy var realm = try! Realm()
  fileprivate var realmItems: Results<ToDoItem>? {
    didSet {
      filterdGroupList()
      collectionView.reloadData()
    }
  }
  fileprivate var realmIncompleteItems: Results<ToDoItem>?
  fileprivate var items: [BasketTotals] = []
  
  // UI
  fileprivate let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout
    layout?.sectionHeadersPinToVisibleBounds = true
    layout?.minimumInteritemSpacing = 0
    layout?.minimumLineSpacing = 1
    
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.register(BasketHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "basketHeaderCell")
    $0.register(SummaryCell.self, forCellWithReuseIdentifier: "summaryCell")
    $0.register(PriceCell.self, forCellWithReuseIdentifier: "priceCell")
  }
  fileprivate let statusBarView = UIView(frame: .zero).then { $0.backgroundColor = .clear }
  fileprivate let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let navigationController = navigationController as? ScrollingNavigationController {
      navigationController.navigationBar.backgroundColor = .white
      navigationController.followScrollView(collectionView, delay: 50.0)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
//    UIApplication.shared.applicationIconBadgeNumber = 2
//    print(Realm.Configuration.defaultConfiguration.fileURL!)
    
    self.navigationItem.rightBarButtonItem = self.addButtonItem
    self.view.backgroundColor = .white
    
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    self.addButtonItem.target = self
    self.addButtonItem.action = #selector(addButtonItemDidTap)
    
    self.view.addSubview(statusBarView)
    self.view.addSubview(collectionView)
    
    self.statusBarView.snp.makeConstraints { make in
      make.height.equalTo(22)
      make.top.left.right.equalTo(0)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.left.right.equalTo(0)
      make.top.equalTo(self.topLayoutGuide.snp.bottom)
      make.bottom.equalTo(self.view.snp.bottom)
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(refreshItems), name: Noti.refreshItems, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(refreshBadgeNumbers), name: Noti.refreshBadgeCount, object: nil)
    
    self.loadItems()
    self.refreshBadgeNumbers()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func refreshBadgeNumbers() {
    UIApplication.shared.applicationIconBadgeNumber = self.realmIncompleteItems?.count ?? 0
  }
  
  func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    if let navigationController = self.navigationController as? ScrollingNavigationController {
      navigationController.showNavbar(animated: true)
    }
    return true
  }

  func loadItems() {
    self.realmItems = realm.objects(ToDoItem.self).sorted(byKeyPath: "createAt", ascending: false)
    self.realmIncompleteItems = self.realm
      .objects(ToDoItem.self)
      .filter("done = false")
  }
  
  func refreshItems() {
    self.filterdGroupList()
    self.collectionView.reloadData()
  }
  
  func filterdGroupList() {
    var items: [String: [String: BasketTotal]] = [:]
    
    guard let todoItems = realmItems else { return }
    
    todoItems.forEach { item in
      let key = keyFormatter.string(from: item.createAt)
      let year = yearFormatter.string(from: item.createAt)
      let title = titleFormatter.string(from: item.createAt)
      let price = Int(item.price) ?? 0
      
      if items[year] == nil {
        items[year] = [:]
      }
      
      var totalPrice = items[year]?[key]?.total ?? 0
      totalPrice += price
      
      items[year]?[key] = (year, title, totalPrice)
    }
    
    let today = Date()
    let key = keyFormatter.string(from: today)
    let year = yearFormatter.string(from: today)
    let title = titleFormatter.string(from: today)
    
    if items[year] == nil {
      items[year] = [:]
    }
    
    let total = items[year]?[key]?.total ?? 0
    items[year]?[key] = (year, title, total)

    var newItems: [BasketTotals] = []
    items.sorted { $0.key > $1.key }.forEach { item in
      let filteredItems = item.value.sorted { $0.key > $1.key }
      newItems.append(filteredItems)
    }
    
    self.items = newItems
  }
  
  func addButtonItemDidTap() {
    self.navigationController?.showAddDialog { [weak self] in
      self?.addButtonItemDidTap()
    }
  }
  
  func pushController(month: String, title: String) {
    self.navigationController?.pushBasketController(month: month, title: title, addButtonItemDidTap: addButtonItemDidTap)
  }
}

extension TotalViewConroller: UICollectionViewDataSource {
  // MARK: cell count
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.items[section].count
  }
  
  // MARK: section cell
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionElementKindSectionHeader {
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "basketHeaderCell", for: indexPath) as! BasketHeaderCell
      let title = self.items[indexPath.section].first?.value.year
      headerView.configure(title: title ?? "####")
      return headerView
    }
    return UICollectionReusableView()
  }

  // MARK: cell
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let section = indexPath.section
    let row = indexPath.item
    
    if section == 0, row == 0 {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summaryCell", for: indexPath) as! SummaryCell
      let item = self.items[section][row]
      
      cell.configure(item: item.value)
      cell.didTap = { [weak self] in
        self?.pushController(month: item.key, title: item.value.title)
      }
      
      return cell
    }
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceCell", for: indexPath) as! PriceCell
    let item = self.items[section][row]
    
    cell.configure(item: item.value)
    cell.didTap = { [weak self] in
      self?.pushController(month: item.key, title: item.value.title)
    }
    
    return cell
  }

}

extension TotalViewConroller: UICollectionViewDelegateFlowLayout {
  // MARK: section count
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return self.items.count
  }
  
  // MARK: margin between cells
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  // MARK: header cell size
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 0 {
      return CGSize(width: 0, height: 0)
    }
    return BasketHeaderCell.size(width: collectionView.frame.size.width)
  }

  // MARK: cell size
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var height: CGFloat
    if indexPath.section == 0, self.items.count == 1, self.items[indexPath.section].count <= 1 {
      height = self.collectionView.frame.size.height - 40
    } else {
      height = self.collectionView.frame.size.width - 60
    }
    
    if indexPath.section == 0, indexPath.item == 0 {
      return SummaryCell.size(width: collectionView.frame.size.width, height: height)
    }
    
    return PriceCell.size(width: collectionView.frame.size.width)
  }
}
