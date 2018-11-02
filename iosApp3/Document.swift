//
//  Document.swift
//  iosApp3
//
//  Created by User1 RDMA on 2018-11-01.
//  Copyright © 2018 CP. All rights reserved.
//

import Foundation
class Summary{
    var Acknowledged: Bool = false
    var Content: String = ""
}
class Version{
    var summaries: Dictionary = [String: Summary]() // a dictionary of summaries
    var filePath: URL!
    var versionNumber: String = ""
    init(fromVersionNumber: String){
        versionNumber = fromVersionNumber
    }
}
class Document{
    var Name: String = ""
    var versions: Dictionary = [String: Version]() // a dictionary of versions
    var Country: String = ""
    var Language: String = ""
    init(fromName: String){
        Name = fromName
    }
}
