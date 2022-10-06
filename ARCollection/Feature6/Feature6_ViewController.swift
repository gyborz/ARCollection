//
//  Feature6_ViewController.swift
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 10. 02..
//

import ARKit
import Metal
import MetalKit
import SnapKit
import UIKit

extension MTKView: Feature6_RenderDestinationProvider { }

class Feature6_ViewController: UIViewController, MTKViewDelegate, ARSessionDelegate {
    private var session: ARSession!
    private var renderer: Feature6_Renderer!
    private var depthBuffer: CVPixelBuffer!
    private var confidenceBuffer: CVPixelBuffer!

    private let mtkView = MTKView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LiDAR depth of field"

        view.addSubview(mtkView)
        mtkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        session = ARSession()
        session.delegate = self
        view.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = .sceneDepth

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
        renderer = Feature6_Renderer(session: session, metalDevice: mtkView.device!, renderDestination: mtkView)

        renderer.drawRectResized(size: mtkView.bounds.size)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Feature4_ViewController.handleTap(gestureRecognize:)))
        mtkView.addGestureRecognizer(tapGesture)
    }

    // MARK: - MTKViewDelegate

    // Called whenever view changes orientation or size.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Schedule the screen to be redrawn at the new size.
        renderer.drawRectResized(size: size)
    }

    // Implements the main rendering loop.
    func draw(in view: MTKView) {
        renderer.update()
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion,
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                if let configuration = self.session.configuration {
                    self.session.run(configuration, options: .resetSceneReconstruction)
                }
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // Auto-hide the home indicator to maximize immersion in AR experiences.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    // Hide the status bar to maximize immersion in AR experiences.
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
