import UIKit
import QuartzCore
import SceneKit
import SceneKit.ModelIO

class DiceController: UIViewController, SCNSceneRendererDelegate, Die.Delegate {
    
    protocol Delegate: Die.Delegate {
        func dice(didChange dice: Set<Die>, maxDice: Int)
    }
    
    private static let maxDice = 17
    
    var sceneFrame: CGRect!
    var sceneView: SCNView!
    var cameraNode: SCNNode!
    
    var topWallNode: SCNNode!
    var leftWallNode: SCNNode!
    var bottomWallNode: SCNNode!
    var rightWallNode: SCNNode!
    var floorNode: SCNNode!
    var ceilingNode: SCNNode!
    
    var dice: Set<Die> = []
    var heldDice: [UITouch: Die] = [:]
    var dieDelegate: Die.Delegate?
    
    override func loadView() {
        view = SCNView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = (self.view as! SCNView)
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.clear
        sceneView.contentMode = .center

        let scene = SCNScene()
        scene.physicsWorld.speed = 1.5
        sceneView.scene = scene
        
        cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera!.focalLength = 30
        cameraNode.camera!.fieldOfView = 30
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 12)
        cameraNode.simdRotate(
            by: simd_quatf(angle: -.pi / 2, axis: simd_normalize(simd_float3(1, 0, 0))),
            aroundTarget: simd_float3(x: 0, y: 0, z: 0)
        )
        scene.rootNode.addChildNode(cameraNode)
        
        floorNode = createWallNode()
        floorNode.simdRotate(
            by: simd_quatf(angle: -.pi / 2, axis: simd_normalize(simd_float3(1, 0, 0))),
            aroundTarget: simd_float3(x: 0, y: 0, z: 0)
        )
        floorNode.position = .init(x: 0, y: -3, z: 0)
        floorNode.opacity = 1
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        
        ceilingNode = createWallNode()
        ceilingNode.simdRotate(
            by: simd_quatf(angle: -.pi / 2, axis: simd_normalize(simd_float3(1, 0, 0))),
            aroundTarget: simd_float3(x: 0, y: 3, z: 0)
        )
        ceilingNode.position = .init(x: 0, y: 4, z: 0)
        ceilingNode.opacity = 0

        topWallNode = createWallNode()
        bottomWallNode = createWallNode()
        leftWallNode = createWallNode()
        rightWallNode = createWallNode()

        leftWallNode.simdRotate(
            by: simd_quatf(angle: -.pi / 2, axis: simd_normalize(simd_float3(0, 1, 0))),
            aroundTarget: simd_float3(x: 0, y: 0, z: 0)
        )
        
        rightWallNode.simdRotate(
            by: simd_quatf(angle: -.pi / 2, axis: simd_normalize(simd_float3(0, 1, 0))),
            aroundTarget: simd_float3(x: 0, y: 0, z: 0)
        )
    }
    
    override func viewDidLayoutSubviews() {
        sceneFrame = sceneView.frame
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Update the position of the walls to match the viewport.
        let topLeftPoint = CGPoint(x: sceneFrame.minX, y: sceneFrame.minY)
        let topLeftPosition = viewPointToScene(topLeftPoint)
        let bottomRightPoint = CGPoint(x: sceneFrame.maxX, y: sceneFrame.maxY)
        let bottomRightPosition = viewPointToScene(bottomRightPoint)
        leftWallNode.position = topLeftPosition
        topWallNode.position = topLeftPosition
        rightWallNode.position = bottomRightPosition
        bottomWallNode.position = bottomRightPosition
        
        for die in dice {
            die.maybeBeginResting()
            die.keepWithinWalls(
                top: topWallNode,
                bottom: bottomWallNode,
                left: leftWallNode,
                right: rightWallNode,
                floor: floorNode,
                ceiling: ceilingNode
            )
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let rootNode = sceneView.scene?.rootNode,
            dice.count < Self.maxDice
        else { return }
        
        for touch in touches {
            let position = viewPointToScene(touch.location(in: sceneView))
            
        
            let die: Die
            let percent = Float.random(in: 0...1)
            if percent > 0.98 {
                die = Die(in: rootNode, assetName: "Explosion", worth: [
                    1000, 1000, 1000, 3000, 1000, 1000,
                ])
            } else {
                die = Die(in: rootNode, assetName: "Default")
            }
            
            die.delegate = self
            dice.insert(die)
            heldDice[touch] = die
            die.beginHolding(at: position)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let position = viewPointToScene(touch.location(in: sceneView))
            heldDice[touch]?.continueHolding(at: position)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let currentLocation = viewPointToScene(touch.location(in: sceneView))
            let previousLocation = viewPointToScene(touch.previousLocation(in: sceneView))

            heldDice[touch]?.beginRolling(velocity: .init(
                x: CGFloat(currentLocation.x - previousLocation.x),
                y: CGFloat(currentLocation.z - previousLocation.z)
            ), at: currentLocation)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func die(_ die: Die, didStopOnValue value: Int) {
        die.despawn()
        dice.remove(die)
        dieDelegate?.die(die, didStopOnValue: value)
    }

    
    private func viewPointToScene(_ viewPoint: CGPoint) -> SCNVector3 {
        let scenePoint = sceneView.unprojectPoint(.init(x: Float(viewPoint.x), y: Float(viewPoint.y), z: 0))
        let factor = cameraNode.position.y
        return .init(x: scenePoint.x * factor, y: 0, z: scenePoint.z * factor)
    }
    
    private func createWallNode() -> SCNNode {
        let node = SCNNode(geometry: SCNPlane(width: 50, height: 50))
        node.opacity = 0
        node.physicsBody = .init(type: .static, shape: .init(
            geometry: SCNPlane(width: 50, height: 50)
        ))
        sceneView.scene!.rootNode.addChildNode(node)
        return node
    }
}
