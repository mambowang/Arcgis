//
//  Download.swift
//  ArcGisMap
//
//  Created by Admin on 1/17/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

class Download {
    
    var mapModel: MapModel
    init(mapModel: MapModel) {
        self.mapModel = mapModel
    }
    
    // Download service sets these values:
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    
    // Download delegate sets this value:
    var progress: Float = 0
    
}
