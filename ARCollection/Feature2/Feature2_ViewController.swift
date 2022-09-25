//
//  Feature2_ViewController.swift
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 09. 18..
//

import ARKit
import SceneKit
import SnapKit
import UIKit

class Feature2_ViewController: UIViewController {
    private var sceneView: ARSCNView!
    private var placedPlane = false
    private var planeNode: PlaneNode?
    private let configuration = ARWorldTrackingConfiguration()
    private var viewFrame: CGRect?
    private var lastUpdateTime: TimeInterval?

    private var waveHeight: Float = 0.25
    private var waveFrequency: Float = 20.0

    private let heightLabel = UILabel()
    private let heightSlider = UISlider()
    private let frequencyLabel = UILabel()
    private let frequencySlider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Space distortion"

        sceneView = ARSCNView(frame: view.bounds, options: [
            SCNView.Option.preferredRenderingAPI.rawValue: SCNRenderingAPI.metal,
        ])

        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true

        setupUI()

        viewFrame = sceneView.bounds

        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal, .vertical]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    private func setupUI() {
        view.addSubview(sceneView)
        view.addSubview(heightLabel)
        view.addSubview(heightSlider)
        view.addSubview(frequencyLabel)
        view.addSubview(frequencySlider)

        sceneView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        frequencySlider.minimumValue = 0.0
        frequencySlider.maximumValue = 50.0
        frequencySlider.setValue(20.0, animated: false)
        frequencySlider.addTarget(self, action: #selector(changeFrequency), for: .valueChanged)
        frequencySlider.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
        }

        frequencyLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        frequencyLabel.textColor = .white
        frequencyLabel.text = "Wave frequency"
        frequencyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalTo(frequencySlider.snp.top).offset(-20)
        }

        heightSlider.minimumValue = 0.0
        heightSlider.maximumValue = 1.0
        heightSlider.setValue(0.25, animated: false)
        heightSlider.addTarget(self, action: #selector(changeHeight), for: .valueChanged)
        heightSlider.snp.makeConstraints { make in
            make.bottom.equalTo(frequencyLabel.snp.top).offset(-36)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        heightLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        heightLabel.textColor = .white
        heightLabel.text = "Wave height"
        heightLabel.snp.makeConstraints { make in
            make.bottom.equalTo(heightSlider.snp.top).offset(-20)
            make.leading.equalToSuperview().inset(24)
        }
    }

    @objc private func changeFrequency(_ sender: UISlider) {
        waveFrequency = sender.value
    }

    @objc private func changeHeight(_ sender: UISlider) {
        waveHeight = sender.value
    }
}

extension Feature2_ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard planeNode == nil else { return nil }

        if anchor is ARPlaneAnchor {
            planeNode = PlaneNode(sceneView: sceneView, viewportSize: viewFrame!.size)
            sceneView.scene.rootNode.addChildNode(planeNode!.contentNode)
        }

        return nil
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let delta: Float = lastUpdateTime == nil ? 0.03 : Float(time - lastUpdateTime!)
        lastUpdateTime = time

        if planeNode != nil {
            let couldPlace = tryPlacePlaneInWorld(planeNode: planeNode!, screenLocation: CGPoint(x: viewFrame!.width / 2, y: viewFrame!.height / 2))

            planeNode!.contentNode.isHidden = !couldPlace
        }

        planeNode?.update(time: time, timeDelta: delta, waveHeight: waveHeight, waveFrequency: waveFrequency)
    }

    private func tryPlacePlaneInWorld(planeNode: PlaneNode, screenLocation: CGPoint) -> Bool {
        if placedPlane {
            return true
        }

        guard let query = sceneView.raycastQuery(from: screenLocation, allowing: .existingPlaneGeometry, alignment: .any), let hitTestResult = sceneView.session.raycast(query).first else { return false }

        placedPlane = true
        planeNode.contentNode.simdWorldTransform = hitTestResult.worldTransform

        return true
    }
}
