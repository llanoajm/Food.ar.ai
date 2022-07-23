//
//  extensions.swift
//  TBD
//
//  Created by Antonio Llano on 16/02/21.
//

import Foundation
import UIKit
import SceneKit
import ARKit


extension String{
    func emailToUsername(_ email: String) -> String{
        var username = ""
        for char in email{
            if char != "@"{
                username.append(char)
            }
            else{
                break
            }
        }
       return username
    }
}
extension UIDeviceOrientation {
    func getImagePropertyOrientation() -> CGImagePropertyOrientation {
        switch self {
        case UIDeviceOrientation.portrait, .faceUp: return CGImagePropertyOrientation.right
        case UIDeviceOrientation.portraitUpsideDown, .faceDown: return CGImagePropertyOrientation.left
        case UIDeviceOrientation.landscapeLeft: return CGImagePropertyOrientation.up
        case UIDeviceOrientation.landscapeRight: return CGImagePropertyOrientation.down
        case UIDeviceOrientation.unknown: return CGImagePropertyOrientation.right
        }
    }
}

extension UIView {

    func takeScreenshot() -> UIImage {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}



extension RateViewController {
    
    enum SegueIdentifier: String {
        case showSettings
    }
    
    // MARK: - Interface Actions
    

    
    
}





extension FocusSquare {
    
    /*
     The focus square consists of eight segments as follows, which can be individually animated.
     
     s1  s2
     _   _
     s3 |     | s4
     
     s5 |     | s6
     -   -
     s7  s8
     */
    enum Corner {
        case topLeft // s1, s3
        case topRight // s2, s4
        case bottomRight // s6, s8
        case bottomLeft // s5, s7
    }
    enum Alignment {
        case horizontal // s1, s2, s7, s8
        case vertical // s3, s4, s5, s6
    }
    enum Direction {
        case up, down, left, right
        
        var reversed: Direction {
            switch self {
            case .up:   return .down
            case .down: return .up
            case .left:  return .right
            case .right: return .left
            }
        }
    }
    
    class Segment: SCNNode {
        
        // MARK: - Configuration & Initialization
        
        /// Thickness of the focus square lines in m.
        static let thickness: Float = 0.018
        
        /// Length of the focus square lines in m.
        static let length: Float = 0.5  // segment length
        
        /// Side length of the focus square segments when it is open (w.r.t. to a 1x1 square).
        static let openLength: Float = 0.2
        
        let corner: Corner
        let alignment: Alignment
        
        init(name: String, corner: Corner, alignment: Alignment) {
            self.corner = corner
            self.alignment = alignment
            super.init()
            self.name = name
            
            switch alignment {
            case .vertical:
                geometry = SCNPlane(width: CGFloat(FocusSquare.Segment.thickness),
                                    height: CGFloat(FocusSquare.Segment.length))
            case .horizontal:
                geometry = SCNPlane(width: CGFloat(FocusSquare.Segment.length),
                                    height: CGFloat(FocusSquare.Segment.thickness))
            }
            
            let material = geometry!.firstMaterial!
            material.diffuse.contents = FocusSquare.primaryColor
            material.isDoubleSided = true
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = FocusSquare.primaryColor
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Animating Open/Closed
        
        var openDirection: Direction {
            switch (corner, alignment) {
            case (.topLeft,     .horizontal):   return .left
            case (.topLeft,     .vertical):     return .up
            case (.topRight,    .horizontal):   return .right
            case (.topRight,    .vertical):     return .up
            case (.bottomLeft,  .horizontal):   return .left
            case (.bottomLeft,  .vertical):     return .down
            case (.bottomRight, .horizontal):   return .right
            case (.bottomRight, .vertical):     return .down
            }
        }
        
        func open() {
            guard let plane = self.geometry as? SCNPlane else { return }
            let direction = openDirection
            
            if alignment == .horizontal {
                plane.width = CGFloat(FocusSquare.Segment.openLength)
            } else {
                plane.height = CGFloat(FocusSquare.Segment.openLength)
            }
            
            let offset = FocusSquare.Segment.length / 2 - FocusSquare.Segment.openLength / 2
            switch direction {
            case .left:     self.position.x -= offset
            case .right:    self.position.x += offset
            case .up:       self.position.y -= offset
            case .down:     self.position.y += offset
            }
        }
        
        func close() {
            guard let plane = self.geometry as? SCNPlane else { return }
            let direction = openDirection.reversed
            
            let oldLength: Float
            if alignment == .horizontal {
                oldLength = Float(plane.width)
                plane.width = CGFloat(FocusSquare.Segment.length)
            } else {
                oldLength = Float(plane.height)
                plane.height = CGFloat(FocusSquare.Segment.length)
            }
            
            let offset = FocusSquare.Segment.length / 2 - oldLength / 2
            switch direction {
            case .left:     self.position.x -= offset
            case .right:    self.position.x += offset
            case .up:       self.position.y -= offset
            case .down:     self.position.y += offset
            }
        }
        
    }
}

extension ARSCNView {
    
