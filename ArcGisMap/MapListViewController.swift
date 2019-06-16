//
//  MapListViewController.swift
//  ArcGisMap
//
//  Created by Admin on 1/16/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit


class MapListViewController: UIViewController{

    @IBOutlet var MapTableView: UITableView!
    var searchResults: [MapModel] = []
    var map_datas: [[String]] = [
                                    ["Northern Territory","https://www.blueapps.com.au/downloads/maps/Australia_Northern_Territory.mmpk"],
                                    ["Queensland","https://www.blueapps.com.au/downloads/maps/Australia_Queensland.mmpk"]
                                ]
    var selectedIndex: Int!
    var selectedURL: URL!
    var fileMgr: FileManager = FileManager.default
    let downloadService = DownloadService()
    lazy var downloadsSession: URLSession = {
        //    let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MapTableView.delegate = self
        self.MapTableView.dataSource = self
        downloadService.downloadsSession = downloadsSession
        for mapData in self.map_datas {
            searchResults.append(MapModel(name: mapData[0], previewURL:URL(string: mapData[1])!, index: searchResults.count))
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mapView = segue.destination as! ViewController
        mapView.mapURL = localFilePath(for: self.selectedURL)
        mapView.mapName = map_datas[selectedIndex][0]
    }
}
extension MapListViewController: URLSessionDownloadDelegate {
    
    // Stores downloaded file
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.mapModel.downloaded = true
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        if let index = download?.mapModel.index {
            DispatchQueue.main.async {
                self.MapTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    
    // Updates progress info
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        // 1
        guard let url = downloadTask.originalRequest?.url,
            let download = downloadService.activeDownloads[url]  else { return }
        // 2
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        // 3
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
                                                  countStyle: .file)
        // 4
        DispatchQueue.main.async {
            if let trackCell = self.MapTableView.cellForRow(at: IndexPath(row: download.mapModel.index,
                                                                       section: 0)) as? MapListTableViewCell {
                trackCell.updateDisplay(progressValue: download.progress, totalSize: totalSize)
            }
        }
    }
    
}

// MARK: - URLSessionDelegate

extension MapListViewController: URLSessionDelegate {
    
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
}

extension MapListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapListCell", for: indexPath) as! MapListTableViewCell
        cell.delegate = self
        let track = searchResults[indexPath.row]
        let existFlag = self.fileMgr.fileExists(atPath: localFilePath(for: track.previewURL).path)
        track.downloaded = existFlag
        cell.configure(mapModel: track, downloaded: existFlag, download: downloadService.activeDownloads[track.previewURL])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    
    // When user taps cell, play the local file, if it's downloaded
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = searchResults[indexPath.row]
        if track.downloaded {
            self.selectedURL = track.previewURL
            self.selectedIndex = indexPath.row
            self.performSegue(withIdentifier: "segShowMap", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension MapListViewController: MapListCellDelegate {
    
    func downloadTapped(_ cell: MapListTableViewCell) {
        if let indexPath = MapTableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.startDownload(track)
            reload(indexPath.row)
        }
    }
    
    func pauseTapped(_ cell: MapListTableViewCell) {
        if let indexPath = MapTableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.pauseDownload(track)
            reload(indexPath.row)
        }
    }
    
    func resumeTapped(_ cell: MapListTableViewCell) {
        if let indexPath = MapTableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.resumeDownload(track)
            reload(indexPath.row)
        }
    }
    
    func cancelTapped(_ cell: MapListTableViewCell) {
        if let indexPath = MapTableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.cancelDownload(track)
            reload(indexPath.row)
        }
    }
    
    func showMap(_ cell: MapListTableViewCell) {
        if let indexPath = MapTableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            self.selectedURL = track.previewURL
            self.selectedIndex = indexPath.row
            self.performSegue(withIdentifier: "segShowMap", sender: self)
        }
    }
    
    // Update track cell's buttons
    func reload(_ row: Int) {
        MapTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    
}
extension UITableView {
    func cellForRow<T: UITableViewCell>(at indexPath: IndexPath) -> T {
        guard let cell = cellForRow(at: indexPath) as? T else {
            fatalError("Could not get cell as type \(T.self)")
        }
        return cell
    }
}
