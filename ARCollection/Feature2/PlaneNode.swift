//
//  PlaneNode.swift
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 09. 18..
//

import ARKit
import SceneKit

class PlaneNode: NSObject {
    public let contentNode: SCNNode
    private let geometryNode: SCNNode
    private let vertexEffectMaterial: SCNMaterial
    private let sceneView: ARSCNView
    private let viewportSize: CGSize
    private var time: Float = 0.0

    private let PLANE_SCALE = Float(0.75)
    private let PLANE_SEGS = 60

    init(sceneView: ARSCNView, viewportSize: CGSize) {
        self.sceneView = sceneView
        self.viewportSize = viewportSize

        let plane = SCNPlane(width: 1.0, height: 1.0)
        plane.widthSegmentCount = PLANE_SEGS
        plane.heightSegmentCount = PLANE_SEGS

        contentNode = SCNNode()

        geometryNode = SCNNode(geometry: plane)
        geometryNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        geometryNode.scale = SCNVector3(PLANE_SCALE, PLANE_SCALE, PLANE_SCALE)
        contentNode.addChildNode(geometryNode)

        vertexEffectMaterial = PlaneNode.createMaterial(vertexFunctionName: "Feature2_geometryEffectVertexShader", fragmentFunctionName: "Feature2_geometryEffectFragmentShader")
        vertexEffectMaterial.setValue(SCNMaterialProperty(contents: sceneView.scene.background.contents!), forKey: "diffuseTexture")

        super.init()

        geometryNode.geometry!.firstMaterial = vertexEffectMaterial
    }

    func update(time: TimeInterval, timeDelta: Float, waveHeight: Float, waveFrequency: Float) {
        self.time += timeDelta
        guard let frame = sceneView.session.currentFrame else { return }

        let affineTransform = frame.displayTransform(for: .portrait, viewportSize: viewportSize)
        let transform = SCNMatrix4(affineTransform)

        let material = geometryNode.geometry!.firstMaterial!
        material.setValue(SCNMatrix4Invert(transform), forKey: "u_displayTransform")
        material.setValue(NSNumber(value: self.time), forKey: "u_time")
        material.setValue(NSNumber(value: waveHeight), forKey: "u_waveHeight")
        material.setValue(NSNumber(value: waveFrequency), forKey: "u_waveFrequency")
    }

    private static func createMaterial(vertexFunctionName: String, fragmentFunctionName: String) -> SCNMaterial {
        let program = SCNProgram()
        program.vertexFunctionName = vertexFunctionName
        program.fragmentFunctionName = fragmentFunctionName

        let material = SCNMaterial()
        material.program = program

        return material
    }
}
