//
//  VC_MainPageSearch.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/12/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageSearch: UIViewController,
                        UISearchBarDelegate,
                        UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let searchBar                   = UISearchBar()
    var focusAreaCollectionView     : UICollectionView?
    let doneBtn                     = UIButton()
    
    var listFocusAreas              = _AppCoreData.listSystemFocusAreas
    var listSelectedAreas           : [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let backBtn = UIBarButtonItem.init(image: UIImage.init(named: "back_black_btn")?.withRenderingMode(.alwaysOriginal),
                                           style: .plain,
                                           target: self,
                                           action: #selector(backButtonTapped))
        
        let clearBtn                = UIButton()
        clearBtn.setTitle(NSLocalizedString("kClearAll", comment: ""), for: .normal)
        clearBtn.setTitleColor(UIColor.init(hexString: "666666"), for: .normal)
        clearBtn.titleLabel?.font   = setFontSize(size: 13, weight: .regular)
        clearBtn.layer.cornerRadius = 3
        clearBtn.addTarget(self, action: #selector(clearAllButtonTapped), for: .touchUpInside)
        let clearAllBtn             = UIBarButtonItem.init(customView: clearBtn)
        
        self.navigationItem.leftBarButtonItem  = backBtn
        self.navigationItem.rightBarButtonItem = clearAllBtn
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: setFontSize(size: 14, weight: .regular),
            .foregroundColor: UIColor.init(hexString: "929292")!,
        ]
        let placeholderText = NSLocalizedString("kSearchTextField", comment: "")
        let attributedText = NSAttributedString(string: placeholderText, attributes: attributes)
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.attributedPlaceholder = attributedText
        } else {
            searchBar.placeholder = NSLocalizedString("kSearchTextField", comment: "")
        }
        
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = UIColor.init(hexString: "fafafa")
        searchBar.delegate = self
        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(2)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
            make.height.equalTo(35)
        }
        
        let focusTitle = UILabel()
        focusTitle.text = NSLocalizedString("kFocusAreaTitle", comment: "")
        focusTitle.font = setFontSize(size: 18, weight: .bold)
        focusTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(focusTitle)
        focusTitle.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.width.equalToSuperview().offset(-55)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        doneBtn.setTitle(NSLocalizedString("kSearchTextField", comment: ""), for: .normal)
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold)
        doneBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        doneBtn.layer.cornerRadius = 20
        doneBtn.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        self.view.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        
        let layout = ChipSelectionFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.scrollDirection = .vertical
        
        self.focusAreaCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        self.focusAreaCollectionView?.backgroundColor = .white
        self.focusAreaCollectionView?.register(CC_ChipSelectionCell.self, forCellWithReuseIdentifier: "chipCell")
        self.focusAreaCollectionView?.dataSource = self
        self.focusAreaCollectionView?.delegate = self
        self.view.addSubview(focusAreaCollectionView!)
        focusAreaCollectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(focusTitle.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-10)
            make.bottom.equalTo(doneBtn.snp.top).offset(-20)
        })
        self.focusAreaCollectionView?.isHidden = true
        focusTitle.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        searchBar.becomeFirstResponder()
    }
    
    //MARK: - Buttons
    
    @objc private func dissmissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clearAllButtonTapped(sender: UIButton) {
        self.searchBar.text = ""
        self.listSelectedAreas = []
        self.focusAreaCollectionView?.reloadData()
        UIView.animate(withDuration: 0.3) {
            sender.layer.backgroundColor =  UIColor.gray.cgColor
        }
        UIView.animate(withDuration: 0.3) {
            sender.layer.backgroundColor =  UIColor.white.cgColor
        }
    }
    
    @objc func doneButtonTapped() {
        
        var listSelected : [String] = []
        
        for areasID in self.listSelectedAreas {
            listSelected.append("\(areasID)")
        }
        
        let searchResultVC = VC_MainPageSearchResults()
        searchResultVC.searchKeyword = self.searchBar.text!
        searchResultVC.searchFocusAreas = listSelected
        self.navigationController?.pushViewController(searchResultVC, animated: true)
    }
    
    //MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.doneButtonTapped()
    }
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listFocusAreas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chipCell", for: indexPath) as! CC_ChipSelectionCell
        
        let cellData = listFocusAreas[indexPath.row]
        
        cell.selectOption.text = cellData.areaTitle
        cell.layoutSubviews()
        
        //check cell isSelected
        for selection in self.listSelectedAreas {
            if selection == cellData.areaId {
                cell.layoutView.backgroundColor = UIColor.init(hexString: "718cfe")
                cell.selectOption.font = setFontSize(size: 14, weight: .semibold)
                cell.selectOption.textColor = .white
                
                return cell
            }
        }
        
        cell.layoutView.backgroundColor = .white
        cell.selectOption.font = setFontSize(size: 14, weight: .regular)
        cell.selectOption.textColor = UIColor.init(hexString: "929292")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellData = listFocusAreas[indexPath.row]

        // your label font.
        let font = setFontSize(size: 14, weight: .regular)

        // to get the exact width for label according to ur label font and Text.
        let size = cellData.areaTitle.size(withAttributes: [NSAttributedString.Key.font: font])

        // some extraSpace give if like so.
        let extraSpace : CGFloat = 32 + 20
        let width = size.width + extraSpace
        return CGSize(width:width, height: 46)
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.dissmissKeyboard()

        let cell = collectionView.cellForItem(at: indexPath) as! CC_ChipSelectionCell
        let cellData = self.listFocusAreas[indexPath.row]
        
        //check cell isSelected
        for selection in self.listSelectedAreas {
            if selection == cellData.areaId {
                
                // Remove data
                if let index = self.listSelectedAreas.firstIndex(of: selection) {
                    self.listSelectedAreas.remove(at: index)
                    
                    cell.layoutView.backgroundColor = .white
                    cell.selectOption.font = setFontSize(size: 14, weight: .regular)
                    cell.selectOption.textColor = UIColor.init(hexString: "929292")
                    
                    return
                }
            }
        }
        
        self.listSelectedAreas.append(cellData.areaId)
        cell.layoutView.backgroundColor = UIColor.init(hexString: "718cfe")
        cell.selectOption.font = setFontSize(size: 14, weight: .semibold) 
        cell.selectOption.textColor = .white
    }
}
