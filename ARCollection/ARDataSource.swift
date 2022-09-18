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
        ARFeature(title: "1: VideoPlayer in RealityKit", controller: Feature1_ViewController())
    ]
}
