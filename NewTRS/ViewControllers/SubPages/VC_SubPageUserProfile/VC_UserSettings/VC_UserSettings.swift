//
//  VC_UserSettings.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/25/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_UserSettings: UIViewController,
                        UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var myEquipmentCollectionView       : UICollectionView?
    let doneBtn                         = UIButton()
    let loadingAnimation                = VW_LoadingAnimation()
    
    var listEquipmet                : [SystemEquipmentDataSource] = _AppCoreData.listSystemEquipments
    var listUserSelection           : [SystemEquipmentDataSource] = _AppDataHandler.getUserProfile().userSettings.myEquipments
    
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
        
        let focusTitle  = UILabel()
        focusTitle.text = NSLocalizedString("kMyEquipmentsList", comment: "")
        focusTitle.font = setFontSize(size: 24, weight: .bold)
        focusTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(focusTitle)
        focusTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        
        let myEquipment  = UILabel()
        myEquipment.text = NSLocalizedString("kMyEquipmentTitle", comment: "")
        myEquipment.font = setFontSize(size: 18, weight: .bold)
        myEquipment.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(myEquipment)
        myEquipment.snp.makeConstraints { (make) in
            make.top.equalTo(focusTitle.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
        }
        
        doneBtn.setTitle(NSLocalizedString("kSaveBtn", comment: ""), for: .normal)
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
        
        self.myEquipmentCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        self.myEquipmentCollectionView?.backgroundColor = .white
        self.myEquipmentCollectionView?.register(CC_ChipSelectionCell.self, forCellWithReuseIdentifier: "chipCell")
        self.myEquipmentCollectionView?.dataSource = self
        self.myEquipmentCollectionView?.delegate = self
        self.view.addSubview(myEquipmentCollectionView!)
        myEquipmentCollectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(myEquipment.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-10)
            make.bottom.equalTo(doneBtn.snp.top).offset(-20)
        })
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Buttons
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clearAllButtonTapped(sender: UIButton) {
        let alertVC = UIAlertController.init(title: NSLocalizedString("kMessageTitle", comment: ""),
                                             message: NSLocalizedString("kEquipmentPopupMessage", comment: ""),
                                             preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                          style: .cancel) { [self] (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
            self.clearAction(sender: sender)
        }
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func clearAction(sender: UIButton) {
        self.listUserSelection = []
        for item in listEquipmet {
            if item.equipmentId == 1855 || item.equipmentId == 1856 {
                listUserSelection.append(item)
            }
        }
        self.myEquipmentCollectionView?.reloadData()
        UIView.animate(withDuration: 0.3) {
            sender.layer.backgroundColor =  UIColor.gray.cgColor
        }
        UIView.animate(withDuration: 0.3) {
            sender.layer.backgroundColor =  UIColor.white.cgColor
        }
    }
    
    @objc func doneButtonTapped() {
        
        self.loadingAnimation.isHidden = false
        let userProfile = _AppDataHandler.getUserProfile()
        userProfile.userSettings.myEquipments = self.listUserSelection
        
        _AppDataHandler.updateUserProfile(profile: userProfile) { (isSuccess, error) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                _AppDataHandler.getUserProfile().userSettings.myEquipments = self.listUserSelection
                let alertVC = UIAlertController(title: "Edit Equipment", message: "Updated successfully", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    alertVC.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""),
                                                   message: error)
            }
        }
    }
    
    //MARK: - Data
    func reloadData() {
        _AppDataHandler.reloadUserProfile()
        self.listUserSelection = _AppDataHandler.getUserProfile().userSettings.myEquipments
        self.myEquipmentCollectionView?.reloadData()
    }
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listEquipmet.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chipCell", for: indexPath) as! CC_ChipSelectionCell
        
        let cellData = self.listEquipmet[indexPath.row]
        
        cell.selectOption.text = cellData.equipmentTitle
        cell.layoutSubviews()
        
        //check cell isSelected
        for selection in self.listUserSelection {
            if selection.equipmentId == cellData.equipmentId {
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
        
        let cellData = self.listEquipmet[indexPath.row]
        let string = cellData.equipmentTitle
        
        // your label font.
        let font = setFontSize(size: 14, weight: .regular)
        
        // to get the exact width for label according to ur label font and Text.
        let size = string.size(withAttributes: [NSAttributedString.Key.font: font])
        
        // some extraSpace give if like so.
        let extraSpace : CGFloat = 32 + 20
        let width = size.width + extraSpace
        return CGSize(width:width, height: 46)
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CC_ChipSelectionCell
        
        let cellData = self.listEquipmet[indexPath.row]
        
        //check cell isSelected
        for selection in self.listUserSelection {
            if selection.equipmentId == cellData.equipmentId {
                
                if selection.equipmentId == 1855 || selection.equipmentId == 1856 {
                    return
                }
                // Remove data
                if let index = self.listUserSelection.firstIndex(of: selection) {
                    self.listUserSelection.remove(at: index)
                    
                    cell.layoutView.backgroundColor = .white
                    cell.selectOption.font = setFontSize(size: 14, weight: .regular)
                    cell.selectOption.textColor = UIColor.init(hexString: "929292")
                    
                    return
                }
            }
        }
        
        self.listUserSelection.append(cellData)
        cell.layoutView.backgroundColor = UIColor.init(hexString: "718cfe")
        cell.selectOption.font = setFontSize(size: 14, weight: .semibold)
        cell.selectOption.textColor = .white
        
    }
}
