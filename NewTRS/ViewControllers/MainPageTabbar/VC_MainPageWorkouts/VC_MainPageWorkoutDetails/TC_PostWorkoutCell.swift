//
//  TC_PostWorkoutCell.swift
//  NewTRS
//
//  Created by Phuong Duy on 10/8/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//
import UIKit

class TC_PostWorkoutCell: UITableViewCell, VideoCellDelegate {
    
    let listPostScroll          = UIScrollView()
    private var listPostVideos  : [VideoDataSource] = []
    var delegate                : VideoCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        listPostScroll.showsHorizontalScrollIndicator = false
        self.addSubview(listPostScroll)
        listPostScroll.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadListPostData(listVideoData: [VideoDataSource]) {
        // Remove all old cell
        for subView in listPostScroll.subviews {
            subView.removeFromSuperview()
        }
        
        let newVideos = listVideoData // KH 3 videos
//        if newVideos.count > 1 {
//            newVideos.removeLast() // remove thằng cuối lấy 2 thằng đầu
//        }
        
        // Reload scrollView
        let size = CGSize(width: 250, height: 140)
        var index = 0
        
        for videoData in newVideos {
            
            let frame = CGRect.init(x: 20 + CGFloat(index)*(size.width + 10), y: 0, width: size.width, height: size.height)
            
            let cell = VW_RetangleVideoViewCellTagging.init(frame: frame)
            cell.delegate = self
            cell.showDownloadOption(isHidden: true)
            cell.showPrePostLabel(isHidden: false)
            cell.reloadLayout()
            listPostScroll.addSubview(cell)
            
            cell.setVideoDataSource(newVideoData: videoData)
            
            index += 1
        }
        
        listPostScroll.contentSize = CGSize.init(width: CGFloat(newVideos.count)*(size.width + 10) + 30, height: size.height)
    }
    
    //MARK: - VideoCellDelegate
    func didSelectVideo(videoData: VideoDataSource) {
        if self.delegate != nil {
            delegate?.didSelectVideo(videoData: videoData)
        }
    }
    
    func didSelectDownloadVideo(videoData: VideoDataSource) {
        //
    }
    
    func didDeleteVideo(videoData: VideoDataSource) {
        //
    }
}
