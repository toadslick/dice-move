import SceneKit
import SceneKit.ModelIO

class Die: NSObject {
    
    enum State {
        case holding
        case rolling
        case resting
    }
    
    protocol Delegate {
        func die(_ die: Die, didStopOn value: Int)
    }
    
    private static let facePositions: [SCNVector3] = [
        .init( 0,  0,  1),
        .init(-1,  0,  0),
        .init( 0, -1,  0),
        .init( 0,  1,  0),
        .init( 1,  0,  0),
        .init( 0,  0, -1),
    ]
    
    private static let velocityFactor: Float = 3000 // TODO: calculate based on frame rate
    
    var dieNode: SCNNode?
    private var faceNodes: [SCNNode]?
    private var surfaceNode: SCNNode?
    
    private var state = State.holding
    private var overrideFaceValues: [Int]?
    var delegate: Delegate?
    
    var value: Int {
        guard let faceNodes else { return 0 }
        
        let upwardFaceNode = faceNodes.sorted(by: {
            $0.presentation.worldPosition.y > $1.presentation.worldPosition.y
        }).first!
        return faceNodes.firstIndex(of: upwardFaceNode)! + 1
    }
    
    private var currentSkin: UIImage {
        .init(resource: .init(name: InventoryCategory.skins.currentItem, bundle: .main))
    }
    
