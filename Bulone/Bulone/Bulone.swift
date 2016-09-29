//
//  Bulone.swift
//  Bulone
//
//  Created by Moody Allen on 06/06/16.
//  Copyright © 2016 Moody Allen. All rights reserved.
//

import Foundation

// MARK: Model
class BuloneModuleModel {
    
    var name: String = ""
    var path: String = ""
    
    var projectName: String  {
        set { persist("projectName", value: newValue) }
        get { return read(forKey: "projectName") }
    }
    
    var author: String  {
        set { persist("author", value: newValue) }
        get { return read(forKey: "author") }
    }
    
    var copyright: String  {
        set { persist("copyright", value: newValue) }
        get { return read(forKey: "copyright") }
    }
}

private extension BuloneModuleModel {
    
    func persist(_ key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func read(forKey key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
}

// MARK: Generator model
struct BuloneGeneratorModel {
    
    enum Part: String {
        case dataManager, item, interactor, presenter, view, wireframe, protocols
        static var array: [Part] {
            return [.dataManager, .item, .interactor, .presenter, .view, .wireframe, .protocols]
        }
    }
    
    let part: Part
    var data: [String: String] = [:]
    var directory: String {
        get { return part.rawValue.capitalized }
    }
}

// MARK: Bulone 🌴
final class Bulone {
    
    static func generate(from model: BuloneModuleModel) throws {
        
        let date = today()
        
        var data =  [
            "project": model.projectName,
            "author": model.author,
            "date": date.date,
            "year": date.year,
            "copyright": model.copyright,
            "module": model.name
        ]
        
        let path = URL(fileURLWithPath: model.path).appendingPathComponent(model.name)
        
        try BuloneGeneratorModel.Part.array
            .map { BuloneGeneratorModel(part: $0, data: [:]) }
            .forEach { item in
                
                let filename = model.name + item.part.rawValue.capitalized
                data["filename"] = filename

                let path = path
                    .appendingPathComponent(item.directory)
                    .absoluteString
                    .replacingOccurrences(of: "file://", with: "")
                
                do {
                    let header = try read(from: "header")
                    var content = try read(from: item.directory.lowercased())
                    content = header + content
                    
                    data.forEach { key, value in
                        content = content.replacingOccurrences(of: "{{ \(key) }}", with: value)
                    }
                    
                    try directory(at: path)
                    try save(text: content, directory: path, filename: filename + ".swift")
                    
                } catch let error {
                    throw error
                }
        }
    }
}

// MARK: Error
enum BuloneError: Error {
    case read(String)
}

// MARK: Utilities
internal extension Bulone {
    
    static func today() -> (date: String, year: String) {
        let date = DateFormatter()
        date.dateStyle = DateFormatter.Style.short
        let year = DateFormatter()
        year.dateFormat = "YYYY"
        return (date.string(from: Date()), year.string(from: Date()))
    }
    
    static func directory(at path: String) throws {
        return try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func save(text: String, directory: String, filename: String) throws {
        return try text.write(toFile: directory + "/" + filename, atomically: true, encoding: String.Encoding.utf8)
    }
    
    static func read(from resource: String) throws -> String {
        guard let file = Bundle.main.path(forResource: resource, ofType: "mustache") else {
            throw BuloneError.read("Read error for resource: \(resource)")
        }
        return try String(contentsOfFile: file, encoding: String.Encoding.utf8)
    }
}
