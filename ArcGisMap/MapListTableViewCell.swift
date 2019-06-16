//
//  MapListTableViewCell.swift
//  ArcGisMap
//
//  Created by Admin on 1/16/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

protocol MapListCellDelegate {
    func pauseTapped(_ cell: MapListTableViewCell)
    func resumeTapped(_ cell: MapListTableViewCell)
    func cancelTapped(_ cell: MapListTableViewCell)
    func downloadTapped(_ cell: MapListTableViewCell)
    func showMap(_ cell: MapListTableViewCell)
}

class MapListTableViewCell: UITableViewCell {

    var delegate: MapListCellDelegate?
    @IBOutlet var mapTitle: UILabel!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var btn_pause: UIButton!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var btn_download: UIButton!
    @IBOutlet var btn_cancel: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        delegate?.cancelTapped(self)
    }
    @IBAction func onPause(_ sender: Any) {
        if(btn_pause.titleLabel!.text == "Pause") {
            delegate?.pauseTapped(self)
        } else {
            delegate?.resumeTapped(self)
        }
    }
    @IBAction func onDownload(_ sender: Any) {
        if(btn_download.titleLabel!.text == "Download") {
            delegate?.downloadTapped(self)
        } else {
            delegate?.showMap(self)
        }
    }
    func configure(mapModel: MapModel, downloaded: Bool, download: Download?) {
        mapTitle.text = mapModel.name
        
        // Download controls are Pause/Resume, Cancel buttons, progress info
        var showDownloadControls = false
        // Non-nil Download object means a download is in progress
        if let download = download {
            showDownloadControls = true
            let title = download.isDownloading ? "Pause" : "Resume"
            btn_pause.setTitle(title, for: .normal)
            progressLabel.text = download.isDownloading ? "Downloading..." : "Paused"
        }
        
        btn_pause.isHidden = !showDownloadControls
        btn_cancel.isHidden = !showDownloadControls
        progress.isHidden = !showDownloadControls
        progressLabel.isHidden = !showDownloadControls
        
        // If the track is already downloaded, enable cell selection and hide the Download button
        selectionStyle = downloaded ? UITableViewCell.SelectionStyle.gray : UITableViewCell.SelectionStyle.none
        btn_download.isHidden = !btn_pause.isHidden
        if downloaded {
            btn_download.setTitle("View", for: .normal)
        }
    }
    func updateDisplay(progressValue: Float, totalSize : String) {
        progress.progress = progressValue
        progressLabel.text = String(format: "%.1f%% of %@", progressValue * 100, totalSize)
    }
}
