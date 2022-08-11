//
//  ApplicationCoreData.swift
//  NewTRS
//
//  Created by yaya on 10/6/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import CoreData
import ObjectMapper

class ApplicationCoreData: NSObject {
    
    static let shared                   = ApplicationCoreData()
    //System Data
    var listSystemFocusAreas            : [SystemFocusAreaDataSource] = []
    var listSystemPainAreas             : [SystemPainAreaDataSource] = []
    var listSystemEquipments            : [SystemEquipmentDataSource] = []
    var listBonusData                   : [SystemBonusDataSource] = []
    var listSystemFilterAreas            : [SystemFocusAreaDataSource] = []
    
    //Mobility Test
    var listTrunkVideo                  : [MobilityTestVideo] = []
    var listShouderVideo                : [MobilityTestVideo] = []
    var listHipVideo                    : [MobilityTestVideo] = []
    var listAnkleVideo                  : [MobilityTestVideo] = []
    var returnVideo                     : MobilityTestVideo?

    
    func startContext() {
        self.listSystemFocusAreas = self.getDataFocusAreas() // lay data cache co san
        self.forceRefreshFocusArea() // lay data moi de replace data cu
        
        self.listSystemPainAreas = self.getDataPainAreas()
        self.forceRefreshPainArea()
        
        self.listSystemEquipments = self.getDataEquipment()
        self.forceRefreshEquipment()
        
        self.listBonusData = self.getDataBonus()
        self.forceRefreshBonus()
        
        self.listSystemFilterAreas = self.getDataFilterAreas()
        self.forceRefreshFilterArea()
        
        self.listShouderVideo = self.getDataShoulder()
        self.listTrunkVideo = self.getDataTruck()
        self.listHipVideo = self.getDataHip()
        self.listAnkleVideo = self.getDataAnkle()
        self.forceRefeshMobilityVideo()
    }
    
