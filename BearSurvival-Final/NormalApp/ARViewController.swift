//
//  ARViewController.swift
//  NormalApp
//
//  Created by Kelly Ma on 12/1/21.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion

// Motion Related
import CoreLocation
import MapKit

var overlay = false

class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {

    // Important Variables
    var sceneView: ARSCNView?
    let manager = CMMotionManager()
    
    var dollNode: SCNNode?
    var dollCount = 1
    var dollTurned = false

    let locationManager = CLLocationManager()
    
    var gameTimer: Timer?
    var timeLeft = 60
    var stateTimer: Timer?
    let timerLabel = UILabel(frame: CGRect(x: 600, y: 1120, width: 300, height: 40))
    
    let northWest = CLLocationCoordinate2DMake(38.6491269, -90.3106974)
    let southWest = CLLocationCoordinate2DMake(38.6485275, -90.3107963)
    let southEast = CLLocationCoordinate2DMake(38.648431, -90.309940)
    let northEast = CLLocationCoordinate2DMake(38.649069, -90.309814)
    
    var previousX: Double?
    var previousY: Double?
 //   let threshold: Double = 5 * pow(10, -5)
    let threshold = 0.000015

    var behindStartLineState = false
    var pastFinishLineState = false
    var withinBoundsState = false
    var isPlayerMovingState = false
    var lightState = 0
    // 0 = green
    // 1 = yellow
    // 2 = red
    
    var timeNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView()
        if sceneView != nil {
            sceneView!.delegate = self
            self.view.addSubview(sceneView!)
            sceneView!.showsStatistics = false
            
            // https://stackoverflow.com/questions/47007614/add-arscnview-programmatically
            NSLayoutConstraint.activate([
                        sceneView!.topAnchor.constraint(equalTo: view.topAnchor),
                        sceneView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        sceneView!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                        sceneView!.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                    ])
                    view.subviews.forEach {
                        $0.translatesAutoresizingMaskIntoConstraints = false
                    }
        }
        
        // Do any additional setup after loading the view.
        
        // Start Game Button
        let startGameButton = UIButton(frame: CGRect(x: 370, y: 40, width: 100, height: 40))
        startGameButton.backgroundColor = .green
        startGameButton.setTitle("Start Game", for: .normal)
        startGameButton.addTarget(self, action: #selector(startGamePressed), for: .touchUpInside)
        self.view.addSubview(startGameButton)
                
// MARK: Location Code Starts Here
        
        // Sets up location functionality
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
      
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        // Adds Mudd Field Map View
        pointMuddField()
        
// MARK: Timer Code
        
        // Label Creation - https://stackoverflow.com/questions/24081731/how-to-create-uilabel-programmatically-using-swift/47726453
        
        timerLabel.text = "60 Seconds Left"
        timerLabel.textColor = UIColor.white
        timerLabel.font = UIFont(name:"Arial", size: 30)
        
        self.view.addSubview(timerLabel)
        
    }
    
    @objc func onTimerFires()
    {
        timeLeft -= 1
        timerLabel.text = "\(timeLeft) seconds left"

        if timeLeft <= 0 {
            gameTimer?.invalidate()
            gameTimer = nil
            stateTimer?.invalidate()
            stateTimer = nil
            print("Timer finished - Push to Lose Game View")
            
            let lostGame = LostViewController()
            navigationController?.pushViewController(lostGame, animated: true)
        }
    }

// MARK: Doll Rotation Code
    // Rotates the doll based on a specific time
    func rotateDoll(node: SCNNode) {
        if (timeNumber == 0) {
            print("rotatedDoll")
        }
        
        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 1)
        node.runAction(rotateOne)
        
    }
    
    //This is a temporary function to open overlay indicating that the user has moved
    func openOverlay(){
        print("button tapped")
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let vc: ViewController = storyboard.instantiateViewController(withIdentifier: "CreateUserVC_Navigation") as! ViewController

        self.present(vc, animated: true, completion: nil)
    }

    // Makes sure we can get user location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Alert", message: "Location Services Failed!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

