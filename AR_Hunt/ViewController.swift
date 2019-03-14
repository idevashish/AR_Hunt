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

class ViewController: UIViewController {
  
  @IBOutlet weak var sceneView: SCNView!
  @IBOutlet weak var leftIndicator: UILabel!
  @IBOutlet weak var rightIndicator: UILabel!
  var cameraSession: AVCaptureSession?
  var cameraLayer: AVCaptureVideoPreviewLayer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadCamera()
    self.cameraSession?.startRunning()
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
}