    init(
        parentNode: SCNNode,
        textureName: String,
        overrideFaceValues: [Int]? = nil
    ) {
        self.overrideFaceValues = overrideFaceValues
        super.init()
        
        let asset = MDLAsset(url: Bundle.main.url(forResource: textureName, withExtension: "usdz")!)
        asset.loadTextures()
        dieNode = SCNNode(mdlObject: asset.object(at: 0))
        
        guard let dieNode else { return }
        
        dieNode.physicsBody = .init(type: .dynamic, shape: .init(
            geometry: SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0),
            options: [.type: SCNPhysicsShape.ShapeType.boundingBox]
        ))
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self, weak dieNode] in
            guard
                let self,
                let dieNode
            else { return }
            
            dieNode.name = "die"
            dieNode.simdScale = .init(2, 2, 2)
            dieNode.simdEulerAngles = .random(in: 0...(.pi))
            dieNode.position = .init(x: 0, y: 0, z: 0)
            
            
            parentNode.addChildNode(dieNode)
            
            surfaceNode = SCNNode(geometry: SCNBox(width: 0.302, height: 0.302, length: 0.302, chamferRadius: 0.02))
            guard let surfaceNode else { return }
            
            surfaceNode.position = .init(0, 0, 0)
            dieNode.addChildNode(surfaceNode)
            
            faceNodes = Die.facePositions.map {
                let node = SCNNode()
                node.position = $0
                return node
            }
            guard let faceNodes else { return }
            
            faceNodes.forEach(dieNode.addChildNode)
            
            surfaceNode.geometry?.firstMaterial?.diffuse.contents = currentSkin
        }
    }
    
    func continueHolding(at point: CGPoint, in sceneView: SCNView, depth: Float) {
        guard state == .holding else { return }

        DispatchQueue.global(qos: .userInteractive).async { [weak dieNode] in
            guard let dieNode else { return }
            let position = Self.viewPointToScene(point, sceneView: sceneView, depth: depth)
            dieNode.position = position
            dieNode.physicsBody?.velocity = .init(0, 0, 0)
            dieNode.physicsBody?.angularVelocity = .init(0, 0, 0, 0)
        }
    }
    
    func beginRolling(velocity: CGPoint, at point: CGPoint, in sceneView: SCNView, depth: Float) {
        guard state == .holding else { return }
        state = .rolling
        
        DispatchQueue.global(qos: .userInteractive).async { [weak dieNode] in
            guard let dieNode else { return }
            
            dieNode.physicsBody?.type = .dynamic
            dieNode.physicsBody?.friction = 1
            dieNode.physicsBody?.continuousCollisionDetectionThreshold = 0.5
            dieNode.physicsBody?.rollingFriction = 0
            dieNode.physicsBody?.mass = 4
            dieNode.physicsBody?.linearRestingThreshold = 10
            dieNode.physicsBody?.angularRestingThreshold = 3
            dieNode.physicsBody?.restitution = 0.9
            
            let vx = Float(velocity.x) * Self.velocityFactor
            let vy = Float(velocity.y) * Self.velocityFactor
            dieNode.physicsBody?.applyForce(.init(vx, 0, vy), asImpulse: false)
            
            // Apply a random angular force
            let minTorque = 0.05
            let maxTorque = 0.5
            dieNode.physicsBody?.applyTorque(.init(
                .random(in: minTorque...maxTorque),
                .random(in: minTorque...maxTorque),
                .random(in: minTorque...maxTorque),
                .random(in: minTorque...maxTorque)
            ), asImpulse: true)
            
            if
                (dieNode.particleSystems ?? []).isEmpty,
                let particle = SCNParticleSystem(named: "\(InventoryCategory.particles.currentItem).scnp", inDirectory: nil),
                let aura = SCNParticleSystem(named: "\(InventoryCategory.auras.currentItem).scnp", inDirectory: nil)
            {
                dieNode.addParticleSystem(particle)
                dieNode.addParticleSystem(aura)
            }
        }
    }
    
    func maybeBeginResting() {
        guard
            let dieNode,
            state == .rolling,
            dieNode.physicsBody?.isResting ?? false
        else { return }
        state = .resting
        
        var money = value
        if let overrideFaceValues {
            money = overrideFaceValues[value - 1]
        }
        delegate?.die(self, didStopOn: money)
    }

    
    // Prevent the die from clipping through walls
    func keepWithinWalls(
        top topWallNode: SCNNode,
        bottom bottomWallNode: SCNNode,
        left leftWallNode: SCNNode,
        right rightWallNode: SCNNode,
        floor floorNode: SCNNode,
        ceiling ceilingNode: SCNNode
    ) {
        guard let dieNode else { return }
        
        var x = dieNode.presentation.worldPosition.x
        var y = dieNode.presentation.worldPosition.y
        var z = dieNode.presentation.worldPosition.z
        var didClip = false
        if dieNode.presentation.worldPosition.x < leftWallNode.presentation.worldPosition.x {
            didClip = true
            x = leftWallNode.presentation.worldPosition.x + dieNode.presentation.boundingSphere.radius
        }
        if dieNode.presentation.worldPosition.x > rightWallNode.presentation.worldPosition.x {
            didClip = true
            x = rightWallNode.presentation.worldPosition.x - dieNode.presentation.boundingSphere.radius
        }
        if dieNode.presentation.worldPosition.z < topWallNode.presentation.worldPosition.z {
            didClip = true
            z = topWallNode.presentation.worldPosition.z + dieNode.presentation.boundingSphere.radius
        }
        if dieNode.presentation.worldPosition.z > bottomWallNode.presentation.worldPosition.z {
            didClip = true
            z = bottomWallNode.presentation.worldPosition.z - dieNode.presentation.boundingSphere.radius
        }
        if dieNode.presentation.worldPosition.y < floorNode.presentation.worldPosition.y {
            didClip = true
            y = 0
        }
        if dieNode.presentation.worldPosition.y > ceilingNode.presentation.worldPosition.y {
            didClip = true
            y = 0
        }
        if didClip {
            dieNode.position = .init(x: x, y: y, z: z)
        }
    }
    
    func despawn() {
        guard let dieNode else { return }
        dieNode.removeAllParticleSystems()
        dieNode.removeFromParentNode()
    }
    
    private static func viewPointToScene(_ viewPoint: CGPoint, sceneView: SCNView, depth: Float) -> SCNVector3 {
        let scenePoint = sceneView.unprojectPoint(.init(x: Float(viewPoint.x), y: Float(viewPoint.y), z: 0))
        return .init(x: scenePoint.x * depth, y: 0, z: scenePoint.z * depth)
    }
}
