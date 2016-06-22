//
//  Bulone.swift
//  Bulone
//
//  Created by Moody Allen on 06/06/16.
//  Copyright © 2016 Moody Allen. All rights reserved.
//

import Foundation
import Mustache

public enum BuloneModuleType: String {
    case APIDataManager, LocalDataManager, Item, Interactor, Presenter, View, Wireframe, Protocols
    static func array() -> [BuloneModuleType] {
        return [.APIDataManager, .LocalDataManager, .Item, .Interactor, .Presenter, .View, .Wireframe, .Protocols]
    }
}

public struct BuloneModulePart {
    let type: BuloneModuleType
    var data: [String: String] = [:]
    func directory() -> String {
        switch type {
        case .APIDataManager: return "/DataManager/API"
        case .LocalDataManager: return "/DataManager/Local"
        case .Item: return "/Interactor"
        case .Interactor, .Presenter, .View, .Wireframe, .Protocols: return "/" + type.rawValue
        }
    }
}

public class BuloneModuleModel {
    
    var moduleName: String = ""
    var path: String = ""
    
    var projectName: String  {
        set { storeKey("projectName", value: newValue) }
        get { return getStringValue(forKey: "projectName") }
    }
    
    var author: String  {
        set { storeKey("author", value: newValue) }
        get { return getStringValue(forKey: "author") }
    }
    
    var copyright: String  {
        set { storeKey("copyright", value: newValue) }
        get { return getStringValue(forKey: "copyright") }
    }
    
}

private extension BuloneModuleModel {
    
    func storeKey(key: String, value: String) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
    }
    
    func getStringValue(forKey key: String) -> String {
        return NSUserDefaults.standardUserDefaults().stringForKey(key) ?? ""
    }
    
}

public class Bulone {
    
    static func generateModule(model: BuloneModuleModel) throws {
        
        let moduleParts = BuloneModuleType.array()
                .map { BuloneModulePart(type: $0, data: ["module": model.moduleName]) }

        try moduleParts.forEach { part in
            
            let filename = model.moduleName + part.type.rawValue
            let modelPartDirectory = part.directory()
            let date = getTodayFormatedDate()
            
            let data =  [
                "filename": filename,
                "project": model.projectName,
                "author": model.author,
                "date": date.date,
                "year": date.year,
                "copyright": model.copyright,
                "module": model.moduleName
            ]
            
            do {

                let fullPath = model.path + "/" + model.moduleName + modelPartDirectory

                let header = try Template(named: "header")
                let headerRender = try header.render(Box(data))
                let template = try Template(named: part.type.rawValue.lowercaseString)
                let rendering = try template.render(Box(data))
                let text = headerRender + "\n\r" + rendering
                
                try NSFileManager
                    .defaultManager()
                    .createDirectoryAtPath(
                        fullPath,
                        withIntermediateDirectories: true,
                        attributes: nil
                )
                
                try text.writeToFile(
                    fullPath + "/" + filename + ".swift",
                    atomically: true,
                    encoding: NSUTF8StringEncoding
                )
                
            } catch let error {
                throw error
            }
        }
    }
    
}

private extension Bulone {
    
    static func getTodayFormatedDate() -> (date: String, year: String) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        let yearFormater = NSDateFormatter()
        yearFormater.dateFormat = "YYYY"
        
        return (dateFormatter.stringFromDate(NSDate()), yearFormater.stringFromDate(NSDate()))
    }
    
}