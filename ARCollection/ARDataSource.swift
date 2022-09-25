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
        ARFeature(title: "4: Camera background replace", controller: Feature4_ViewController())
    ]
}
