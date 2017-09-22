//
//  DataEntryDataSource.swift
//  DataLogger
//
//  Created by Ben Kreeger on 9/21/17.
//  Copyright © 2017 Ben Kreeger. All rights reserved.
//

import Foundation

class DataEntryDataSource {
    enum DataEntryError: Error {
        case fileSystemError
        case entryNotFound
    }
    
    private var entries: [DataEntry] = []
    
    
    // MARK: Public functions and properties
    
    var numberOfEntries: Int {
        return entries.count
    }
    
    func entry(at index: Int) -> DataEntry? {
        guard index < entries.count else { return nil }
        return entries[index]
    }
    
    func fetchEntries(_ completion: @escaping (Error?) -> Void) {
        guard let url = storagePath else {
            completion(DataEntryError.fileSystemError)
            return
        }
        
        let allEntries = entries
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    let data = try Data(contentsOf: url)
                    let parsed = try JSONDecoder().decode([DataEntry].self, from: data)
                    self?.entries = parsed
                } else {
                    print("File doesn't exist at \(url); creating.")
                    let data = try JSONEncoder().encode(allEntries)
                    FileManager.default.createFile(atPath: url.path, contents: data, attributes: [:])
                }
                DispatchQueue.main.async { completion(nil) }
            } catch let error {
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
    
    func commit(_ entry: DataEntry, completion: @escaping (Int, Error?) -> Void) {
        entries.insert(entry, at: 0)
        persist { err in completion(0, err) }
    }
    
    func delete(_ entry: DataEntry, completion: @escaping (Error?) -> Void) {
        if let index = entries.index(of: entry) {
            entries.remove(at: index)
        } else {
            completion(DataEntryError.entryNotFound)
            return
        }
        persist(completion)
    }
    
    
    // MARK: Private functions
    
    private var storagePath: URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("ERROR: could not get document directory in user domain.")
            return nil
        }
        return url.appendingPathComponent("dataEntries.json")
    }
    
    private func persist(_ completion: @escaping (Error?) -> Void) {
        guard let url = storagePath else {
            completion(DataEntryError.fileSystemError)
            return
        }
        
        let allEntries = entries
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try JSONEncoder().encode(allEntries)
                try data.write(to: url)
                print("Data written to URL \(url).")
                DispatchQueue.main.async { completion(nil) }
            } catch let error {
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
}
