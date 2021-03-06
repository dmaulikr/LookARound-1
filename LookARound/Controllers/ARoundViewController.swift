//
//  ARoundViewController.swift
//  LookARound
//
//  Created by John Nguyen on 10/12/17.
//  Copyright © 2017 LookARound. All rights reserved.
//

import UIKit
import SceneKit
import MapKit
import ARKit
import ARCL
import CoreLocation

@available(iOS 11.0, *)
class ARoundViewController: UIViewController, SceneLocationViewDelegate {
    @IBOutlet weak var friendsButton: UIButton!
    let sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addARScene()
        
        friendsButton.setTitleColor(UIColor.LABrand.primary, for: .normal)
        friendsButton.layer.cornerRadius = friendsButton.frame.size.height * 0.5
        friendsButton.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneLocationView.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addARScene() {
        view.insertSubview(sceneLocationView, at: 0)
        
        sceneLocationView.translatesAutoresizingMaskIntoConstraints = false
        sceneLocationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        sceneLocationView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        sceneLocationView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        sceneLocationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        sceneLocationView.locationDelegate = self
        
        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        //sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        //sceneLocationView.locationEstimateMethod = .mostRelevantEstimate
        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
    }
    
    func addPlaces( places: [Place] )
    {
        for index in 0..<places.count {
            let place = places[index]
            
            let name = place.name
            let pinName = "pin_home"
            
            //let pinCoordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            let pinCoordinate = place.location
            
            let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 236)
            
            let origImage = UIImage(named: pinName)!
            let pinImage =  origImage.addText(name as! NSString, atPoint: CGPoint(x: 15, y: 0), textColor:nil, textFont:UIFont.systemFont(ofSize: 26))
            
            var pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
            
            pinLocationNode.scaleRelativeToDistance = false
            
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
        }
    }
    
    @IBAction func onFriendsButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.completionHandler = { places in
            print( "* places.count=\(places.count)")
            self.addPlaces( places: places )
        }
        present(loginViewController, animated: true, completion: nil)
    }
    
    // MARK: - SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        // DDLogDebug("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        // DDLogDebug("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Extensions

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}

extension UIImage {
    
    func addText(_ drawText: NSString, atPoint: CGPoint, textColor: UIColor?, textFont: UIFont?) -> UIImage {
        
        // Setup the font specific variables
        var _textColor: UIColor
        if textColor == nil {
            _textColor = UIColor.yellow
        } else {
            _textColor = textColor!
        }
        
        var _textFont: UIFont
        if textFont == nil {
            _textFont = UIFont.systemFont(ofSize: 20)
            //_textFont = UIFont(name: "Helvetica-Bold", size: 15.0)
        } else {
            _textFont = textFont!
        }
        
        // Setup the image context using the passed image
        UIGraphicsBeginImageContext(size)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        
        let attributes = [
            NSAttributedStringKey.font:  _textFont,
            NSAttributedStringKey.foregroundColor: _textColor,
            NSAttributedStringKey.strokeWidth: -1,
            NSAttributedStringKey.strokeColor: UIColor.black] as [NSAttributedStringKey : Any]
        
        // Put the image into a rectangle as large as the original image
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: size.width, height: size.height)
        
        // Draw the text into an image
        //drawText.draw(in: rect, withAttributes: textFontAttributes)
        drawText.draw(in: rect, withAttributes: attributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
        
    }
}

