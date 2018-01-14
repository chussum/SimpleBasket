//
//  TotalViewController.swift
//  tododew
//
//  Created by 권형주 on 2017. 6. 1..
//  Copyright © 2017년 hyungdew. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift
import AMScrollingNavbar

final class BasketViewConroller: UIViewController {
  fileprivate struct Font {
    static let titleLabel = UIFont(name: "Quicksand-Bold", size: 18)
    static let priceLabel = UIFont(name: "Quicksand-Regular", size: 18)
    static let unitLabel = UIFont(name: "Quicksand-Regular", size: 14)
    static let buttonActionLabel = UIFont(name: "Quicksand-Bold", size: 16)
    static let textLabel = UIFont(name: "Quicksand-Bold", size: 16)
  }
  
  fileprivate lazy var realm = try! Realm()
  fileprivate var notificationToken: NotificationToken?
  fileprivate var realmItems: Results<ToDoItem>? {
    didSet {
      calcBasketItems()
      collectionView.reloadData()
    }
  }
  
  fileprivate var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
  fileprivate var buttonStyle: ButtonStyle = .backgroundColor

  fileprivate let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout
    layout?.sectionHeadersPinToVisibleBounds = true
    layout?.minimumInteritemSpacing = 0
    layout?.minimumLineSpacing = 0
    
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.register(SummaryCell.self, forCellWithReuseIdentifier: "summaryCell")
    $0.register(PriceCell.self, forCellWithReuseIdentifier: "priceCell")
  }
  fileprivate let statusBarView = UIView(frame: .zero).then {
    $0.backgroundColor = .clear
  }
  fileprivate let totalView = UIView().then {
    $0.backgroundColor = .white
  }
  fileprivate let totalLabel = UILabel().then {
    $0.font = Font.titleLabel
    $0.text = "Total"
    $0.textAlignment = .left
    $0.sizeToFit()
  }
  fileprivate let priceLabel = UILabel().then {
    $0.font = Font.priceLabel
    $0.textAlignment = .right
  }
  fileprivate let unitLabel = UILabel().then {
    $0.font = Font.unitLabel
    $0.text = "₩"
    $0.sizeToFit()
  }
  
  fileprivate let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
  fileprivate let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
  fileprivate let backButton = UIButton().then {
    $0.setTitle("", for: .normal)
    $0.setImage(UIImage(named: "icon-back"), for: .normal)
    $0.imageView?.contentMode = .scaleAspectFit
    $0.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -60, bottom: 0, right: 0)
    $0.contentHorizontalAlignment = .left
    $0.widthAnchor.constraint(equalToConstant: 70).isActive = true
    $0.heightAnchor.constraint(equalToConstant: 19).isActive = true
  }
  fileprivate let month: String
  fileprivate let targetDate: Date
  
  var addButtonDidTap: (() -> Void)?
  
  // MARK: Initializing
  
  init(month: String, title: String) {
    self.month = month
    
    if let date = keyFormatter.date(from: month) {
      self.targetDate = date
    } else {
      self.targetDate = Date()
    }
    
    super.init(nibName: nil, bundle: nil)
    
    self.title = title
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    self.notificationToken?.stop()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let navigationController = self.navigationController as? ScrollingNavigationController {
      navigationController.navigationBar.backgroundColor = .clear
      navigationController.showNavbar(animated: true)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
  
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    self.addButtonItem.target = self
    self.addButtonItem.action = #selector(addButtonItemDidTap)
    
    self.doneButtonItem.target = self
    self.doneButtonItem.action = #selector(doneButtonItemDidTap)
    
    self.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
    
    let currentMonth = keyFormatter.string(from: Date())
    if month == currentMonth {
      self.navigationItem.rightBarButtonItem = self.addButtonItem
    }
    
    self.view.addSubview(statusBarView)
    self.view.addSubview(collectionView)
    self.view.addSubview(totalView)
    self.totalView.addSubview(totalLabel)
    self.totalView.addSubview(priceLabel)
    self.totalView.addSubview(unitLabel)
    
    self.statusBarView.snp.makeConstraints { make in
      make.height.equalTo(64)
      make.top.left.right.equalTo(0)
    }
    self.collectionView.snp.makeConstraints { make in
      make.left.right.equalTo(0)
      make.top.equalTo(self.statusBarView.snp.bottom)
      make.bottom.equalTo(self.totalView.snp.top)
    }
    self.totalView.snp.makeConstraints { make in
      make.width.equalTo(self.view)
      make.height.equalTo(54)
      make.bottom.equalTo(self.view.snp.bottom)
    }
    self.totalLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.totalView)
      make.left.equalTo(20)
    }
    self.unitLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.totalView)
      make.right.equalTo(-20)
    }
    self.priceLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.totalView)
      make.right.equalTo(self.unitLabel.snp.left)
    }

    self.loadItems()
    self.describeRealmItems()
    
    NotificationCenter.default.addObserver(self, selector: #selector(refreshSubItems), name: Noti.refreshSubItems, object: nil)
  }
  
  func loadItems() {
    let startOfMonth = self.targetDate.startOfMonth() as CVarArg
    let endOfMonth = self.targetDate.endOfMonth() as CVarArg
    let sorted = [
      SortDescriptor(keyPath: "done"),
      SortDescriptor(keyPath: "createAt", ascending: false)
    ]

    self.realmItems = self.realm
      .objects(ToDoItem.self)
      .filter("createAt BETWEEN %@", [startOfMonth, endOfMonth])
      .sorted(by: sorted)
  }
  
  func calcBasketItems() {
    guard let items = self.realmItems else { return }
  
    let total = items.reduce(0) {
      guard let next = Int($1.price) else { return $0 }
      return $0 + next
    }
  
    self.priceLabel.text = toNumberFormat(string: String(total))
    self.priceLabel.sizeToFit()
  }
  
  func refreshSubItems() {
    self.calcBasketItems()
    self.collectionView.reloadData()
  }
  
  // MARK: Observe Results Notifications
  func describeRealmItems() {

    self.notificationToken = self.realmItems?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
      guard let `self` = self else { return }
      
      switch changes {
      case .initial:
        // Results are now populated and can be accessed without blocking the UI
        break
      case .update(_,  _, _, _):
        // Query results have changed
        self.calcBasketItems()
        NotificationCenter.default.post(name: Noti.refreshItems, object: nil)
        break
      case .error(let error):
        // An error occurred while opening the Realm file on the background worker thread
        fatalError("\(error)")
        break
      }
    }
  }
  
  // MARK: Actions
  func addButtonItemDidTap() {
    self.addButtonDidTap?()
  }
  
  func doneButtonItemDidTap() {
    self.view.endEditing(true)
    self.navigationItem.rightBarButtonItem = self.addButtonItem
  }
  
  func backButtonDidTap() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension BasketViewConroller: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let items = self.realmItems else { return 0 }
    return items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceCell", for: indexPath) as! PriceCell
    cell.delegate = self
    
    guard let item = self.realmItems?[indexPath.row] else { return cell }
    
    cell.configure(item: item)
    cell.willEdit = { [weak self] in
      self?.navigationItem.rightBarButtonItem = self?.doneButtonItem
    }
    cell.didEdit = { [weak self] in
      self?.navigationItem.rightBarButtonItem = self?.addButtonItem
    }
    
    return cell
  }

}

