//
//  ApplicationVideoManager.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import ObjectMapper

protocol ApplicationVideoManagerDelegate {
    func didUpdateDownloadProgess(video: VideoDownloadedDataSource, progress: Double)
}

class ApplicationVideoManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    private var listDownloadedVideo     : [VideoDownloadedDataSource] = [] {
        didSet {
            self.syncDownloadingData()
        }
    }
    
    private lazy var downloadsSession: URLSession = {
        
        let configuration = URLSessionConfiguration.background(withIdentifier:"\(Bundle.main.bundleIdentifier!).background");
        configuration.isDiscretionary = true
        configuration.sessionSendsLaunchEvents = true
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil);
        
        return session;
    }()
    
    private var downloadTask                           : URLSessionDownloadTask?
    private var activeDownloads                        : [URL: VideoDownloadedDataSource] = [:]
    private var backgroundSessionCompletionHandler     : (() -> Void)?
    var delegate                                       : ApplicationVideoManagerDelegate?
        
    override init() {
        super.init()
        
        let userDefault = UserDefaults.standard
        if let stringData = userDefault.object(forKey: kUserDownloadedData) as? String {
            self.listDownloadedVideo = Mapper<VideoDownloadedDataSource>().mapArray(JSONString: stringData) ?? []
        }
        
        let _ = self.downloadsSession
    }
    
    func getBackgroundSessionCompletionHandler(completionHandler:@escaping () -> Void) {
        self.backgroundSessionCompletionHandler = completionHandler
    }
    
    private func calculateProgress(session : URLSession, completionHandler : @escaping (Float) -> ()) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            let progress = downloads.map({ (task) -> Float in
                if task.countOfBytesExpectedToReceive > 0 {
                    return Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
                } else {
                    return 0.0
                }
            })
            completionHandler(progress.reduce(0.0, +))
        }
    }
    //MARK: - Public function
    
    func isVideoIsDownloading(videoID : Int) -> Bool {
        for videoData in self.listDownloadedVideo {
            if videoData.videoID == videoID && videoData.videoDownloadPercent < 1 {
                return true
            }
        }
        
        return false
    }
    
    func getListDownloadedVideo() -> [VideoDownloadedDataSource] {
        return listDownloadedVideo
    }
    
    func requestDownloadVideo(videoData: VideoDataSource) {
        
        if _AppVideoManager.isVideoIsDownloading(videoID: videoData.videoID) {
            
            let alertVC = UIAlertController.init(title: NSLocalizedString("kSorryTitle", comment: ""), message: NSLocalizedString("kDownloadingMessage", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("kDownloadingContinuousBtn", comment: ""), style: .default)
            { (action) in
                alertVC.dismiss(animated: true, completion: nil)
            }
            
            let stopAction = UIAlertAction.init(title: NSLocalizedString("kDownloadingStopBtn", comment: ""),
                                                style: .cancel) { (action) in
                                                    if let index = self.listDownloadedVideo.firstIndex(where: {$0.videoID == videoData.videoID}) {
                                                        self.deleteVideo(videoData: self.listDownloadedVideo[index])
                                                    }
            }
            
            alertVC.addAction(okAction)
            alertVC.addAction(stopAction)
            if let presentedVC = _NavController.presentedViewController {
                
                if presentedVC is UIAlertController {
                    return
                }
                
                presentedVC.present(alertVC, animated: true, completion: nil)
                return
            } else {
                _NavController.present(alertVC, animated: true, completion: nil)
            }
            
            return
        }
        
        for videoDownloaded in self.listDownloadedVideo {
            if videoDownloaded.videoID == videoData.videoID {
                
                _NavController.presentAlertForCase(title: NSLocalizedString("kDownloadTitle", comment: ""),
                                                   message: NSLocalizedString("kVideoDownloaded", comment: ""))
                NotificationCenter.default.post(name: kDownloadVideoCancelNotification, object: nil, userInfo: ["video_id": videoData.videoID])
                return
            }
        }
        
        if _AppVideoManager.getListDownloadedVideo().count == 5 {
            _NavController.presentAlertForCase(title: NSLocalizedString("kSorryTitle", comment: ""),
                                               message: NSLocalizedString("kDownloadVideoLitmit", comment: ""))
            NotificationCenter.default.post(name: kDownloadVideoCancelNotification, object: nil, userInfo: ["video_id": videoData.videoID])
            return
        }
        
        let videoDownload = VideoDownloadedDataSource.init(JSONString: "{}")
        videoDownload?.videoID = videoData.videoID
        listDownloadedVideo.append(videoDownload!)
        
        _AppDataHandler.getVideoDownloadableLink(videoData: videoData)
        { (isSuccess, error, videoDownloadData) in
            
            if isSuccess {
                if videoDownloadData != nil {
//                    videoDownloadData?.videoDownloadLink = "http://techslides.com/demos/sample-videos/small.mp4"
                    videoDownloadData!.videoTitle = videoData.videoTitle
                    videoDownloadData!.savedDate = Int(Date().timeIntervalSince1970)
                    self.downloadVideo(videoData: videoDownloadData!)
                    self.downloadThumbnailImage(videoData: videoDownloadData!)
                    
                    if let index = self.listDownloadedVideo.firstIndex(where: {$0.videoID == videoDownloadData?.videoID}) {
                        self.listDownloadedVideo[index] = videoDownloadData!
                    }
                }
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kDownloadBtn", comment: ""),
                                                   message: error)
            }
        }
    }
    
    func deleteVideo(videoData: VideoDownloadedDataSource) {
        
        self.cancelDownload(videoData: videoData)
        
        let documentsFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageFileURL = documentsFileURL.appendingPathComponent(String(format: "Downloaded/%ld.png", videoData.videoID))
        let videoFileURL = documentsFileURL.appendingPathComponent(String(format: "Downloaded/%ld.mp4", videoData.videoID))
        
        do {
            try FileManager.default.removeItem(at: imageFileURL)
            try FileManager.default.removeItem(at:videoFileURL)
            
            if let index = self.listDownloadedVideo.firstIndex(of: videoData) {
                self.listDownloadedVideo.remove(at: index)
                NotificationCenter.default.post(name: kDownloadVideoDeletedNotification, object: nil)
            }
        } catch {
            do {
                //file exists, now try deleting the file
                try FileManager.default.removeItem(at:videoFileURL)
                print("File deleted")
            } catch {
                print("Error")
            }
            
            print("Could not delete file: \(error)")
            if let index = self.listDownloadedVideo.firstIndex(of: videoData) {
                self.listDownloadedVideo.remove(at: index)
                NotificationCenter.default.post(name: kDownloadVideoDeletedNotification, object: nil)
            }
        }
    }
    
    func checkDoneDownloadManager() {
        if listDownloadedVideo.count == 0 {return}
        
        for videoData in listDownloadedVideo {
            if videoData.videoDownloadPercent < 1 {
                downloadVideo(videoData: videoData)
            }
        }
    }
    //MARK: - Private functions
    
    private func downloadVideo(videoData: VideoDownloadedDataSource) {
        
        guard let downloadUrl = URL(string: videoData.videoDownloadLink) else {
            return
        }
        
        self.downloadTask = _AppVideoManager.downloadsSession.downloadTask(with: downloadUrl);
        self.downloadTask!.resume();
        videoData.task = downloadTask
        self.activeDownloads[downloadUrl] = videoData
    }
    
    private func downloadThumbnailImage(videoData: VideoDownloadedDataSource) {
        guard let downloadUrl = URL(string: videoData.imageDownloadLink) else {
            return
        }
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            fileURL = fileURL.appendingPathComponent(String(format: "Downloaded/%ld.png", videoData.videoID))
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(downloadUrl, to: destination).response { response in
            
            print(response.destinationURL as Any)
            
//            if let index = self.listDownloadedVideo.firstIndex(of: videoData) {
//                let videoDownloadedData = self.listDownloadedVideo[index]
//                videoDownloadedData.videoDownloadPercent = 1
//                self.listDownloadedVideo[index] = videoDownloadedData
//            }
        }
    }
        
    func syncDownloadingData () {
        print("didChange")
        
        if let jsonString = self.getListDownloadedVideo().toJSONString() {
            let userDefault = UserDefaults.standard
            userDefault.set(jsonString, forKey: kUserDownloadedData)
        }
    }
    
    func cancelDownload (videoData: VideoDownloadedDataSource) {
        guard let downloadUrl = URL(string: videoData.videoDownloadLink) else {
            return
        }
        if let index = self.listDownloadedVideo.firstIndex(where: {$0.videoID == videoData.videoID}) {
            listDownloadedVideo[index].task?.cancel()
            activeDownloads[downloadUrl] = nil
        }
    }
    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if (error != nil){
            print("BackgroundMode:\(error?.localizedDescription ?? "error")")
        }
        else{
            print("BackgroundMode: success")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        if totalBytesExpectedToWrite > 0 {
            guard
                let url = downloadTask.originalRequest?.url,
                let videoData = self.activeDownloads[url]
                else {
                    return
            }
            // 2
            if let delegate = self.delegate {
                let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                if (progress < 1) {
                    delegate.didUpdateDownloadProgess(video: videoData, progress: Double(progress))
                    debugPrint("Progress \(downloadTask) \(progress)")
                }
            }
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        print("Download finished: \(location)")
        
        guard let sourceURL = downloadTask.originalRequest?.url else {
            return
        }
        
        let download = self.activeDownloads[sourceURL]
        self.activeDownloads[sourceURL] = nil
        
        if download == nil {return}
        // 2
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = fileURL.appendingPathComponent(String(format: "Downloaded/%ld.mp4", download!.videoID))
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        
        if let delegate = self.delegate {
            delegate.didUpdateDownloadProgess(video: download!, progress: 1)
            if let index = self.listDownloadedVideo.firstIndex(of: download!) {
                download?.videoDownloadPercent = 1
                download?.task = nil 
                self.listDownloadedVideo[index] = download!
            }
             NotificationCenter.default.post(name: kDownloadVideoDoneNotification, object: nil, userInfo: ["video_id": download!.videoID])
        }
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
    }
    
    // MARK: - URLSessionDelegate
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundSessionCompletionHandler?()
            self.backgroundSessionCompletionHandler = nil
        }
    }
    
}