    // MARK: - Types
    
    struct HitTestRay {
        let origin: float3
        let direction: float3
    }
    
    struct FeatureHitTestResult {
        let position: float3
        let distanceToRayOrigin: Float
        let featureHit: float3
        let featureDistanceToHitResult: Float
    }
    
    func unprojectPoint(_ point: float3) -> float3 {
        return float3(self.unprojectPoint(SCNVector3(point)))
    }
    
    // MARK: - Hit Tests
    
    func hitTestRayFromScreenPos(_ point: CGPoint) -> HitTestRay? {
        
        guard let frame = self.session.currentFrame else {
            return nil
        }
        
        let cameraPos = frame.camera.transform.translation
        
        // Note: z: 1.0 will unproject() the screen position to the far clipping plane.
        let positionVec = float3(x: Float(point.x), y: Float(point.y), z: 1.0)
        let screenPosOnFarClippingPlane = self.unprojectPoint(positionVec)
        
        let rayDirection = simd_normalize(screenPosOnFarClippingPlane - cameraPos)
        return HitTestRay(origin: cameraPos, direction: rayDirection)
    }
    
    func hitTestWithInfiniteHorizontalPlane(_ point: CGPoint, _ pointOnPlane: float3) -> float3? {
        
        guard let ray = hitTestRayFromScreenPos(point) else {
            return nil
        }
        
        // Do not intersect with planes above the camera or if the ray is almost parallel to the plane.
        if ray.direction.y > -0.03 {
            return nil
        }
        
        // Return the intersection of a ray from the camera through the screen position with a horizontal plane
        // at height (Y axis).
        return rayIntersectionWithHorizontalPlane(rayOrigin: ray.origin, direction: ray.direction, planeY: pointOnPlane.y)
    }
    
    func hitTestWithFeatures(_ point: CGPoint, coneOpeningAngleInDegrees: Float,
                             minDistance: Float = 0,
                             maxDistance: Float = Float.greatestFiniteMagnitude,
                             maxResults: Int = 1) -> [FeatureHitTestResult] {
        
        var results = [FeatureHitTestResult]()
        
        guard let features = self.session.currentFrame?.rawFeaturePoints else {
            return results
        }
        
        guard let ray = hitTestRayFromScreenPos(point) else {
            return results
        }
        
        let maxAngleInDeg = min(coneOpeningAngleInDegrees, 360) / 2
        let maxAngle = (maxAngleInDeg / 180) * .pi
        
        let points = features.__points
        
        for i in 0...features.__count {
            
            let feature = points.advanced(by: Int(i))
            let featurePos = feature.pointee
            
            let originToFeature = featurePos - ray.origin
            
            let crossProduct = simd_cross(originToFeature, ray.direction)
            let featureDistanceFromResult = simd_length(crossProduct)
            
            let hitTestResult = ray.origin + (ray.direction * simd_dot(ray.direction, originToFeature))
            let hitTestResultDistance = simd_length(hitTestResult - ray.origin)
            
            if hitTestResultDistance < minDistance || hitTestResultDistance > maxDistance {
                // Skip this feature - it is too close or too far away.
                continue
            }
            
            let originToFeatureNormalized = simd_normalize(originToFeature)
            let angleBetweenRayAndFeature = acos(simd_dot(ray.direction, originToFeatureNormalized))
            
            if angleBetweenRayAndFeature > maxAngle {
                // Skip this feature - is is outside of the hit test cone.
                continue
            }
            
            // All tests passed: Add the hit against this feature to the results.
            results.append(FeatureHitTestResult(position: hitTestResult,
                                                distanceToRayOrigin: hitTestResultDistance,
                                                featureHit: featurePos,
                                                featureDistanceToHitResult: featureDistanceFromResult))
        }
        
        // Sort the results by feature distance to the ray.
        results = results.sorted(by: { (first, second) -> Bool in
            return first.distanceToRayOrigin < second.distanceToRayOrigin
        })
        
        // Cap the list to maxResults.
        var cappedResults = [FeatureHitTestResult]()
        var i = 0
        while i < maxResults && i < results.count {
            cappedResults.append(results[i])
            i += 1
        }
        
        return cappedResults
    }
    
