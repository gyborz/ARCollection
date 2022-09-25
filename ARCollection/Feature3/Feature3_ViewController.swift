//
//  Feature3_ViewController.swift
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 09. 25..
//

import ARKit
import Metal
import MetalKit
import SnapKit
import UIKit

class Feature3_ViewController: UIViewController, MTKViewDelegate, ARSessionDelegate {
    var session: ARSession!
    var renderer: Feature3_Renderer!
    var mtkView = MTKView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LiDAR and Metal"

        view.addSubview(mtkView)
        mtkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        session = ARSession()
        session.delegate = self

        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.backgroundColor = .black
        mtkView.delegate = self

        renderer = Feature3_Renderer(session: session, view: mtkView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        renderer.update()
    }
}
