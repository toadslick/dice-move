import UIKit
import QuartzCore
import SceneKit
import SceneKit.ModelIO

class DiceController: UIViewController, SCNSceneRendererDelegate, Die.Delegate {
    
    protocol Delegate {
        func die(_ die: Die, didStopOn value: Int, at point: CGPoint)
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
    var backgroundNode: SCNNode!
    
    var dice: Set<Die> = []
    var heldDice: [UITouch: Die] = [:]
    var delegate: Delegate?
    
    override func loadView() {
        view = SCNView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.addObserver(self, forKeyPath: InventoryCategory.backgrounds.storageKey, context: nil)
                
        sceneView = (self.view as! SCNView)
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.black
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
        
        backgroundNode = createWallNode()
        backgroundNode.simdRotate(
            by: simd_quatf(angle: -.pi / 2, axis: simd_normalize(simd_float3(1, 0, 0))),
            aroundTarget: simd_float3(x: 0, y: 0, z: 0)
        )
        backgroundNode.position = .init(x: 0, y: -10, z: 0)
        backgroundNode.geometry?.firstMaterial?.isDoubleSided = true
        setBackground()
        
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
        
        // Resize the background node to aspect-fill the view.
        let topLeft = viewPointToScene(.zero, additionalDepth: 11)
        let bottomRight = viewPointToScene(.init(x: sceneFrame.width, y: sceneFrame.height), additionalDepth: 10)
        let targetSize = max(bottomRight.x - topLeft.x, bottomRight.z - topLeft.z)
        let currentWidth = (backgroundNode.boundingBox.max.x - backgroundNode.boundingBox.min.x)
        let currentHeight = (backgroundNode.boundingBox.max.y - backgroundNode.boundingBox.min.y)
        backgroundNode.scale = .init(
            x: targetSize / currentWidth,
            y: targetSize / currentHeight,
            z: 1
        )
        
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
            let die: Die
            
            let percent = Float.random(in: 0...1)
            if percent > 0.98 {
                die = Die(parentNode: rootNode, textureName: "Explosion", overrideFaceValues: [
                    1000, 1000, 1000, 3000, 1000, 1000,
                ])
            } else {
                die = Die(parentNode: rootNode, textureName: InventoryCategory.faces.currentItem)
            }
            die.delegate = self
            dice.insert(die)
            heldDice[touch] = die
            die.continueHolding(at: touch.location(in: sceneView), in: sceneView, depth: cameraNode.position.y)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            heldDice[touch]?.continueHolding(at: touch.location(in: sceneView), in: sceneView, depth: cameraNode.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let currentLocation = viewPointToScene(touch.location(in: sceneView))
            let previousLocation = viewPointToScene(touch.previousLocation(in: sceneView))
            
            heldDice[touch]?.beginRolling(velocity: .init(
                x: CGFloat(currentLocation.x - previousLocation.x),
                y: CGFloat(currentLocation.z - previousLocation.z)
            ), at: touch.location(in: sceneView), in: sceneView, depth: cameraNode.position.y)
            heldDice.removeValue(forKey: touch)
        }
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func die(_ die: Die, didStopOn value: Int) {
        dice.remove(die)
        die.despawn()
        
        guard let dieNode = die.dieNode else { return }
        let position = sceneView.projectPoint(dieNode.presentation.worldPosition)
        let point = CGPoint(
            x: CGFloat(position.x),
            y: CGFloat(position.y)
        )
        delegate?.die(die, didStopOn: value, at: point)
    }
    
    
    private func viewPointToScene(_ viewPoint: CGPoint, additionalDepth: Float = 0) -> SCNVector3 {
        let scenePoint = sceneView.unprojectPoint(.init(x: Float(viewPoint.x), y: Float(viewPoint.y), z: 0))
        let factor = cameraNode.position.y + additionalDepth
        return .init(x: scenePoint.x * factor, y: 0, z: scenePoint.z * factor)
    }
    
    private func createWallNode() -> SCNNode {
        let size = 30.0
        let node = SCNNode(geometry: SCNPlane(width: size, height: size))
        node.opacity = 0
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        node.physicsBody = .init(type: .static, shape: .init(
            geometry: SCNPlane(width: size, height: size)
        ))
        sceneView.scene!.rootNode.addChildNode(node)
        return node
    }
    
    // MARK: update background when changed
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == InventoryCategory.backgrounds.storageKey {
            setBackground()
        }
    }
    
    private func setBackground() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            
            let image = UIImage(named: InventoryCategory.backgrounds.currentItem)
            backgroundNode.geometry?.firstMaterial?.diffuse.contents = image
            
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = backgroundNode.opacity
            animation.toValue = 1.0
            animation.duration = 2
            animation.autoreverses = false
            animation.repeatCount = .zero
            animation.isRemovedOnCompletion = true
            backgroundNode.addAnimation(animation, forKey: nil)
            backgroundNode.opacity = 1
        }
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: InventoryCategory.backgrounds.storageKey)
    }
}