// MARK: Start Game Pressed
    @objc func startGamePressed(sender: UIButton!) {
        
        //startMotionTracking()
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        
        stateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int.random(in: 2..<5)), target: self, selector: #selector(onStateTimerFires), userInfo: nil, repeats: false)
    }
    
    // Red Light, Green Light Core Function Method
    @objc func onStateTimerFires() {
        
        // Doll
       
        // Red Light -> Green Light
        if (lightState == 2) {
            let interval = Int.random(in: 4..<9)
            stateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(onStateTimerFires), userInfo: nil, repeats: false)
            lightState = 0 //switch to green
            
            // Rotates Doll & Sets dollTurned false
            rotateDoll(node: dollNode!)
            dollTurned = false
            stopTracking()
            print("Was red, going green. \(interval)")
        }
        // Green Light -> Yellow Light
        else if (lightState == 0) {
            //is green, going to yellow
            stateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onStateTimerFires), userInfo: nil, repeats: false)
            lightState = 1 //switch to yellow
            
            // Rotates Doll & Sets dollTurned True
            rotateDoll(node: dollNode!)
            dollTurned = true

            print("Was green, going yellow")
        }
        // Yellow Light -> Red Light
        else if (lightState == 1) {
            //is yellow, going to red
            let interval = Int.random(in: 3..<7)
            stateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(onStateTimerFires), userInfo: nil, repeats: false)
            lightState = 2
            startMotionTracking()
            print("Was yellow, going red. \(interval)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let theLocation = locations[0]
        print("Location is \(theLocation)")
        
        if previousX == nil {
            previousX = theLocation.coordinate.longitude
            previousY = theLocation.coordinate.latitude
        }
        else {
          
            let val = abs(theLocation.coordinate.longitude - previousX!) + abs(theLocation.coordinate.latitude - previousY!)
            if (val >= threshold) {
                //isMovingLabel.text = "Player is moving"
            }
            else {
                //isMovingLabel.text = "Player is not moving"
            }
            previousX = theLocation.coordinate.longitude
            previousY = theLocation.coordinate.latitude
            print(val)
        }
        
        let userY = theLocation.coordinate.latitude
        let userX = theLocation.coordinate.longitude
        let topSlope = (northWest.latitude - northEast.latitude) / (northWest.longitude - northEast.longitude)
        let topIntercept = northWest.latitude - (topSlope * northWest.longitude)
        let topBoundaryY  = calculatePoint(slope: topSlope, intercept: topIntercept, value: userX)
        
        let bottomSlope = (southWest.latitude - southEast.latitude) / (southWest.longitude - southEast.longitude)
        let bottomIntercept = southWest.latitude - (bottomSlope * southWest.longitude)
        let bottomBoundaryY = calculatePoint(slope: bottomSlope, intercept: bottomIntercept, value: userX)
        
        if (userY > topBoundaryY || userY < bottomBoundaryY) {
            withinBoundsState = false
            
//            let lostGame = LostViewController()
//            navigationController?.pushViewController(lostGame, animated: true)
            
            print("Dead, outside playing field")
        }
        else {
            withinBoundsState = true
            print("Inside playing field")
        }
        
        let rightSlope  = (northEast.longitude - southEast.longitude) / (northEast.latitude - southEast.latitude)
        let rightIntercept = northEast.longitude - (rightSlope * northEast.latitude)
        let rightBoundaryX = calculatePoint(slope: rightSlope, intercept: rightIntercept, value: userY)
        
        let leftSlope  = (northWest.longitude - southWest.longitude) / (northWest.latitude - southWest.latitude)
        let leftIntercept = northWest.longitude - (leftSlope * northWest.latitude)
        let leftBoundaryX = calculatePoint(slope: leftSlope, intercept: leftIntercept, value: userY)
        
        if (userX > rightBoundaryX) {
            behindStartLineState = true
            print("Behind start line? \(behindStartLineState)")
        }
        else {
            behindStartLineState = false
            print("Behind start line? \(behindStartLineState)")
        }
        
        if (userX < leftBoundaryX) {
            pastFinishLineState = true
            
            // Pushes Win View Controller
            let wonGame = WonViewController()
            navigationController?.pushViewController(wonGame, animated: true)
            
            print("Past finish line? \(pastFinishLineState)")
        }
        else {
            pastFinishLineState = false
            print("Past finish line? \(pastFinishLineState)")
        }
        
        //inside: 38.648797
        //above: 38.649271
        //below: 38.648367
    }

    func calculatePoint(slope: Double, intercept: Double, value: Double) -> Double {
        let theValue = slope * value + intercept
        return theValue
    }
    
    func pointMuddField() {
        
        let corner1 = PointOfInterest(title: "North West", locationName: "North West", coordinate: CLLocationCoordinate2DMake(38.649209, -90.311398))
        
        let corner2 = PointOfInterest(title: "South West", locationName: "South West", coordinate: CLLocationCoordinate2DMake(38.648576, -90.311505))
        
        let corner3 = PointOfInterest(title: "South East", locationName: "South East", coordinate: CLLocationCoordinate2DMake(38.648484, -90.310693))
        
        let corner4 = PointOfInterest(title: "North East", locationName: "North East", coordinate: CLLocationCoordinate2DMake(38.649152, -90.310344))
        
        // Create and Add Map View - https://swiftdeveloperblog.com/code-examples/create-mkmapview-in-swift-programmatically/
        let mapView = MKMapView()
        
        mapView.frame = CGRect(x: 10, y: 850, width: 400, height: 300)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        mapView.addAnnotation(corner1)
        mapView.addAnnotation(corner2)
        mapView.addAnnotation(corner3)
        mapView.addAnnotation(corner4)
        
        let coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(38.648743, -90.310600), latitudinalMeters: 250, longitudinalMeters: 250)
        mapView.setRegion(coordinateRegion, animated: true)
        
        self.view.addSubview(mapView)
       
    }
    
