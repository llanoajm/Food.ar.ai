//
//  nodes--extensions.swift
//  TBD
//
//  Created by Antonio Llano on 3/1/21.
//

import Foundation
import SceneKit
extension SCNNode {

  public class func allNodes(from file: String) -> [SCNNode] {
    var nodesInFile = [SCNNode]()
    do {
      guard let sceneURL = Bundle.main.url(forResource: file, withExtension: nil) else {
        print("Could not find scene file \(file)")
        return nodesInFile
      }

      let objScene = try SCNScene(url: sceneURL as URL, options: [SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay])
      objScene.rootNode.enumerateChildNodes({ (node, _) in
        nodesInFile.append(node)
      })
    } catch {}
    return nodesInFile
  }
}
