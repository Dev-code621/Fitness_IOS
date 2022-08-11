//
//  VW_UserHistoryView.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol VW_UserHistoryViewDelegate {
    func didSelectVideoData(videoData: VideoDataSource)
}

class VW_UserHistoryView: UIView,
                            UITableViewDataSource, UITableViewDelegate {
    
    var delegate            : VW_UserHistoryViewDelegate?
    
    let tableView           = UITableView()
    let nodataLabel         = UILabel()
    
    private var listVideo   : [VideoDataSource] = []
    
    private var currentPage         : Int = 1
    private var isLoadingList       : Bool = false
    var paging                      : PagingDataSource?
    private let loadingAnimation    = VW_LoadingAnimation()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.init(hexString: "fafafa")
        tableView.register(TC_HistoryCell.self, forCellReuseIdentifier: "historyCell")
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        nodataLabel.isHidden = true
        nodataLabel.text = NSLocalizedString("kUserHistoryNoData", comment: "")
        nodataLabel.textAlignment = .center
        nodataLabel.font = setFontSize(size: 14, weight: .regular)
        nodataLabel.textColor = UIColor.init(hexString: "666666")
        nodataLabel.numberOfLines = 0
        self.addSubview(nodataLabel)
        nodataLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        loadingAnimation.isHidden = true
        self.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Data
    func setListVideo(newListVideo: [VideoDataSource]) {
        self.listVideo = newListVideo
        self.tableView.reloadData()
        
        self.nodataLabel.isHidden = !(newListVideo.count == 0)
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listVideo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWdith = UIScreen.main.bounds.size.width
        return screenWdith * 0.533
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! TC_HistoryCell
        
        let cellData = self.listVideo[indexPath.row]
        cell.setDataSource(newDataSource: cellData)
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let cellData = self.listVideo[indexPath.row]
        
        if delegate != nil {
            delegate?.didSelectVideoData(videoData: cellData)
        }
    }
    
    func reloadData() {
        self.loadingAnimation.isHidden = false
        _AppDataHandler.getUserHistoriesVideo( page: currentPage, limit: 10) { (isSucess, error, paging, listHistoriesVideo) in
            self.loadingAnimation.isHidden = true
            if isSucess {
                self.isLoadingList = false
                if self.paging?.currentPage != self.currentPage && self.paging?.currentPage != nil {
                    var list = self.listVideo
                    list.append(contentsOf: listHistoriesVideo)
                    self.listVideo = list
                } else {
                    self.listVideo = listHistoriesVideo
                }
                self.paging = paging
                self.tableView.reloadData()
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            if paging != nil {
                if paging!.maxPage > currentPage {
                    isLoadingList = true
                    currentPage += 1
                    self.reloadData()
                }
            }
        }
    }
    
}