// MARK: Motion Tracking Code
   func startMotionTracking(){
        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 1
        
        manager.startGyroUpdates()
        manager.gyroUpdateInterval = 1
       
       overlay = false
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){_ in
            if let data = self.manager.accelerometerData{
                let x = round(data.acceleration.x * 100)
                let y = round(data.acceleration.y * 100/98)
                let z = round(data.acceleration.z)
          
                if abs(x)>20 || abs(y)>20 || abs(z)>5{
                    print("moved")
                    // Lost Game
                    
                    if (overlay == false){
                        self.stopTracking()
                        self.gameTimer?.invalidate()
                        self.gameTimer = nil
                        self.stateTimer?.invalidate()
                        self.stateTimer = nil
                        let lostGame = LostViewController()
                        self.navigationController?.pushViewController(lostGame, animated: true)
                        overlay = true
                    }
                }
            }
            
            if let rotateData = self.manager.gyroData{
                let xR = round(rotateData.rotationRate.x * 100)
                let yR = round(rotateData.rotationRate.y * 100)
                let zR = round(rotateData.rotationRate.z * 100)
            
                if abs(zR)>20 || abs(yR)>20 || abs(xR)>20{
                    print("moved")
                    // Lost Game
                    if (overlay == false){
                        self.stopTracking()
                        self.gameTimer?.invalidate()
                        self.gameTimer = nil
                        self.stateTimer?.invalidate()
                        self.stateTimer = nil
                        let lostGame = LostViewController()
                        self.navigationController?.pushViewController(lostGame, animated: true)
                        overlay = true
                    }
                    
                }
                
            }
        }
    }
    
    func stopTracking() {
        manager.stopAccelerometerUpdates()
        manager.stopGyroUpdates()
    }

    // https://medium.com/@maherbhavsar/placing-objects-with-plane-detection-in-arkit-3-10-steps-a6393bf3c83d
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        UIApplication.shared.isIdleTimerDisabled = true
        if sceneView != nil {
            self.sceneView!.autoenablesDefaultLighting = true

            // Run the view's session
            sceneView!.session.run(configuration)
        }

        addGestures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        if sceneView != nil {
            sceneView!.session.pause()

        }
    }
    
    func addGestures() {
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        if sceneView != nil {
            sceneView!.addGestureRecognizer(tapped)

        }
    }