    func hitTestWithFeatures(_ point: CGPoint) -> [FeatureHitTestResult] {
        
        var results = [FeatureHitTestResult]()
        
        guard let ray = hitTestRayFromScreenPos(point) else {
            return results
        }
        
        if let result = self.hitTestFromOrigin(origin: ray.origin, direction: ray.direction) {
            results.append(result)
        }
        
        return results
    }
    
    func hitTestFromOrigin(origin: float3, direction: float3) -> FeatureHitTestResult? {
        
        guard let features = self.session.currentFrame?.rawFeaturePoints else {
            return nil
        }
        
        let points = features.__points
        
        // Determine the point from the whole point cloud which is closest to the hit test ray.
        var closestFeaturePoint = origin
        var minDistance = Float.greatestFiniteMagnitude
        
        for i in 0...features.__count {
            let feature = points.advanced(by: Int(i))
            let featurePos = feature.pointee
            
            let originVector = origin - featurePos
            let crossProduct = simd_cross(originVector, direction)
            let featureDistanceFromResult = simd_length(crossProduct)
            
            if featureDistanceFromResult < minDistance {
                closestFeaturePoint = featurePos
                minDistance = featureDistanceFromResult
            }
        }
        
        // Compute the point along the ray that is closest to the selected feature.
        let originToFeature = closestFeaturePoint - origin
        let hitTestResult = origin + (direction * simd_dot(direction, originToFeature))
        let hitTestResultDistance = simd_length(hitTestResult - origin)
        
        return FeatureHitTestResult(position: hitTestResult,
                                    distanceToRayOrigin: hitTestResultDistance,
                                    featureHit: closestFeaturePoint,
                                    featureDistanceToHitResult: minDistance)
    }
    
}
extension ARSCNView {
    
    func setup() {
        antialiasingMode = .multisampling4X
        automaticallyUpdatesLighting = false
        
        preferredFramesPerSecond = 60
        contentScaleFactor = 1.3
        
        if let camera = pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
            camera.maximumExposure = 3
        }
    }
}

// MARK: - Scene extensions

extension SCNScene {
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat, queue: DispatchQueue) {
        queue.async {
            if self.lightingEnvironment.contents == nil {
                if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
                    self.lightingEnvironment.contents = environmentMap
                }
            }
            self.lightingEnvironment.intensity = intensity
        }
    }
}




import Foundation
import ARKit

// MARK: - Collection extensions
extension Array where Iterator.Element == Float {
    var average: Float? {
        guard !self.isEmpty else {
            return nil
        }
        
        let sum = self.reduce(Float(0)) { current, next in
            return current + next
        }
        return sum / Float(self.count)
    }
}

extension Array where Iterator.Element == float3 {
    var average: float3? {
        guard !self.isEmpty else {
            return nil
        }
  
        let sum = self.reduce(float3(0)) { current, next in
            return current + next
        }
        return sum / Float(self.count)
    }
}

