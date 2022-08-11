//
//  VC_MainPageWorkoutCategory.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/22/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

enum CollectionType : Int {
    case workout = 1
    case sport = 2
    case archetype = 3
}

class VC_MainPageWorkoutCategory: UIViewController,
                                    UICollectionViewDataSource, UICollectionViewDelegate,
                                    UICollectionViewDelegateFlowLayout {
    
    let thumbnailImage  = UIImageView()
    let backBtn         = UIButton()
    let filterBtn       = UIButton()
    
    let workoutTitle    = UILabel()
    
    var collectionView  : UICollectionView?
    var collectionType  : CollectionType = .workout
    var listCategories  : [CategoryDataSource] = []
    
    let loadingAnimation    = VW_LoadingAnimation()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        thumbnailImage.contentMode = .scaleAspectFill
        thumbnailImage.layer.masksToBounds = true
        self.view.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(270)
        }
        
        let opacityView = UIView()
        opacityView.backgroundColor = .black
        opacityView.layer.opacity = 0.2
        thumbnailImage.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalTo(thumbnailImage)
        }
        
        let fakeNavigationBar = UIView()
        thumbnailImage.addSubview(fakeNavigationBar)
        fakeNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        
        self.view.layoutIfNeeded()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.frame = fakeNavigationBar.bounds
        gradientLayer.locations = [0, 1.0]
        fakeNavigationBar.layer.addSublayer(gradientLayer)
        
        backBtn.setBackgroundImage(UIImage.init(named: "back_white_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(35)
            make.height.width.equalTo(30)
        }
        
        workoutTitle.font = setFontSize(size: 18, weight: .bold)
        workoutTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(workoutTitle)
        workoutTitle.snp.makeConstraints { (make) in
            make.top.equalTo(thumbnailImage.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view).offset(-40)
            make.height.equalTo(18)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
        
        self.collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        self.collectionView?.register(CC_SquareCategoryCell.self, forCellWithReuseIdentifier: "videoCell")
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = .white
        self.view.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(workoutTitle.snp.bottom).offset(16)
            make.centerX.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.reloadData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Data
    
    func reloadData() {
        self.loadingAnimation.isHidden = false
        
        switch self.collectionType {
        case .workout:
            let _ = _AppDataHandler.getWorkoutCategories(limit: 50,
                                                 page: 1)
            { (isSuccess, error, listCategory) in
                self.loadingAnimation.isHidden = true
                if isSuccess {
                    self.listCategories = listCategory
                    self.collectionView?.reloadData()
                } else {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                    return
                }
            }
            break
        case .sport:
            let _ = _AppDataHandler.getSportCategories(limit: 50,
                                               page: 1)
            { (isSuccess, error, listCategory) in
                self.loadingAnimation.isHidden = true
                if isSuccess {
                    self.listCategories = listCategory
                    self.collectionView?.reloadData()
                } else {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                    return
                }
            }
            break
        case .archetype:
            let _ = _AppDataHandler.getArchetypeCategories(limit: 50,
                                                   page: 1)
            { (isSuccess, error, listCategory) in
                self.loadingAnimation.isHidden = true
                if isSuccess {
                    self.listCategories = listCategory
                    self.collectionView?.reloadData()
                } else {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                    return
                }
            }
            break
        }
    }
    
    //MARK: - Button
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! CC_SquareCategoryCell
        
        let cellData = self.listCategories[indexPath.row]
        cell.thumbnailImage.image = UIImage(named: "default_thumbnail_image")
        cell.updateCategoryInfo(categoryData: cellData)
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.size.width - 50)/2
        return CGSize(width: width, height: width )
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cellData = self.listCategories[indexPath.row]
        
        let detailVC = VC_MainPageWorkoutDetails()
        detailVC.setDataSource(newData: cellData)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
