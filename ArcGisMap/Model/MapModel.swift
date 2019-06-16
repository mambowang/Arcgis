//
//  MapModel.swift
//  ArcGisMap
//
//  Created by Admin on 1/17/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation.NSURL

// Query service creates Track objects
class MapModel {
    
    let name: String
    let previewURL: URL
    let index: Int
    var downloaded = false
    
    init(name: String, previewURL: URL, index: Int) {
        self.name = name
        self.previewURL = previewURL
        self.index = index
    }
    
}
