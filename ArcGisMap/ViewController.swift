//
//  ViewController.swift
//  ArcGisMap
//
//  Created by Admin on 1/14/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import ArcGIS
class ViewController: UIViewController {
    @IBOutlet var mapView: AGSMapView!
    @IBOutlet var lable_mapname: UILabel!
    @IBOutlet var btn_compass: UIButton!
    
    @IBOutlet var northArrow: UIImageView!
    @IBAction func onShowMapList(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private var mobileMapPackage : AGSMobileMapPackage!
    
    var mapURL: URL!
    var mapName: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.mobileMapPackage = AGSMobileMapPackage(fileURL: mapURL)
        self.lable_mapname.text = mapName
        
        self.mobileMapPackage.load { [weak self] (error: Error?) in
            guard error == nil else {
                print("Error loading mobile map package")
                return
            }
            // Get the first map in the mobile map package and display it in an AGSMapView
            let map = self?.mobileMapPackage.maps.first
            self?.mapView.map = map
            self?.mapView.locationDisplay.start { (error:Error?) -> Void in
                 if let error = error {
                    print(error.localizedDescription)
                 }
            }
            //self?.northArrow.mapView
        }
        self.mapView.viewpointChangedHandler = { [weak self] () in
            DispatchQueue.main.async {
                self?.mapViewpointDidChange()
            }
        }
         self.northArrow.isHidden = true
      //  self.mapView.map = AGSMap(basemapType: .navigationVector, latitude: 34.09, longitude: -118.71, levelOfDetail: 10)
    }
  
    func mapViewpointDidChange() {
        self.btn_compass.transform = CGAffineTransform(rotationAngle: CGFloat(-mapView.rotation * Double.pi / 180))
        self.northArrow.transform = CGAffineTransform(rotationAngle: CGFloat(-mapView.rotation * Double.pi / 180))
        if mapView.rotation == 0 {
            self.northArrow.isHidden = true
        }
        else {
            self.northArrow.isHidden = false
        }
    }
    
    @IBAction func compassAction(_ sender: Any) {
        self.btn_compass.transform = CGAffineTransform.identity
        self.mapView.setViewpointRotation(0, completion: nil)
    }
    
    @IBAction func setOffMode(_ sender: Any) {
        self.mapView.locationDisplay.stop()
    }
    @IBAction func setCompassMode(_ sender: Any) {
        self.mapView.locationDisplay.autoPanMode = .compassNavigation
        self.mapView.locationDisplay.start {(error:Error?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    @IBAction func setNavigationMode(_ sender: Any) {
        self.mapView.locationDisplay.autoPanMode = .navigation
        self.mapView.locationDisplay.start {(error:Error?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    @IBAction func setCenterMode(_ sender: Any) {
        self.mapView.locationDisplay.autoPanMode = .recenter
        self.mapView.locationDisplay.start {(error:Error?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    @IBAction func setNormalMode(_ sender: Any) {
        self.mapView.locationDisplay.start {(error:Error?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

