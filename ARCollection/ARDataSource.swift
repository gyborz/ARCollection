//
//  ARDataSource.swift
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 09. 18..
//

import UIKit

struct ARFeature {
    let title: String
    let controller: UIViewController
}

struct ARDataSource {
    let features: [ARFeature] = [
        ARFeature(title: "1: VideoPlayer in RealityKit", controller: Feature1_ViewController()),
        ARFeature(title: "2: Space distortion", controller: Feature2_ViewController()),
        ARFeature(title: "3: LiDAR and Metal", controller: Feature3_ViewController()),
        ARFeature(title: "4: Camera background replace", controller: Feature4_ViewController()),
        ARFeature(title: "5: Multiple camera feed", controller: Feature5_ViewController()),
        ARFeature(title: "6: LiDAR depth of field", controller: Feature6_ViewController()),
        ARFeature(title: "7: Human and specific color", controller: Feature7_ViewController()),
        ARFeature(title: "8: LiDAR space voxels", controller: Feature8_ViewController())
    ]
}
