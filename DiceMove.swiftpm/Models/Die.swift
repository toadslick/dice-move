import SceneKit
import SceneKit.ModelIO

class Die: NSObject {
    
    enum State {
        case resting
        case holding
        case rolling
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
    
    private static let velocityFactor: Float = 2000 // TODO: calculate based on frame rate
    
    let dieNode: SCNNode
    let faceNodes: [SCNNode]
    let surfaceNode: SCNNode
    
    private let worth: [Int]?
    
    var delegate: Delegate?
    
    public private(set) var state = State.resting
    
    var value: Int {
        let upwardFaceNode = faceNodes.sorted(by: {
            $0.presentation.worldPosition.y > $1.presentation.worldPosition.y
        }).first!
        return faceNodes.firstIndex(of: upwardFaceNode)! + 1
    }
    
    private var currentSkin: UIImage {
        .init(resource: .init(name: InventoryCategory.skins.currentItem, bundle: .main))
    }

    init(in parentNode: SCNNode, assetName: String, worth: [Int]? = nil) {
        self.worth = worth
        
        let asset = MDLAsset(url: Bundle.main.url(forResource: assetName, withExtension: "usdz")!)
        asset.loadTextures()
        
        dieNode = SCNNode(mdlObject: asset.object(at: 0))
        dieNode.name = "die"
        dieNode.simdScale = .init(2, 2, 2)
        dieNode.position = .init(x: 0, y: 0, z: 0)
        dieNode.physicsBody = .init(type: .dynamic, shape: .init(
            geometry: SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0),
            options: [.type: SCNPhysicsShape.ShapeType.boundingBox]
        ))
        dieNode.physicsBody!.friction = 1
        dieNode.physicsBody!.continuousCollisionDetectionThreshold = 0.5
        dieNode.physicsBody!.rollingFriction = 0
        dieNode.physicsBody!.mass = 4
        dieNode.physicsBody!.linearRestingThreshold = 10
        dieNode.physicsBody!.angularRestingThreshold = 3
        dieNode.physicsBody!.restitution = 0.9
        parentNode.addChildNode(dieNode)
        
        surfaceNode = SCNNode(geometry: SCNBox(width: 0.302, height: 0.302, length: 0.302, chamferRadius: 0.02))
        surfaceNode.position = .init(0, 0, 0)
        dieNode.addChildNode(surfaceNode)
        
        faceNodes = Die.facePositions.map {
            let node = SCNNode()
            node.position = $0
            return node
        }
        
        faceNodes.forEach(dieNode.addChildNode)
        
        super.init()
        
        surfaceNode.geometry?.firstMaterial?.diffuse.contents = currentSkin
    }
    
    func beginHolding(at position: SCNVector3) {
        guard state == .resting else { return }
        state = .holding
        
        dieNode.physicsBody!.type = .kinematic
        dieNode.simdEulerAngles = .random(in: 0...(.pi))
        continueHolding(at: position)
    }
    
    func continueHolding(at position: SCNVector3) {
        guard state == .holding else { return }

        dieNode.position = position
        dieNode.physicsBody?.velocity = .init(0, 0, 0)
        dieNode.physicsBody?.angularVelocity = .init(0, 0, 0, 0)
    }
    
    func beginRolling(velocity: CGPoint, at position: SCNVector3) {
        guard state == .holding else { return }
        continueHolding(at: position)
        state = .rolling
        
        dieNode.physicsBody!.type = .dynamic

        let vx = Float(velocity.x) * Self.velocityFactor
        let vy = Float(velocity.y) * Self.velocityFactor
        dieNode.physicsBody!.applyForce(.init(vx, 0, vy), asImpulse: false)

        // Apply a random angular force
        let minTorque = 0.05
        let maxTorque = 0.5
        dieNode.physicsBody!.applyTorque(.init(
            .random(in: minTorque...maxTorque),
            .random(in: minTorque...maxTorque),
            .random(in: minTorque...maxTorque),
            .random(in: minTorque...maxTorque)
        ), asImpulse: true)

        if
            (dieNode.particleSystems ?? []).isEmpty,
            let ps = SCNParticleSystem(named: "\(InventoryCategory.particles.currentItem).scnp", inDirectory: nil)
        {
            dieNode.addParticleSystem(ps)
        }
    }
    
    func maybeBeginResting() {
        guard state == .rolling else { return }
        
        if (dieNode.physicsBody!.isResting) {
            state = .resting
            
            dieNode.removeAllParticleSystems()
            var money = value
            if let worth {
                money = worth[value - 1]
            }
            delegate?.die(self, didStopOn: money)
        }
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
        dieNode.removeAllParticleSystems()
        dieNode.removeFromParentNode()
    }
}
