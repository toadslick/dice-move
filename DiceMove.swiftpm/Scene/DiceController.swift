import UIKit
import QuartzCore
import SceneKit
import SceneKit.ModelIO

class DiceController: UIViewController, SCNSceneRendererDelegate {
    
    enum State {
        case initializing
        case running
    }
    
    protocol Delegate {
        func die(_ die: Die, didStopOn value: Int, at point: CGPoint)
    }
    
    private var sceneFrame: CGRect!
    private var sceneView: SCNView!
    private var cameraNode: SCNNode!
    
    private var topWallNode: SCNNode!
    private var leftWallNode: SCNNode!
    private var bottomWallNode: SCNNode!
    private var rightWallNode: SCNNode!
    private var floorNode: SCNNode!
    private var ceilingNode: SCNNode!
    private var backgroundNode: SCNNode!
    
    private var explosions: Set<Explosion> = []
    private var heldDice: [UITouch: Die] = [:]
    private var state: State = .initializing
    
    var delegate: Delegate?
    
    private var dice: Set<Die> = [] {
        didSet {
            Game.shared.ammoUsed = dice.count
        }
    }
    
    override func loadView() {
        view = SCNView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.addObserver(self, forKeyPath: Loot.backgrounds.currentItemStorageKey, context: nil)
                
        sceneView = (self.view as! SCNView)
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.black
        sceneView.contentMode = .center
        sceneView.rendersContinuously = true
        
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
    }
    
    override func viewDidLayoutSubviews() {
        sceneFrame = sceneView.frame
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }
    
    // MARK: rendering
    
    func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
        renderInitial()
        renderWalls()
        renderBackground()
        
        heldDice.forEach { (touch, die) in
            die.updateHolding(
                location: touch.location(in: sceneView),
                previousLocation: touch.previousLocation(in: sceneView),
                isHolding: !(touch.phase == .ended || touch.phase == .cancelled)
            )
            if die.state == .released {
                heldDice.removeValue(forKey: touch)
            }
        }
        
        dice.forEach { die in
            die.render(at: viewPointToScene(die.touchLocation))
            
            die.renderWithinWalls(
                top: topWallNode,
                bottom: bottomWallNode,
                left: leftWallNode,
                right: rightWallNode,
                floor: floorNode,
                ceiling: ceilingNode
            )
            
            if die.state == .resting {
                renderExplosion(for: die)
                derender(die: die)
            }
        }
        
        explosions.forEach { exp in
            if exp.state == .done {
                explosions.remove(exp)
            }
        }
    }
    
    private func renderInitial() {
        guard state == .initializing else { return }
        state = .running
                
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
    
    // Update the position of the walls to match the viewport.
    private func renderWalls() {
        let wallOffset = 30.0
        
        let topLeftPoint = CGPoint(x: sceneFrame.minX - wallOffset, y: sceneFrame.minY - wallOffset)
        let topLeftPosition = viewPointToScene(topLeftPoint)
        let bottomRightPoint = CGPoint(x: sceneFrame.maxX + wallOffset, y: sceneFrame.maxY + wallOffset)
        let bottomRightPosition = viewPointToScene(bottomRightPoint)

        leftWallNode.position = topLeftPosition
        topWallNode.position = topLeftPosition
        rightWallNode.position = bottomRightPosition
        bottomWallNode.position = bottomRightPosition
    }
    
    private func renderBackground() {
        // Resize the background node to aspect-fill the view.
        let topLeft = viewPointToScene(.zero, additionalDepth: 10)
        let bottomRight = viewPointToScene(.init(x: sceneFrame.width, y: sceneFrame.height), additionalDepth: 10)
        let targetSize = max(bottomRight.x - topLeft.x, bottomRight.z - topLeft.z)
        let currentWidth = (backgroundNode.boundingBox.max.x - backgroundNode.boundingBox.min.x)
        let currentHeight = (backgroundNode.boundingBox.max.y - backgroundNode.boundingBox.min.y)
        backgroundNode.scale = .init(
            x: targetSize / currentWidth,
            y: targetSize / currentHeight,
            z: 1
        )
    }
    
    private func renderExplosion(for die: Die) {
        guard
            let position = die.dieNode?.presentation.worldPosition,
            let rootNode = sceneView.scene?.rootNode
        else { return }
        explosions.insert(.init(position: position, parentNode: rootNode))
    }

    private func derender(die: Die) {
        if let dieNode = die.dieNode {
            let viewPoint = sceneView.projectPoint(dieNode.presentation.worldPosition)
            delegate?.die(die, didStopOn: die.value, at: .init(
                x: Double(viewPoint.x),
                y: Double(viewPoint.y)
            ))
        }
        
        die.derender()
        dice.remove(die)
    }
    
    // MARK: touch handling
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            state == .running,
            let rootNode = sceneView.scene?.rootNode,
            dice.count < Game.shared.ammo
        else { return }

        for touch in touches {
            let die: Die
            let percent = Float.random(in: 0...1)
            let location = touch.location(in: sceneView)
            if percent > 0.98 {
                die = Die(at: location, in: rootNode, textureName: "Explosion", overrideFaceValues: [
                    1000, 1000, 1000, 3000, 1000, 1000,
                ])
            } else {
                die = Die(at: location, in: rootNode, textureName: Loot.faces.currentItem)
            }
            dice.insert(die)
            heldDice[touch] = die
        }
    }
    
    // MARK: helper methods
    
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
        if keyPath == Loot.backgrounds.currentItemStorageKey {
            setBackground()
        }
    }
    
    private func setBackground() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            
            let image = UIImage(named: Loot.backgrounds.currentItem)
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
        UserDefaults.standard.removeObserver(self, forKeyPath: Loot.backgrounds.currentItemStorageKey)
    }
}