// MARK: Places Doll on Screen from Tap Gesture
    @objc func tapGesture (sender: UITapGestureRecognizer) {
        if sceneView != nil {
            let location = sender.location(in: sceneView!) // 2D point
           
            //https://stackoverflow.com/questions/64258067/hittest-was-depecrated-in-ios-14-0
        
            guard let query = sceneView!.raycastQuery(from: location, allowing: .existingPlaneInfinite, alignment: .any) else {
                return
            }
            let hitTest = sceneView!.session.raycast(query)
            guard hitTest.first != nil else {
                print("No plane detected")
                return
            }
            
            if (dollCount == 1) {
                // Get the url of the .usdz file
                guard let usdzURL = Bundle.main.url(forResource: "SquidGameDoll", withExtension: "usdz")
                else {
                    return
                }
                
                // Load the SCNNode from file
                let referenceNode = SCNReferenceNode(url: usdzURL)
                referenceNode?.load()
                
                // Positions doll far away from the camera
                referenceNode?.position = SCNVector3(0, 0, -20)
                
                // Add node to the scene
                dollNode = referenceNode
                
                sceneView!.scene.rootNode.addChildNode(dollNode!)
                
                //Turns doll to the starting position
                rotateDoll(node: dollNode!)
                
                dollCount -= 1
            }
        }
    }

// MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let meshNode: SCNNode
        let textNode: SCNNode
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        if sceneView != nil {
            guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView!.device!)
            else {
                fatalError("Can't create plane geometry")
            }
            meshGeometry.update(from: planeAnchor.geometry)
            meshNode = SCNNode(geometry: meshGeometry)
            meshNode.opacity = 0.6
            meshNode.name = "MeshNode"
            
            guard let material = meshNode.geometry?.firstMaterial
            else {
                fatalError("ARSCNPlaneGeometry always has one material")
            }
            material.diffuse.contents = UIColor.blue
            
            node.addChildNode(meshNode)
            
            let textGeometry = SCNText(string: "Plane", extrusionDepth: 1)
            textGeometry.font = UIFont(name: "Futura", size: 75)
            
            textNode = SCNNode(geometry: textGeometry)
            textNode.name = "TextNode"
            
            textNode.simdScale = SIMD3(repeating: 0.0005)
            textNode.eulerAngles = SCNVector3(x: Float(-90.degreesToradians), y: 0, z: 0)
            
            node.addChildNode(textNode)
            
            textNode.centerAlign()
            print("did add plane node")
        }
    }
    

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = node.childNode(withName: "MeshNode", recursively: false)
        if let planeGeometry = planeNode?.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = (max - min)
        simdPivot = float4x4(translation: SIMD3(extents/2 + min))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4(1, 0, 0, 0 ),
                  SIMD4(0, 1, 0, 0),
                  SIMD4(0, 0, 1, 0),
                  SIMD4(vector.x, vector.y, vector.z, 1))
    }
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func / (left: SCNVector3, right: Int) -> SCNVector3 {
    return SCNVector3Make(left.x / Float(right), left.y / Float(right), left.z / Float(right))
}

extension Int {
    var degreesToradians: Double {return Double(self) * .pi/180}
}