extension RangeReplaceableCollection where IndexDistance == Int {
    mutating func keepLast(_ elementsToKeep: Int) {
        if count > elementsToKeep {
            self.removeFirst(count - elementsToKeep)
        }
    }
}

// MARK: - SCNNode extension

extension SCNNode {
    
    func setUniformScale(_ scale: Float) {
        self.simdScale = float3(scale, scale, scale)
    }
    
    func renderOnTop(_ enable: Bool) {
        self.renderingOrder = enable ? 2 : 0
        if let geom = self.geometry {
            for material in geom.materials {
                material.readsFromDepthBuffer = enable ? false : true
            }
        }
        for child in self.childNodes {
            child.renderOnTop(enable)
        }
    }
}

// MARK: - float4x4 extensions

extension float4x4 {
    /// Treats matrix as a (right-hand column-major convention) transform matrix
    /// and factors out the translation component of the transform.
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

// MARK: - SCNMaterial extensions

extension SCNMaterial {
    
    static func material(withDiffuse diffuse: Any?, respondsToLighting: Bool = true) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = diffuse
        material.isDoubleSided = true
        if respondsToLighting {
            material.locksAmbientWithDiffuse = true
        } else {
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = diffuse
        }
        return material
    }
}

// MARK: - CGPoint extensions

extension CGPoint {
    
    init(_ size: CGSize) {
        self.init()
        self.x = size.width
        self.y = size.height
    }
    
    init(_ vector: SCNVector3) {
        self.init()
        self.x = CGFloat(vector.x)
        self.y = CGFloat(vector.y)
    }
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        return (self - point).length()
    }
    
    func length() -> CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
    func midpoint(_ point: CGPoint) -> CGPoint {
        return (self + point) / 2
    }
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }
    
    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
    
    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }
    
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
    
    static func /= (left: inout CGPoint, right: CGFloat) {
        left = left / right
    }
    
    static func *= (left: inout CGPoint, right: CGFloat) {
        left = left * right
    }
}

// MARK: - CGSize extensions

extension CGSize {
    
    init(_ point: CGPoint) {
        self.init()
        self.width = point.x
        self.height = point.y
    }

    static func + (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    static func - (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width - right.width, height: left.height - right.height)
    }

    static func += (left: inout CGSize, right: CGSize) {
        left = left + right
    }

    static func -= (left: inout CGSize, right: CGSize) {
        left = left - right
    }

    static func / (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width / right, height: left.height / right)
    }

    static func * (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width * right, height: left.height * right)
    }

    static func /= (left: inout CGSize, right: CGFloat) {
        left = left / right
    }

    static func *= (left: inout CGSize, right: CGFloat) {
        left = left * right
    }
}

// MARK: - CGRect extensions

extension CGRect {
    var mid: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

func rayIntersectionWithHorizontalPlane(rayOrigin: float3, direction: float3, planeY: Float) -> float3? {
    
    let direction = simd_normalize(direction)

    // Special case handling: Check if the ray is horizontal as well.
    if direction.y == 0 {
        if rayOrigin.y == planeY {
            // The ray is horizontal and on the plane, thus all points on the ray intersect with the plane.
            // Therefore we simply return the ray origin.
            return rayOrigin
        } else {
            // The ray is parallel to the plane and never intersects.
            return nil
        }
    }
    
    // The distance from the ray's origin to the intersection point on the plane is:
    //   (pointOnPlane - rayOrigin) dot planeNormal
    //  --------------------------------------------
    //          direction dot planeNormal
    
    // Since we know that horizontal planes have normal (0, 1, 0), we can simplify this to:
    let dist = (planeY - rayOrigin.y) / direction.y

    // Do not return intersections behind the ray's origin.
    if dist < 0 {
        return nil
    }
    
    // Return the intersection point.
    return rayOrigin + (direction * dist)
}


// MARK: - float3 extensions

extension float3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    static func + (left: float3, right: float3) -> float3 {
        return float3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func - (left: float3, right: float3) -> float3 {
        return float3(left.x - right.x, left.y - right.y, left.z - right.z)
    }

}

// MARK: - SCNVector3 extensions

extension SCNVector3 {
    
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
    }

}


