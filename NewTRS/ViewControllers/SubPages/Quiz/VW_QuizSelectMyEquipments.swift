//
//  VW_QuizMutilSelectionContent.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/11/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol VW_QuizSelectMyEquipmentDelegate {
    func doneButtonTapped(selectedEquipmentIDs: [String])
}

class VW_QuizSelectMyEquipments: UIView, UIScrollViewDelegate {
    
    var delegate : VW_QuizSelectMyEquipmentDelegate?
    private let questionLabel   = UILabel()
    private let scrollView      = UIScrollView()
    
    let doneBtn                 = UIButton()
    var listTitle               : [UILabel] = []
    var selectedEquipmentIDs    : [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        questionLabel.text = NSLocalizedString("kAskUserEquipment", comment: "")
        questionLabel.font = setFontSize(size: 27, weight: .bold)//HurmeGeometricSans2 
        questionLabel.textAlignment = .center
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 0
        self.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { (make) in
            make.centerX.top.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(questionLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(160)
        }
        
        self.loadScrollView()
        
        doneBtn.setTitle(NSLocalizedString("kDoneBtn", comment: "").uppercased(), for: .normal)
        doneBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        doneBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        doneBtn.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneBtn.layer.cornerRadius = 20
        self.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.bottom).offset(30)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // UI
    
    func loadScrollView() {
        let listSelections = _AppCoreData.listSystemEquipments
        
        
        let topView  = UIView()
        scrollView.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(self).offset(-40)
            make.height.equalTo(1)
        }
        
        var markView = topView
        var index = 0
        
        for selection in listSelections {
            
            
            let button = UIButton()
            button.tag = index
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 5
            button.layer.opacity = 0.6
            button.addTarget(self, action: #selector(selectionButtonTapped(btn:)), for: .touchUpInside)
            scrollView.addSubview(button)
            
            button.snp.makeConstraints { (make) in
                make.top.equalTo(markView.snp.bottom).offset(20)
                make.left.equalTo(topView).offset(50)
                make.width.height.equalTo(25)
            }
            
            let selectionLabel = UILabel()
            selectionLabel.numberOfLines = 0
            selectionLabel.text = selection.equipmentTitle
            selectionLabel.font = setFontSize(size: 16, weight: .regular)
            selectionLabel.textColor = .white
            selectionLabel.layer.opacity = 0.6
            scrollView.addSubview(selectionLabel)
            selectionLabel.snp.makeConstraints { (make) in
                make.left.equalTo(button.snp.right).offset(20)
                make.centerY.equalTo(button)
//                make.height.equalTo(18)
                make.right.equalTo(topView).offset(-40)
            }
            
            listTitle.append(selectionLabel)
            markView = button
            index += 1
            
            
            //Process Hard Selelect
            
            let isHardSelect = (selection.equipmentTitle.contains("Lacrosse Ball")) ||
                (selection.equipmentTitle.contains("Foam Roller"))
            
            if isHardSelect {
                self.selectedEquipmentIDs.append("\(selection.equipmentId)")
                
                button.backgroundColor = .white
                button.setBackgroundImage(UIImage.init(named: "check_icon"), for: .normal)
                
                selectionLabel.layer.opacity = 1
                selectionLabel.font = setFontSize(size: 16, weight: .semibold)
            }
        }
        
        markView.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview().offset(-20)
        })
        
        let _ = Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

    }
    
    //MARK:- Button functions
    
    @objc func selectionButtonTapped(btn: UIButton) {
        
        let listSelections = _AppCoreData.listSystemEquipments
        let selectionEquipment = listSelections[btn.tag]
        
        let isHardSelect = (selectionEquipment.equipmentTitle.contains("Lacrosse Ball")) ||
        (selectionEquipment.equipmentTitle.contains("Foam Roller"))
        
        if isHardSelect {
            return
        }
        
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            btn.backgroundColor = .white
            btn.setBackgroundImage(UIImage.init(named: "check_icon"), for: .normal)
            
            let selectionLabel = listTitle[btn.tag]
            selectionLabel.layer.opacity = 1
            selectionLabel.font = setFontSize(size: 16, weight: .semibold)
            
            //add equipment ID
            let selectionEquipmentID = selectionEquipment.equipmentId
            self.selectedEquipmentIDs.append("\(selectionEquipmentID)")
        }
        else {
            btn.backgroundColor = .clear
            btn.setBackgroundImage(nil, for: .normal)
            
            let selectionLabel = listTitle[btn.tag]
            selectionLabel.layer.opacity = 0.6
            selectionLabel.font = setFontSize(size: 16, weight: .regular)
            
            //remove equipment ID
            let selectionEquipmentID = selectionEquipment.equipmentId
            if let index = self.selectedEquipmentIDs.firstIndex(of: "\(selectionEquipmentID)") {
                self.selectedEquipmentIDs.remove(at: index)
            }
        }
    }
    
    @objc func doneButtonTapped() {
        if delegate != nil {
            delegate?.doneButtonTapped(selectedEquipmentIDs: self.selectedEquipmentIDs)
        }
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let verticalIndicator: UIImageView = (scrollView.subviews[(scrollView.subviews.count - 1)] as? UIImageView) {
//            verticalIndicator.backgroundColor = UIColor.init(hexString: "888888")
//        }
    }
    
    @objc func runTimedCode() {
        scrollView.showsVerticalScrollIndicator = true
        if #available(iOS 13, *) {
            (scrollView.subviews[(scrollView.subviews.count - 1)].subviews[0]).backgroundColor = UIColor.white//verticalIndicator
        } else {
            if let verticalIndicator: UIImageView = (scrollView.subviews[(scrollView.subviews.count - 1)] as? UIImageView) {
                verticalIndicator.backgroundColor = UIColor.white
            }
        }
        UIView.animate(withDuration: 0.0001) {
               self.scrollView.flashScrollIndicators()
           }
    }
}
