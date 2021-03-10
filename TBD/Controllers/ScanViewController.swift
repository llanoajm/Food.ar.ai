//
//  ViewController.swift
//  new
//
//  Created by Antonio Llano on 3/1/21.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ScanViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let sphere = SCNSphere(radius: 0.2)
    let node = SCNNode()
    let prediction_label = UILabel()
    var scansArray = [String]()
    var imageID = ""
    var user = "admin"
    let defaults = UserDefaults.standard
    var doneScanning = false
    // var stopScanning = false
    
    
    
    var sceneController = MainScene()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        
        
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        
        // Create a new scene
        if let scene = sceneController.scene {
          // Set the scene to the view
          sceneView.scene = scene
            
            
            
            
            
            let tapRecogni = UITapGestureRecognizer(target: self, action: #selector(ScanViewController.didTapScreen))
            tapRecogni.numberOfTapsRequired = 1
            tapRecogni.numberOfTouchesRequired = 1
            self.view.addGestureRecognizer(tapRecogni)
        }
        // Set the scene to the view

    }
    
    
    
    
    func doStuff(){
        node.position = SCNVector3(0, 0.1, -0.5)
        node.geometry = sphere
        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
    }
    
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        if let camera = sceneView.session.currentFrame?.camera {
            print("Tap detected")
            var translation = matrix_identity_float4x4
            doStuff()
            translation.columns.3.z = -5.0
            let transform = camera.transform * translation
            let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            sceneController.addSphere(parent: sceneView.scene.rootNode, position: position)
        }
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //stopScanning = false
         
        //stopScanning = false
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.delegate = self
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        setupCoreML()

        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.loopCoreMLUpdate), userInfo: nil, repeats: true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        sceneView.session.pause()
        
    }
    
    
    //mlmodel
    


    let currentMLModel = TBD_Final().model
    private let serialQueue = DispatchQueue(label: "com.ajapps.dispatchqueueml")
    private var visionRequests = [VNRequest]()
    private var timer = Timer()
    
    private func setupCoreML() {
        guard let selectedModel = try? VNCoreMLModel(for: currentMLModel) else {
            fatalError("Could not load model.")
        }
        
        let classificationRequest = VNCoreMLRequest(model: selectedModel,
                                                    completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
        visionRequests = [classificationRequest]
    }
    
    
    @objc private func loopCoreMLUpdate() {
        serialQueue.async {
            self.updateCoreML()
        }
    }


}

extension ScanViewController {
    private func updateCoreML() {
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        
        let deviceOrientation = UIDevice.current.orientation.getImagePropertyOrientation()
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixbuff!, orientation: deviceOrientation,options: [:])
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
        
    }
}


extension ScanViewController {
    
    private func classificationCompleteHandler(request: VNRequest, error: Error?) {
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            return
        }
        
        //change
        let classifications = observations[0...1]
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        //print("Classifications: \(classifications)")
        
        
        
        
        
        
        DispatchQueue.main.async {
            
            let prediction_label = self.view.viewWithTag(101) as? UILabel
            prediction_label!.text = classifications
            
            let topPrediction = classifications.components(separatedBy: "\n")[0]
            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            guard let topPredictionScore: Float = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces)) else { return }
            
            
            //prone to errors
            
            if (topPredictionScore > 0.95) && (topPredictionName != "no_product_detected"){ //&& self.stopScanning == false
                
                    
                    print("Top prediction: \(topPredictionName) - score: \(String(describing: topPredictionScore))")
                    self.prediction_label.text = "Top prediction: \(topPredictionName) - score: \(String(describing: topPredictionScore))"
                    
                    self.update3DText(topPredictionName)
                    
                   
                    
                    
                       // photoArray.append(image)//deprecated*
                        //edits here
                        
                    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let url = documents.appendingPathComponent("image-rand.png")
                   
                     
                    
                     let scannedProduct = self.view.takeScreenshot()
                     // Convert to Data
                     if let data = scannedProduct.pngData() {
                         do {
                            print("photo is valid")
                             try data.write(to: url)
                             
                             print(url)
                            
                            //Deprecated
                            self.scansArray.append(url.path)
                            
                            
                            
                            
                             
                            
                            //Deprecated
                            self.defaults.set(self.scansArray, forKey: "recentScans")
                            
                            print("added to defaults")
                             
                            
                             
                         } catch let error as NSError{
                            NSLog("%@", error.description)
                             print("Unable to Write Image Data to Disk")
                            
                         }
                     }
                
//                checkMarks()
                        
                    
                        
                    
                   
                    
                }
            
        }
    }
    func update3DText(_ string: String){
        
        if string != "null_product"{
            let textGeometry = SCNText(string: string, extrusionDepth: 1.0)
            textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
            let textNode = SCNNode(geometry: textGeometry)
            
            textNode.position = SCNVector3(x: 0, y: 0.01, z: -0.1)
            
            textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
            
            sceneView.scene.rootNode.addChildNode(textNode)
        }
        
        
    }
    
//    func checkMarks(){
//        var screenCenter: CGPoint?
//        var trackingFallbackTimer: Timer?
//
//        let session = ARSession()
//
//        let standardConfiguration: ARWorldTrackingConfiguration = {
//            let configuration = ARWorldTrackingConfiguration()
//            configuration.planeDetection = .horizontal
//            return configuration
//        }()
//        var dragOnInfinitePlanesEnabled = false
//        var virtualObjectManager: VirtualObjectManager!
//
//        // MARK: - Other Properties
//
//        var textManager: TextManager!
//        var restartExperienceButtonIsEnabled = true
//    }
    
}

