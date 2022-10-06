//
//  Feature7_ViewController.swift
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 10. 06..
//

import ARKit
import Metal
import MetalKit
import SnapKit
import UIKit

extension MTKView: Feature7_RenderDestinationProvider { }

class Feature7_ViewController: UIViewController, MTKViewDelegate, ARSessionDelegate {
    var session: ARSession!
    var renderer: Feature7_Renderer!

    private let mtkView = MTKView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Human and specific color"

        view.addSubview(mtkView)
        mtkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        session = ARSession()
        session.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Enable frame semantics
        // .personSegmentation or .personSegmentationWithDepth
        configuration.frameSemantics = .personSegmentationWithDepth

        // Run the view's session
        session.run(configuration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Set the view to use the default device
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.backgroundColor = UIColor.clear
        mtkView.delegate = self
        guard mtkView.device != nil else {
            print("Metal is not supported on this device")
            return
        }

        // Configure the renderer to draw to the view
        renderer = Feature7_Renderer(session: session, metalDevice: mtkView.device!, renderDestination: mtkView)

        renderer.drawRectResized(size: mtkView.bounds.size)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        session.pause()
    }

    // MARK: - MTKViewDelegate

    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }

    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.update()
    }
}