    private class func getContext() -> NSManagedObjectContext
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        return (delegate?.persistentContainer.viewContext)!
    }
    
    //MARK: - Focus Areas
    private func getDataFocusAreas() -> [SystemFocusAreaDataSource] {
        
        if self.listSystemFocusAreas.count > 0  {
            return self.listSystemFocusAreas
        }
        
        let managedContext = ApplicationCoreData.getContext()
        
        let request =  NSFetchRequest<NSFetchRequestResult>(entityName: "SystemFocusAreas")
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            for record in records {
                let jsonString = record.toJSONString()
                let obj = Mapper<SystemFocusAreaDataSource>().map(JSONString: jsonString!)
                listSystemFocusAreas.append(obj!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return listSystemFocusAreas
    }
    
    public func forceRefreshFocusArea() {
        // process background
        let _ =  _AppDataHandler.getListFocusAreas { (isSuccess, error) in
            if isSuccess {
            }
        }        
    }
    
    func insertSystemFocusAreas(list: [SystemFocusAreaDataSource]) {
        
        self.listSystemFocusAreas = list
        
        let managedContext = ApplicationCoreData.getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "SystemFocusAreas",
                                       in: managedContext)!
        self.deleteData(name: "SystemFocusAreas")
        for focus in list {
            let newFocus = NSManagedObject(entity: entity, insertInto: managedContext)
            newFocus.setValue(focus.areaId, forKey: "area_id")
            newFocus.setValue(focus.areaTitle, forKey: "area_title")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Filter Areas
    private func getDataFilterAreas() -> [SystemFocusAreaDataSource] {
        
        if self.listSystemFilterAreas.count > 0  {
            return self.listSystemFilterAreas
        }
        
        let managedContext = ApplicationCoreData.getContext()
        
        let request =  NSFetchRequest<NSFetchRequestResult>(entityName: "SystemFilterAreas")
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            for record in records {
                let jsonString = record.toJSONString()
                let obj = Mapper<SystemFocusAreaDataSource>().map(JSONString: jsonString!)
                listSystemFilterAreas.append(obj!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return listSystemFilterAreas
    }
    
    public func forceRefreshFilterArea() {
        // process background
        let _ =  _AppDataHandler.getListFilterAreas { (isSuccess, error) in
            if isSuccess {
            }
        }
    }
    
    func insertSystemFilterAreas(list: [SystemFocusAreaDataSource]) {
        
        self.listSystemFilterAreas = list
        
        let managedContext = ApplicationCoreData.getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "SystemFilterAreas",
                                       in: managedContext)!
        self.deleteData(name: "SystemFilterAreas")
        for focus in list {
            let newFilter = NSManagedObject(entity: entity, insertInto: managedContext)
            newFilter.setValue(focus.areaId, forKey: "area_id")
            newFilter.setValue(focus.areaTitle, forKey: "area_title")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    //MARK: - PainAreas
    private func getDataPainAreas() -> [SystemPainAreaDataSource] {
        
        if self.listSystemPainAreas.count > 0  {
            return self.listSystemPainAreas
        }
        
        let managedContext = ApplicationCoreData.getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SystemPainAreas")
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            for record in records {
                let jsonString = record.toJSONString()
                let obj = Mapper<SystemPainAreaDataSource>().map(JSONString: jsonString!)
                listSystemPainAreas.append(obj!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return listSystemPainAreas
    }
    
    func forceRefreshPainArea() {
        let _ = _AppDataHandler.getListPainAreas { (isSuccess, error) in
            if isSuccess {
            }
        }
    }
    
    func insertSystemPainAreas(list: [SystemPainAreaDataSource]) {
        
        self.listSystemPainAreas = list
        
        let managedContext = ApplicationCoreData.getContext()
        let entity =
            NSEntityDescription.entity(forEntityName: "SystemPainAreas",
                                       in: managedContext)!
        self.deleteData(name: "SystemPainAreas")
        for pain in list {
            let newPain = NSManagedObject(entity: entity, insertInto: managedContext)
            newPain.setValue(pain.painAreaId, forKey: "pain_area_id")
            newPain.setValue(pain.painAreaTitle, forKey: "pain_area_title")
            newPain.setValue(pain.painAreaKey, forKey: "pain_area_key")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Equipment
    func getDataEquipment() -> [SystemEquipmentDataSource] {
        
        if self.listSystemEquipments.count > 0  {
            return self.listSystemEquipments
        }
        
        let managedContext = ApplicationCoreData.getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SystemPainAreas")
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            for record in records {
                let jsonString = record.toJSONString()
                let obj = Mapper<SystemEquipmentDataSource>().map(JSONString: jsonString!)
                listSystemEquipments.append(obj!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return listSystemEquipments
    }
    
    func forceRefreshEquipment() {
        let _ = _AppDataHandler.getListEquipments { (isSuccess, error) in
            if isSuccess {
            }
        }
    }
    
    func insertSystemEquipment(list: [SystemEquipmentDataSource]) {
        
        self.listSystemEquipments = list
        
        let managedContext = ApplicationCoreData.getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "SystemEquipment",
                                       in: managedContext)!
        self.deleteData(name: "SystemEquipment")
        for equip in list {
            let newEquip = NSManagedObject(entity: entity, insertInto: managedContext)
            newEquip.setValue(equip.equipmentId, forKey: "equipment_id")
            newEquip.setValue(equip.equipmentTitle, forKey: "equipment_title")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Bonus
    func getDataBonus() -> [SystemBonusDataSource] {
        
        if self.listBonusData.count > 0  {
            return self.listBonusData
        }
        
        let managedContext = ApplicationCoreData.getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SystemPainAreas")
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            for record in records {
                let jsonString = record.toJSONString()
                let obj = Mapper<SystemBonusDataSource>().map(JSONString: jsonString!)
                listBonusData.append(obj!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return listBonusData
    }
    
    func forceRefreshBonus() {
        let _ = _AppDataHandler.getListBonus { (isSuccess, error) in
            if isSuccess {
            }
        }
    }
    
    func insertSystemBonus(list: [SystemBonusDataSource]) {
        
        self.listBonusData = list
        
        let managedContext = ApplicationCoreData.getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "SystemBonus",
                                       in: managedContext)!
        self.deleteData(name: "SystemBonus")
        for bonus in list {
            let newBonus = NSManagedObject(entity: entity, insertInto: managedContext)
            newBonus.setValue(bonus.bonusId, forKey: "bonus_id")
            newBonus.setValue(bonus.bonusTitle, forKey: "bonus_title")
            newBonus.setValue(bonus.bonusImage, forKey: "bonus_image")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - DELETE ENTITY
    func deleteData(name: String) {
        let managedContext = ApplicationCoreData.getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            
            for record in records {
                managedContext.delete(record)
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Mobility Shoulder Video
    func getDataShoulder() -> [MobilityTestVideo] {
        
        if self.listShouderVideo.count > 0  {
            return self.listShouderVideo
        }
        
        let managedContext = ApplicationCoreData.getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoulderVideos")
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            for record in records {
                let jsonString      = record.toJSONString()
                let jsonPoseImage   = record.value(forKey: "pose_image")
                let obj = Mapper<MobilityTestVideo>().map(JSONString: jsonString!)
                obj?.poseImages = Mapper<MobilityPoseDataSource>().map(JSONString: jsonPoseImage as! String)!
                listShouderVideo.append(obj!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return listShouderVideo
    }
    
    func insertShoulderVideo(list: [MobilityTestVideo]) {
        
        self.listShouderVideo = list
        
        let managedContext = ApplicationCoreData.getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "ShoulderVideos",
                                       in: managedContext)!
        self.deleteData(name: "ShoulderVideos")
        for shoulder in list {
            let newShoulder = NSManagedObject(entity: entity, insertInto: managedContext)
            newShoulder.setValue(shoulder.videoID, forKey: "video_id")
            newShoulder.setValue(shoulder.thumbnailImage, forKey: "image_thumbnail")
            newShoulder.setValue(shoulder.videoTitle, forKey: "video_title")
            newShoulder.setValue(shoulder.videoURLString, forKey: "video_play_url")
            newShoulder.setValue(shoulder.videoDuration, forKey: "video_duration")
            newShoulder.setValue(arrayConvertToJsonString(obj: shoulder.videoInstruction), forKey: "video_instruction")
            newShoulder.setValue(arrayConvertToJsonString(obj: shoulder.videoCompensations), forKey: "video_compensations")
            newShoulder.setValue(shoulder.poseImages.toJSONString(), forKey: "pose_image")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Mobility Truck Video
    func getDataTruck() -> [MobilityTestVideo] {
        
        if self.listTrunkVideo.count > 0  {
            return self.listTrunkVideo
        }
        
        let managedContext = ApplicationCoreData.getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TruckVideos")
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            for record in records {
                let jsonString      = record.toJSONString()
                let jsonPoseImage   = record.value(forKey: "pose_image")
                let obj = Mapper<MobilityTestVideo>().map(JSONString: jsonString!)
                obj?.poseImages = Mapper<MobilityPoseDataSource>().map(JSONString: jsonPoseImage as! String)!
                listTrunkVideo.append(obj!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return listTrunkVideo
    }
    
    func insertTruckVideo(list: [MobilityTestVideo]) {
        
        self.listTrunkVideo = list
        
        let managedContext = ApplicationCoreData.getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "TruckVideos",
                                       in: managedContext)!
        self.deleteData(name: "TruckVideos")
        for truck in list {
            let newTruck = NSManagedObject(entity: entity, insertInto: managedContext)
            newTruck.setValue(truck.videoID, forKey: "video_id")
            newTruck.setValue(truck.thumbnailImage, forKey: "image_thumbnail")
            newTruck.setValue(truck.videoTitle, forKey: "video_title")
            newTruck.setValue(truck.videoURLString, forKey: "video_play_url")
            newTruck.setValue(truck.videoDuration, forKey: "video_duration")
            newTruck.setValue(arrayConvertToJsonString(obj: truck.videoInstruction), forKey: "video_instruction")
            newTruck.setValue(arrayConvertToJsonString(obj: truck.videoCompensations), forKey: "video_compensations")
            newTruck.setValue(truck.poseImages.toJSONString(), forKey: "pose_image")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Mobility Hip Video
    func getDataHip() -> [MobilityTestVideo] {
        
        if self.listHipVideo.count > 0  {
            return self.listHipVideo
        }
        
        let managedContext = ApplicationCoreData.getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HipVideos")
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            for record in records {
                let jsonString      = record.toJSONString()
                let jsonPoseImage   = record.value(forKey: "pose_image")
                let obj = Mapper<MobilityTestVideo>().map(JSONString: jsonString!)
                obj?.poseImages = Mapper<MobilityPoseDataSource>().map(JSONString: jsonPoseImage as! String)!
                listHipVideo.append(obj!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return listHipVideo
    }
    
    func insertHipVideo(list: [MobilityTestVideo]) {
        
        self.listHipVideo = list
        
        let managedContext = ApplicationCoreData.getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "HipVideos",
                                       in: managedContext)!
        self.deleteData(name: "HipVideos")
        for hip in list {
            let newHip = NSManagedObject(entity: entity, insertInto: managedContext)
            newHip.setValue(hip.videoID, forKey: "video_id")
            newHip.setValue(hip.thumbnailImage, forKey: "image_thumbnail")
            newHip.setValue(hip.videoTitle, forKey: "video_title")
            newHip.setValue(hip.videoURLString, forKey: "video_play_url")
            newHip.setValue(hip.videoDuration, forKey: "video_duration")
            newHip.setValue(arrayConvertToJsonString(obj: hip.videoInstruction), forKey: "video_instruction")
            newHip.setValue(arrayConvertToJsonString(obj: hip.videoCompensations), forKey: "video_compensations")
            newHip.setValue(hip.poseImages.toJSONString(), forKey: "pose_image")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Mobility Ankle Video
    func getDataAnkle() -> [MobilityTestVideo] {
        
        if self.listAnkleVideo.count > 0  {
            return self.listAnkleVideo
        }
        
        let managedContext = ApplicationCoreData.getContext()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AnkleVideos")
        request.returnsObjectsAsFaults = false
        do {
            let records = try managedContext.fetch(request) as! [NSManagedObject]
            for record in records {
                let jsonString      = record.toJSONString()
                let jsonPoseImage   = record.value(forKey: "pose_image")
                let obj = Mapper<MobilityTestVideo>().map(JSONString: jsonString!)
                obj?.poseImages = Mapper<MobilityPoseDataSource>().map(JSONString: jsonPoseImage as! String)!
                listAnkleVideo.append(obj!)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return listAnkleVideo
    }
    
    func insertAnkleVideo(list: [MobilityTestVideo]) {
        
        self.listAnkleVideo = list
        
        let managedContext = ApplicationCoreData.getContext()
        
        let entity =
            NSEntityDescription.entity(forEntityName: "AnkleVideos",
                                       in: managedContext)!
        self.deleteData(name: "AnkleVideos")
        for hip in list {
            let newHip = NSManagedObject(entity: entity, insertInto: managedContext)
            newHip.setValue(hip.videoID, forKey: "video_id")
            newHip.setValue(hip.thumbnailImage, forKey: "image_thumbnail")
            newHip.setValue(hip.videoTitle, forKey: "video_title")
            newHip.setValue(hip.videoURLString, forKey: "video_play_url")
            newHip.setValue(hip.videoDuration, forKey: "video_duration")
            newHip.setValue(arrayConvertToJsonString(obj: hip.videoInstruction), forKey: "video_instruction")
            newHip.setValue(arrayConvertToJsonString(obj: hip.videoCompensations), forKey: "video_compensations")
            newHip.setValue(hip.poseImages.toJSONString(), forKey: "pose_image")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Refesh Mobility Video
    private func forceRefeshMobilityVideo() {
        _AppDataHandler.getListMobilityVideoSource { (isSuccess, error) in
            if isSuccess {
                
            }
        }
    }
    
    func getPreviousMobilityTestVideo(video: MobilityTestVideo) -> MobilityTestVideo? {
        returnVideo = video
        
        let arrayVideo = listTrunkVideo + listShouderVideo + listHipVideo + listAnkleVideo
        
        for videoData in arrayVideo {
            if let nextVideo = self.returnVideo {
                if videoData.videoID == nextVideo.videoID {
                    if let index = arrayVideo.firstIndex(of: videoData){
                        if index == 0 {
                            returnVideo = nil
                            break
                        } else {
                            returnVideo = arrayVideo[index - 1]
                            return returnVideo
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func getNextMobilityTestVideo() -> MobilityTestVideo? {
        
        let arrayVideo = listTrunkVideo + listShouderVideo + listHipVideo + listAnkleVideo
        
        for videoData in arrayVideo {
            if let nextVideo = self.returnVideo {
                if videoData.videoID == nextVideo.videoID {
                    if let index = arrayVideo.firstIndex(of: videoData){
                        if index == arrayVideo.count - 1 {
                            returnVideo = nil
                            break
                        } else {
                            returnVideo = arrayVideo[index + 1]
                            return returnVideo
                        }
                    }
                }
                continue
            }
            if videoData.selectedResult == 0 {
                return videoData
            }
        }
        
        return nil
    }
    
    func setMobilityTestVideo(updatedVideo: MobilityTestVideo) {
        
        for videoData in listTrunkVideo {
            if videoData.videoID == updatedVideo.videoID {
                if let index = listTrunkVideo.firstIndex(of: videoData) {
                    listTrunkVideo[index] = updatedVideo
                }
                return
            }
        }
        
        for videoData in listShouderVideo {
            if videoData.videoID == updatedVideo.videoID {
                if let index = listShouderVideo.firstIndex(of: videoData) {
                    listShouderVideo[index] = updatedVideo
                }
                return
            }
        }
        
        for videoData in listHipVideo {
            if videoData.videoID == updatedVideo.videoID {
                if let index = listHipVideo.firstIndex(of: videoData) {
                    listHipVideo[index] = updatedVideo
                }
                return
            }
        }
        
        for videoData in listAnkleVideo {
            if videoData.videoID == updatedVideo.videoID {
                if let index = listAnkleVideo.firstIndex(of: videoData) {
                    listAnkleVideo[index] = updatedVideo
                }
                return
            }
        }
        
        return
    }
    
    //MARK: - Convert String
    private func arrayConvertToJsonString(obj: [Any]) -> String{
        var myJsonString = ""
        do {
            let data =  try JSONSerialization.data(withJSONObject:obj, options: .prettyPrinted)
            myJsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            print(error.localizedDescription)
        }
        return myJsonString
    }
}

extension NSManagedObject {
    func toJSONString() -> String? {
        
        let keys = Array(self.entity.attributesByName.keys)
        let dict = self.dictionaryWithValues(forKeys: keys)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let reqJSONStr = String(data: jsonData, encoding: .utf8)
            return reqJSONStr
        }
        catch{}
        return nil
    }
}