extension BasketViewConroller: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return PriceCell.size(width: collectionView.frame.size.width)
  }
}

extension BasketViewConroller: SwipeTableViewCellDelegate {

  fileprivate enum ButtonStyle {
    case backgroundColor, circular
  }
  fileprivate enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
  }
  fileprivate enum ActionDescriptor {
    case trash
    case info
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .trash: return "Trash"
        case .info: return "Info"
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .trash: name = "Trash"
        case .info: name = "Info"
        }
        
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    }
    
    var color: UIColor {
        switch self {
        case .trash: return #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        case .info: return #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        }
    }
  }

  func collectionView(_ collectionView: UICollectionView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
      guard let item = self.realmItems?[indexPath.item] else { return nil }

      if orientation == .right {
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
          self.view.endEditing(true)
          
          try! self.realm.write {
            self.realm.delete(item)
          }
          self.collectionView.deleteItems(at: [indexPath])
        }
        self.configure(action: deleteAction, with: .trash)

        return [deleteAction]
      } else {
        let infoAction = SwipeAction(style: .destructive, title: "Info") { action, indexPath in
          // handle action by updating model with deletion
        }
        self.configure(action: infoAction, with: .info, item: item)
        return [infoAction]
      }
  }
  
  func collectionView(_ collectionView: UICollectionView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
      var options = SwipeTableOptions()
      options.expansionStyle = orientation == .left ? .selection : .destructive
      switch buttonStyle {
      case .backgroundColor:
          options.buttonSpacing = 12
      case .circular:
          options.buttonSpacing = 4
          options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
      }

      return options
  }
  
  fileprivate func configure(action: SwipeAction, with descriptor: ActionDescriptor, item: ToDoItem? = nil) {
      switch buttonStyle {
      case .backgroundColor:
          action.backgroundColor = descriptor.color
          action.font = Font.buttonActionLabel
          break
      case .circular:
          action.backgroundColor = .clear
          action.textColor = descriptor.color
          action.font = .systemFont(ofSize: 13)
          action.transitionDelegate = ScaleTransition.default
          break
      }
    
      if let item = item {
        action.title = " " + item.createAt.toString(format: "yyyy.MM.dd") + "  "
        action.font = Font.textLabel
        action.textColor = .black
      } else {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
      }
      action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
  }
}

