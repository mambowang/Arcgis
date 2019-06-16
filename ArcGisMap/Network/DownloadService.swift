//
//  DownloadService.swift
//  ArcGisMap
//
//  Created by Admin on 1/17/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import Foundation

class DownloadService {
    
    // SearchViewController creates downloadsSession
    var downloadsSession: URLSession!
    var activeDownloads: [URL: Download] = [:]
    
    // MARK: - Download methods called by TrackCell delegate methods
    
    func startDownload(_ mapModel: MapModel) {
        // 1
        let download = Download(mapModel: mapModel)
        // 2
        download.task = downloadsSession.downloadTask(with: mapModel.previewURL)
        // 3
        download.task!.resume()
        // 4
        download.isDownloading = true
        // 5
        activeDownloads[download.mapModel.previewURL] = download
    }
    
    func pauseDownload(_ mapModel: MapModel) {
        guard let download = activeDownloads[mapModel.previewURL] else { return }
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { data in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }
    
    func cancelDownload(_ mapModel: MapModel) {
        if let download = activeDownloads[mapModel.previewURL] {
            download.task?.cancel()
            activeDownloads[mapModel.previewURL] = nil
        }
    }
    
    func resumeDownload(_ mapModel: MapModel) {
        guard let download = activeDownloads[mapModel.previewURL] else { return }
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.mapModel.previewURL)
        }
        download.task!.resume()
        download.isDownloading = true
    }
    
}
