//
//  VC_MainPageFilterWorkouts.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/22/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageFilterWorkouts: UIViewController,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let pageScroll                  = UIScrollView()
    
    var equipmentCollectionView     : UICollectionView?
    var focusAreaCollectionView     : UICollectionView?
    
    let doneBtn                     = UIButton()
    
    var selectedTimeFilterBtn       = UIButton()
    var minSelectedFilterOption     = kZeroMinsFilter
    var maxSelectedFilterOption     = kAllMinsFilter
    
    let preSwitcher                 = UISwitch()
    let postSwitcher                = UISwitch()
    
    let listEquipment               = _AppCoreData.listSystemEquipments
    let listFocusAreas              = _AppCoreData.listSystemFocusAreas
    
    var selectedEquipment           : [Int] = []
    var selectedFocusArea           : [Int] = []
    
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
        
        doneBtn.setTitle(NSLocalizedString("kApplyBtn", comment: ""), for: .normal)
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
        
        pageScroll.showsVerticalScrollIndicator = false
        self.view.addSubview(pageScroll)
        pageScroll.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalTo(doneBtn.snp.top).offset(-10)
        }
                
        //MARK: Equipments Layout
        let equipmentTitle = UILabel()
        equipmentTitle.text = NSLocalizedString("kFilterEquipment", comment: "")
        equipmentTitle.font = setFontSize(size: 18, weight: .bold)
        equipmentTitle.textColor = UIColor.init(hexString: "333333")
        pageScroll.addSubview(equipmentTitle)
        equipmentTitle.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(20)
        }

        let equipmentLayout = ChipSelectionFlowLayout()
        equipmentLayout.minimumInteritemSpacing = 0
        equipmentLayout.minimumLineSpacing = 0
        equipmentLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 30, right: 0)
        equipmentLayout.scrollDirection = .vertical

        self.equipmentCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: equipmentLayout)
        self.equipmentCollectionView?.isScrollEnabled = false
        self.equipmentCollectionView?.backgroundColor = .white
        self.equipmentCollectionView?.register(CC_ChipSelectionCell.self, forCellWithReuseIdentifier: "chipCell")
        self.equipmentCollectionView?.dataSource = self
        self.equipmentCollectionView?.delegate = self
        pageScroll.addSubview(equipmentCollectionView!)
        equipmentCollectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(equipmentTitle.snp.bottom).offset(10)
            make.centerX.width.equalToSuperview()
        })
        
        //MARK: Focus Layout
        let focusTitle = UILabel()
        focusTitle.text = NSLocalizedString("kFocusAreaTitle", comment: "")
        focusTitle.font = setFontSize(size: 18, weight: .bold)
        focusTitle.textColor = UIColor.init(hexString: "333333")
        pageScroll.addSubview(focusTitle)
        focusTitle.snp.makeConstraints { (make) in
            make.top.equalTo(equipmentCollectionView!.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(20)
        }

        let focusLayout = ChipSelectionFlowLayout()
        focusLayout.minimumInteritemSpacing = 0
        focusLayout.minimumLineSpacing = 0
        focusLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 30, right: 0)
        focusLayout.scrollDirection = .vertical
        
        self.focusAreaCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: focusLayout)
        self.focusAreaCollectionView?.isScrollEnabled = false
        self.focusAreaCollectionView?.backgroundColor = .white
        self.focusAreaCollectionView?.register(CC_ChipSelectionCell.self, forCellWithReuseIdentifier: "chipCell")
        self.focusAreaCollectionView?.dataSource = self
        self.focusAreaCollectionView?.delegate = self
        pageScroll.addSubview(focusAreaCollectionView!)
        focusAreaCollectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(focusTitle.snp.bottom).offset(10)
            make.centerX.width.equalToSuperview()
        })
        
        //MARK: Duration
        let durationTitle = UILabel()
        durationTitle.text = NSLocalizedString("kDurationTitle", comment: "")
        durationTitle.font = setFontSize(size: 18, weight: .bold)
        durationTitle.textColor = UIColor.init(hexString: "333333")
        pageScroll.addSubview(durationTitle)
        durationTitle.snp.makeConstraints { (make) in
            make.top.equalTo(focusAreaCollectionView!.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(20)
        }

        let filterTabbar = UIView()
            pageScroll.addSubview(filterTabbar)
        filterTabbar.snp.makeConstraints { (make) in
            make.top.equalTo(durationTitle.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(30)
        }

        self.loadWorkoutFilterOptionView(tabbar: filterTabbar)

        let preVideoFilter = UILabel()
        preVideoFilter.font = setFontSize(size: 14, weight: .semibold)
        preVideoFilter.textColor = UIColor.init(hexString: "666666")
        preVideoFilter.text = NSLocalizedString("kPreVideoFilterOnly", comment: "")
        pageScroll.addSubview(preVideoFilter)
        preVideoFilter.snp.makeConstraints { (make) in
            make.top.equalTo(filterTabbar.snp.bottom).offset(30)
            make.left.equalTo(filterTabbar).offset(20)
        }

        preSwitcher.addTarget(self, action: #selector(swtchValueChange(switcher:)), for: .valueChanged)
        pageScroll.addSubview(preSwitcher)
        preSwitcher.snp.makeConstraints { (make) in
            make.right.equalTo(filterTabbar).offset(-20)
            make.centerY.equalTo(preVideoFilter)
        }

        let postVideoFilter = UILabel()
        postVideoFilter.font = setFontSize(size: 14, weight: .semibold)
        postVideoFilter.textColor = UIColor.init(hexString: "666666")
        postVideoFilter.text = NSLocalizedString("kPostVideoFilterOnly", comment: "")
        pageScroll.addSubview(postVideoFilter)
        postVideoFilter.snp.makeConstraints { (make) in
            make.top.equalTo(preVideoFilter.snp.bottom).offset(20)
            make.left.equalTo(filterTabbar).offset(20)
            make.bottom.equalToSuperview().offset(-70)
        }

        postSwitcher.addTarget(self, action: #selector(swtchValueChange(switcher:)), for: .valueChanged)
        pageScroll.addSubview(postSwitcher)
        postSwitcher.snp.makeConstraints { (make) in
            make.right.equalTo(filterTabbar).offset(-20)
            make.centerY.equalTo(postVideoFilter)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.layoutIfNeeded()
        
        let equipmentHeight = equipmentCollectionView!.collectionViewLayout.collectionViewContentSize.height
        equipmentCollectionView?.snp.makeConstraints({ (make) in
            make.height.equalTo(equipmentHeight)
        })
        
        let focusHeight = focusAreaCollectionView!.collectionViewLayout.collectionViewContentSize.height
        focusAreaCollectionView?.snp.makeConstraints({ (make) in
            make.height.equalTo(focusHeight)
        })
    }
    
    //MARK: - UI
    
    func loadWorkoutFilterOptionView(tabbar: UIView) {
        
        let allOption = selectedTimeFilterBtn
        allOption.isSelected = true
        allOption.setTitle(NSLocalizedString("kFilterAll", comment: ""), for: .normal)
        allOption.setTitleColor(UIColor.init(hexString: "666666"), for: .selected)
        allOption.setTitleColor(UIColor.init(hexString: "a9a9a9"), for: .normal)
        allOption.titleLabel?.font = setFontSize(size: 14, weight: .semibold)
        allOption.addTarget(self, action: #selector(timeFilterButtonTapped(btn:)), for: .touchUpInside)
        allOption.tag = 0
        tabbar.addSubview(allOption)
        allOption.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        let space1 = UIView()
        tabbar.addSubview(space1)
        space1.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(allOption.snp.right)
            make.height.equalTo(30)
        }
        
        let tenMinOption = UIButton()
        tenMinOption.setTitle(NSLocalizedString("kFilter10min", comment: ""), for: .normal)
        tenMinOption.setTitleColor(UIColor.init(hexString: "666666"), for: .selected)
        tenMinOption.setTitleColor(UIColor.init(hexString: "a9a9a9"), for: .normal)
        tenMinOption.titleLabel?.font = setFontSize(size: 14, weight: .regular)
        tenMinOption.tag = 1
        tenMinOption.addTarget(self, action: #selector(timeFilterButtonTapped(btn:)), for: .touchUpInside)
        tabbar.addSubview(tenMinOption)
        tenMinOption.snp.makeConstraints { (make) in
            make.left.equalTo(space1.snp.right)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        let space2 = UIView()
        tabbar.addSubview(space2)
        space2.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(tenMinOption.snp.right)
            make.height.equalTo(30)
            make.width.equalTo(space1)
        }
        
        let twenMinOption = UIButton()
        twenMinOption.setTitle(NSLocalizedString("kFilter20min", comment: ""), for: .normal)
        twenMinOption.setTitleColor(UIColor.init(hexString: "666666"), for: .selected)
        twenMinOption.setTitleColor(UIColor.init(hexString: "a9a9a9"), for: .normal)
        twenMinOption.titleLabel?.font = setFontSize(size: 14, weight: .regular)
        twenMinOption.tag = 2
        twenMinOption.addTarget(self, action: #selector(timeFilterButtonTapped(btn:)), for: .touchUpInside)
        tabbar.addSubview(twenMinOption)
        twenMinOption.snp.makeConstraints { (make) in
            make.left.equalTo(space2.snp.right)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        let space3 = UIView()
        tabbar.addSubview(space3)
        space3.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(twenMinOption.snp.right)
            make.height.equalTo(30)
            make.width.equalTo(space1)
        }
        
        let thirdMinOption = UIButton()
        thirdMinOption.setTitle(NSLocalizedString("kFilter30min", comment: ""), for: .normal)
        thirdMinOption.setTitleColor(UIColor.init(hexString: "666666"), for: .selected)
        thirdMinOption.setTitleColor(UIColor.init(hexString: "a9a9a9"), for: .normal)
        thirdMinOption.titleLabel?.font = setFontSize(size: 14, weight: .regular)
        thirdMinOption.tag = 3
        thirdMinOption.addTarget(self, action: #selector(timeFilterButtonTapped(btn:)), for: .touchUpInside)
        tabbar.addSubview(thirdMinOption)
        thirdMinOption.snp.makeConstraints { (make) in
            make.left.equalTo(space3.snp.right)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
    }
    
    //MARK: - Buttons
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clearAllButtonTapped(sender: UIButton) {
        self.selectedEquipment = []
        self.equipmentCollectionView?.reloadData()
        
        self.selectedFocusArea = []
        self.focusAreaCollectionView?.reloadData()
        
        self.minSelectedFilterOption     = kZeroMinsFilter
        self.maxSelectedFilterOption     = kAllMinsFilter
        
        self.preSwitcher.isOn = false
        self.postSwitcher.isOn = false
        
        UIView.animate(withDuration: 0.3) {
            sender.layer.backgroundColor =  UIColor.gray.cgColor
        }
        UIView.animate(withDuration: 0.3) {
            sender.layer.backgroundColor =  UIColor.white.cgColor
        }
    }
    
    @objc func doneButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func timeFilterButtonTapped(btn: UIButton) {
        selectedTimeFilterBtn.isSelected = false
        selectedTimeFilterBtn.titleLabel?.font = setFontSize(size: 14, weight: .regular)
        
        btn.isSelected = true
        btn.titleLabel?.font = setFontSize(size: 14, weight: .semibold)
        
        selectedTimeFilterBtn = btn
        
        switch btn.tag {
        case 0:
            //call filter All
            self.minSelectedFilterOption = kZeroMinsFilter
            self.maxSelectedFilterOption = kAllMinsFilter
            break
        case 1:
            //call filter 10 min
            self.minSelectedFilterOption = kZeroMinsFilter
            self.maxSelectedFilterOption = kFifteenMaxFilter
            break
        case 2:
            //call filter 20 min
            self.minSelectedFilterOption = kFifteenMinsFilter
            self.maxSelectedFilterOption = kTwentyFiveMaxFilter
            break
        default:
            //call filter 30 min
            self.minSelectedFilterOption = kTwentyFiveMinsFilter
            self.maxSelectedFilterOption = kThirtyFiveMaxFilter//kThirtyMaxFilter
            break
        }
    }
    
    @objc func swtchValueChange(switcher: UISwitch) {
        if switcher == preSwitcher {
            if switcher.isOn {
                postSwitcher.isOn = false
            }
        }
        else if switcher == postSwitcher {
            if switcher.isOn {
                preSwitcher.isOn = false
            }
        }
    }
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.equipmentCollectionView {
            return listEquipment.count
        } else if collectionView == self.focusAreaCollectionView {
            return listFocusAreas.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chipCell", for: indexPath) as! CC_ChipSelectionCell
        
        if collectionView == self.equipmentCollectionView {
            let cellData = self.listEquipment[indexPath.row]
            cell.selectOption.text = cellData.equipmentTitle
            
            cell.layoutSubviews()
            
            //check cell isSelected
            for selection in self.selectedEquipment {
                if selection == cellData.equipmentId {
                    cell.layoutView.backgroundColor = UIColor.init(hexString: "718cfe")
                    cell.selectOption.font = setFontSize(size: 14, weight: .semibold)
                    cell.selectOption.textColor = .white
                    
                    return cell
                }
            }
            
        } else if collectionView == self.focusAreaCollectionView {
            let cellData = self.listFocusAreas[indexPath.row]
            cell.selectOption.text = cellData.areaTitle
            
            cell.layoutSubviews()
            
            //check cell isSelected
            for selection in self.selectedFocusArea {
                if selection == cellData.areaId {
                    cell.layoutView.backgroundColor = UIColor.init(hexString: "718cfe")
                    cell.selectOption.font = setFontSize(size: 14, weight: .semibold)
                    cell.selectOption.textColor = .white
                    
                    return cell
                }
            }
        }
        
        cell.layoutSubviews()
        
        cell.layoutView.backgroundColor = .white
        cell.selectOption.font = setFontSize(size: 14, weight: .regular)
        cell.selectOption.textColor = UIColor.init(hexString: "929292")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var string = ""
        if collectionView == self.equipmentCollectionView {
            string = self.listEquipment[indexPath.row].equipmentTitle
        } else if collectionView == self.focusAreaCollectionView {
            string = self.listFocusAreas[indexPath.row].areaTitle
        }
        
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
        
//        let cell = collectionView.cellForItem(at: indexPath) as! CC_ChipSelectionCell
//
//        cell.layoutView.backgroundColor = UIColor.init(hexString: "718cfe")
//        cell.selectOption.font = setFontSize(size: 14, weight: .semibold)
//        cell.selectOption.textColor = .white
//
//        if collectionView == self.equipmentCollectionView {
//            self.selectedEquipment.append(self.listEquipment[indexPath.row].equipmentId)
//        } else if collectionView == self.focusAreaCollectionView {
//            self.selectedFocusArea.append(self.listFocusAreas[indexPath.row].areaId)
//        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CC_ChipSelectionCell
        
        if collectionView == self.equipmentCollectionView {
            let cellData = self.listEquipment[indexPath.row]
            
            //check cell isSelected
            for selection in self.selectedEquipment {
                if selection == cellData.equipmentId {
                    
                    // Remove data
                    if let index = self.selectedEquipment.firstIndex(of: selection) {
                        self.selectedEquipment.remove(at: index)
                        
                        cell.layoutView.backgroundColor = .white
                        cell.selectOption.font = setFontSize(size: 14, weight: .regular)
                        cell.selectOption.textColor = UIColor.init(hexString: "929292")
                        
                        return
                    }
                }
            }
            
            self.selectedEquipment.append(cellData.equipmentId)
            cell.layoutView.backgroundColor = UIColor.init(hexString: "718cfe")
            cell.selectOption.font = setFontSize(size: 14, weight: .semibold)
            cell.selectOption.textColor = .white
            
        }
            
        else if collectionView == self.focusAreaCollectionView
        {
            let cellData = self.listFocusAreas[indexPath.row]
            
            //check cell isSelected
            for selection in self.selectedFocusArea {
                if selection == cellData.areaId {
                    
                    // Remove data
                    if let index = self.selectedFocusArea.firstIndex(of: selection) {
                        self.selectedFocusArea.remove(at: index)
                        
                        cell.layoutView.backgroundColor = .white
                        cell.selectOption.font = setFontSize(size: 14, weight: .regular)
                        cell.selectOption.textColor = UIColor.init(hexString: "929292")
                        
                        return
                    }
                }
            }
            
            self.selectedFocusArea.append(cellData.areaId)
            cell.layoutView.backgroundColor = UIColor.init(hexString: "718cfe")
            cell.selectOption.font = setFontSize(size: 14, weight: .semibold)
            cell.selectOption.textColor = .white
        }
    }
}
