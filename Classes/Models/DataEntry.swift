//
//  DataEntry.swift
//  DataLogger
//
//  Created by Ben Kreeger on 9/21/17.
//  Copyright © 2017 Ben Kreeger. All rights reserved.
//

import Foundation

struct DataEntry: Codable, Equatable {
    var content: String = ""
    var created: Date = Date(timeIntervalSinceReferenceDate: 0)
    
    public static func ==(lhs: DataEntry, rhs: DataEntry) -> Bool {
        return lhs.content == rhs.content && lhs.created == rhs.created
    }
}
