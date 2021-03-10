//
//  Sphere.swift
//  TBD
//
//  Created by Antonio Llano on 3/1/21.
//

import Foundation
class Sphere: SceneObject{
    init() {
        super.init(from: "sphere.dae")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
