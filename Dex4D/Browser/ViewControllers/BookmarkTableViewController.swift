//
//  CollectTableViewController.swift
//  TradingPlatform
//
//  Created by ColdChains on 2018/9/26.
//  Copyright © 2018 冰凉的枷锁. All rights reserved.
//

import UIKit

protocol BookmarkTableViewDelegate: class {
    func didSelectRowAt(urlString: String)
}

class BookmarkTableViewController: BaseViewController {
    
    weak var delegate: BookmarkTableViewDelegate?
    
    var viewModel: BookmarkTableViewModel
    
    var deleteArray: [IndexPath] = []
    
    var isSelectAll = false
    
    var canEdit = false
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(BookMarkTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(BookMarkTableViewCell.self))
        return tableView
    }()
    
    init(type: BookmarkType) {
        self.viewModel = BookmarkTableViewModel(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    func edit() {
        canEdit = true
        tableView.reloadData()
    }
    
    func delete() {
        print(deleteArray)
        if isSelectAll || deleteArray.count == viewModel.dataSource.count {
            viewModel.deleteAll()
        } else {
            deleteArray = deleteArray.sorted { (index1, index2) -> Bool in
                return index1 > index2
            }
            var arr: Array<Bookmark> = []
            for index in deleteArray {
                arr.append(viewModel.dataSource[index.row])
            }
            viewModel.bookmarkStorage.delete(bookmarks: arr)
            tableView.deleteRows(at: deleteArray, with: .automatic)
        }
        deleteArray = []
        cancel()
    }
    
    func selectAll() {
        canEdit = true
        isSelectAll = true
        tableView.reloadData()
    }
    
    func cancel() {
        canEdit = false
        isSelectAll = false
        tableView.reloadData()
    }

}

extension BookmarkTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(BookMarkTableViewCell.self)) as! BookMarkTableViewCell
        cell.setBookmark(model: viewModel.dataSource[indexPath.row])
        if canEdit {
            cell.showSelectButton()
            if isSelectAll {
                cell.selectButton.isSelected = true
            }
        } else {
            cell.hideSelectButton()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if canEdit {
            let cell = tableView.cellForRow(at: indexPath) as! BookMarkTableViewCell
            cell.selectButton.isSelected = !cell.selectButton.isSelected
            if cell.selectButton.isSelected {
                deleteArray.append(indexPath)
            }
        } else {
            let str = viewModel.dataSource[indexPath.row].url
            if str != "" {
                delegate?.didSelectRowAt(urlString: str)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.dataSource.isEmpty ? 50 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No data".localized
        label.textColor = Colors.textTips
        label.textAlignment = .center
        label.font = UIFont.defaultFont(size: 14)
        return label
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
//    
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "Delete".localized
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let bookmark = viewModel.dataSource[indexPath.row]
//            viewModel.bookmarkStorage.delete(bookmarks: [bookmark])
//            tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
//        }
//    }
}
