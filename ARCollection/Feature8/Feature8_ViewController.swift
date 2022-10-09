//
//  Feature8_ViewController.swift
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 10. 06..
//

import ARKit
import Combine
import RealityKit
import SnapKit
import UIKit

final class GameAssets {
    public var voxelEntity: VoxelEntity?
    public var voxelMaterial: SimpleMaterial?

    static func loadAssetsAsync() -> AnyPublisher<GameAssets, Error> {
        return VoxelEntity.loadAsync().map { voxel in
            let assets = GameAssets()
            assets.voxelEntity = voxel
            assets.voxelMaterial = voxel.material
            return assets
        }.eraseToAnyPublisher()
    }
}

enum Constants {
    static let accelerometerFramesPerSecond: Float = 60
    // fling feel scale constant
    static let flingVerticalScale: Float = 11.94

    static let voxelModelName = "Voxel_White"
    static let voxelCageName = "Voxel_Cage"
    static let voxelBaseColorName = "voxelBaseColor"
    static let voxelMetallicName = "voxelMetallic"
    static let voxelRoughnessName = "voxelRoughness"

    static let creatureShape = SIMD3<Float>(0.28, 0.15, 0.32)
    static let creatureLegsPositionAsRatio: Float = 0.3888
    // 2D Assets
    static let voxelBaseColorGreyValue: CGFloat = 0.8
    static let radar2DLocation = CGRect(x: 22.5, y: 22.5, width: 250, height: 250)
}

protocol GameViewControllerDelegate: AnyObject {
    func onSceneUpdated(_ arView: ARView, deltaTimeInterval: TimeInterval)
}

class Feature8_ViewController: UIViewController, UIGestureRecognizerDelegate {
    let arView = ARView()

    weak var delegate: GameViewControllerDelegate?

    private var disposeBag = Set<AnyCancellable>()

    private var assets: GameAssets?
    private var loadRequest: AnyCancellable?
    private var gameManager: GameManager?
    private var trackingConfiguration: ARWorldTrackingConfiguration?
    private var sceneBounds = CGSize()
    private var sceneObserver: Cancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        //title = "LiDAR space voxels"

        view.addSubview(arView)
        arView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadRequest = GameAssets.loadAssetsAsync()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { assets in
                      self.assets = assets
                      self.sceneObserver = self.arView.scene.subscribe(to: SceneEvents.Update.self, { event in
                          self.updateLoop(deltaTimeInterval: event.deltaTime)
                      })
                      self.arView.session.delegate = self
                      self.configureView()
                      self.sceneBounds = self.view.frame.size
                      self.gameManager = GameManager(viewController: self, assets: self.assets!)
                  })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        exitGame()
    }

    func configureView() {
        arView.automaticallyConfigureSession = false

        trackingConfiguration = ARWorldTrackingConfiguration()
        trackingConfiguration?.sceneReconstruction = .meshWithClassification
        trackingConfiguration?.planeDetection = [.horizontal, .vertical]
        arView.session.run(trackingConfiguration!)

        arView.environment.sceneUnderstanding.options = []
        arView.environment.sceneUnderstanding.options = [.collision, .physics]
        arView.renderOptions = [.disablePersonOcclusion]
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }

    private func exitGame() {
        delegate = nil
        gameManager = nil
        assets = nil

        gameManager?.shutdownGame()
        sceneObserver?.cancel()
        sceneObserver = nil
        arView.session.delegate = nil
        arView.scene.anchors.removeAll()
        if let trackingConfiguration = trackingConfiguration {
            trackingConfiguration.planeDetection = []
            trackingConfiguration.environmentTexturing = .none
            arView.session.run(trackingConfiguration, options: [.resetTracking, .removeExistingAnchors])
        }
        dismiss(animated: true, completion: nil)
    }

    private func updateLoop(deltaTimeInterval: TimeInterval) {
        delegate?.onSceneUpdated(arView, deltaTimeInterval: deltaTimeInterval)
    }
}

extension Feature8_ViewController: ARSessionDelegate { }
