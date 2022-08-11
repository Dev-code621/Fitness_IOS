//
//  ConsoleLog.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/18/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import Foundation

class ConsoleLog: TextOutputStream {

    func write(_ string: String) {
        if (kIsProductionReleaseMode == false) {
            let fm = FileManager.default
            let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("console_log.txt")
            if let handle = try? FileHandle(forWritingTo: log) {
                handle.seekToEndOfFile()
                handle.write(string.data(using: .utf8)!)
                handle.closeFile()
            } else {
                try? string.data(using: .utf8)?.write(to: log)
            }
        } else {
            let fm = FileManager.default
            let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("console_log.txt")
            do {
                try fm.removeItem(at: log)
            }
            catch {
                print(error)
            }
        }
    }
    
    func clear() {
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("console_log.txt")
        
        do {
            try fm.removeItem(at: log)
        } catch {
            print(error)
        }
        
        self.write("")
    }
    
    static var consoleLog: ConsoleLog = ConsoleLog()
    private init() {} // we are sure, nobody else could create it
}
