/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SceneKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController {
  
  @IBOutlet weak var sceneView: SCNView!
  @IBOutlet weak var leftIndicator: UILabel!
  @IBOutlet weak var rightIndicator: UILabel!
  var cameraSession: AVCaptureSession?
  var cameraLayer: AVCaptureVideoPreviewLayer?
  var target: ARItem!
  var locationManager = CLLocationManager()
  var heading: Double = 0
  var userLocation = CLLocation()
  let scene = SCNScene()
  let cameraNode = SCNNode()
  let targetNode = SCNNode(geometry: SCNCapsule(capRadius: 1, height: 2))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadCamera()
    self.cameraSession?.startRunning()
    self.locationManager.delegate = self
    self.locationManager.startUpdatingHeading()
    sceneView.scene = scene
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(0, 0, 10)
    scene.rootNode.addChildNode(cameraNode)
    scene.rootNode.addChildNode(cameraNode)
    setupTarget()

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func createCaptureSession() -> (session: AVCaptureSession?, error: NSError?) {
    var error: NSError?
    var captureSession: AVCaptureSession?
    let backVideoDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
    
    if backVideoDevice != nil {
      var videoInput: AVCaptureDeviceInput!
      do {
        videoInput = try AVCaptureDeviceInput(device: backVideoDevice)
      } catch let err as NSError {
        error = err
        videoInput = nil
      }
      
      if error == nil {
        captureSession = AVCaptureSession()
        if captureSession!.canAddInput(videoInput) {
          captureSession!.addInput(videoInput)
        } else {
          error = NSError(domain: "", code: 0, userInfo: ["description": "Error adding video input."])
        }
      } else {
        error = NSError(domain: "", code: 1, userInfo: ["description": "Error creating capture device input."])
      }
    } else {
      error = NSError(domain: "", code: 2, userInfo: ["description": "Back video device not found."])
    }
    return (session: captureSession, error: error)
  }
  
  func loadCamera() {
    let captureSessionResult = createCaptureSession()
    guard captureSessionResult.error == nil, let session = captureSessionResult.session else {
      print("Error creating capture session.")
      return
    }
    self.cameraSession = session
    
    if let cameraLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession) {
      cameraLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
      cameraLayer.frame = self.view.bounds
      
      self.view.layer.insertSublayer(cameraLayer, at: 0)
      self.cameraLayer = cameraLayer
    }
  }
  
  func repositionTarget() {
    let heading = getHeadingForDirectionFromCoordinate(from: userLocation, to: target.location)
    let delta = heading - self.heading
    
    if delta < -15.0 {
      leftIndicator.isHidden = false
      rightIndicator.isHidden = true
    } else if delta > 15 {
      leftIndicator.isHidden = true
      rightIndicator.isHidden = false
    } else {
      leftIndicator.isHidden = true
      rightIndicator.isHidden = true
    }

    let distance = userLocation.distance(from: target.location)
    if let node = target.itemNode {
      if node.parent == nil {
        node.position = SCNVector3(x: Float(delta), y: 0, z: Float(-distance))
        scene.rootNode.addChildNode(node)
      } else {
        node.removeAllActions()
        node.runAction(SCNAction.move(to: SCNVector3(x: Float(delta), y: 0, z: Float(-distance)), duration: 0.2))
      }
    }
  }
  
  func radiansToDegrees(_ radians: Double) -> Double {
    return (radians) * (180.0 / .pi)
  }
  
  func degreesToRadians(_ degrees: Double) -> Double {
    return (degrees) * (.pi / 180.0)
  }
  
  func getHeadingForDirectionFromCoordinate(from: CLLocation, to: CLLocation) -> Double {
    let fLat = degreesToRadians(from.coordinate.latitude)
    let fLng = degreesToRadians(from.coordinate.longitude)
    let tLat = degreesToRadians(to.coordinate.latitude)
    let tLng = degreesToRadians(to.coordinate.longitude)
    
    let degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)))
    
    if degree >= 0 {
      return degree
    } else {
      return degree + 360
    }
  }
  
  func setupTarget() {
    targetNode.name = "enemy"
    self.target.itemNode = targetNode
  }
}

extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    self.heading = fmod(newHeading.trueHeading, 360.0)
    repositionTarget()
  }
}

