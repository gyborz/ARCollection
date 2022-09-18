//
//  Feature1_ViewController.swift
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 09. 18..
//

import ARKit
import AVFoundation
import RealityKit
import SnapKit
import UIKit

class Feature1_ViewController: UIViewController {
    private let arView = ARView()
    private var videoPlayer = AVPlayer()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        arView.session.pause()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "VideoPlayer in RealityKit"
        view.addSubview(arView)
        arView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "sample_320x240", ofType: "mp4")!)
        let playerItem = AVPlayerItem(url: videoURL)
        videoPlayer = AVPlayer(playerItem: playerItem)

        let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
        let videoPlane = ModelEntity(mesh: .generatePlane(width: 0.5, depth: 0.3), materials: [videoMaterial])
        let anchor = AnchorEntity()
        anchor.setPosition(SIMD3<Float>(x: 0, y: 0, z: -0.7), relativeTo: nil)
        let radians = GLKMathDegreesToRadians(90)
        let orientation = simd_quatf(angle: radians, axis: [1, 0, 0])
        anchor.setOrientation(orientation, relativeTo: nil)
        anchor.addChild(videoPlane)

        arView.scene.addAnchor(anchor)

        videoPlayer.play()

        NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    @objc private func loopVideo(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }
        playerItem.seek(to: CMTime.zero, completionHandler: nil)
        videoPlayer.play()
    }
}
