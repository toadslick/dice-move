import SceneKit
import SceneKit.ModelIO

class Die: NSObject {
    
    enum State {
        case initializing
        case holding
        case released
        case rolling
        case resting
    }
    
    private static let facePositions: [SCNVector3] = [
        .init( 0,  0,  1),
        .init(-1,  0,  0),
        .init( 0, -1,  0),
        .init( 0,  1,  0),
        .init( 1,  0,  0),
        .init( 0,  0, -1),
    ]
    
    var dieNode: SCNNode?
    var state: State = .initializing

    var touchLocation: CGPoint
    var touchPreviousLocation: CGPoint

    private var faceNodes: [SCNNode]?
    private var surfaceNode: SCNNode?
    private var parentNode: SCNNode?
    
    private var overrideFaceValues: [Int]?

    var value: Int {
        guard let faceNodes else { return 0 }
        
        let upwardFaceNode = faceNodes.sorted(by: {
            $0.presentation.worldPosition.y > $1.presentation.worldPosition.y
        }).first!
        
        let index = faceNodes.firstIndex(of: upwardFaceNode)!
        
        if let overrideFaceValues {
            return overrideFaceValues[index]
        }
        return index + 1
    }
    
    private var currentSkin: UIImage {
        .init(resource: .init(name: Loot.skins.currentItem, bundle: .main))
    }
    
    init(
        at location: CGPoint,
        in parentNode: SCNNode,
        textureName: String,
        overrideFaceValues: [Int]? = nil
    ) {
        self.overrideFaceValues = overrideFaceValues
        self.parentNode = parentNode
        self.touchLocation = location
        self.touchPreviousLocation = location
        
        super.init()
        
        let asset = MDLAsset(url: Bundle.main.url(forResource: textureName, withExtension: "usdz")!)
        asset.loadTextures()
        dieNode = SCNNode(mdlObject: asset.object(at: 0))

        guard let dieNode else { return }
        
        dieNode.name = "die"
        
        dieNode.physicsBody = .init(type: .dynamic, shape: .init(
            geometry: SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0),
            options: [.type: SCNPhysicsShape.ShapeType.boundingBox]
        ))
        dieNode.physicsBody?.isAffectedByGravity = false
        dieNode.physicsBody?.friction = 1
        dieNode.physicsBody?.continuousCollisionDetectionThreshold = 0.5
        dieNode.physicsBody?.rollingFriction = 0
        dieNode.physicsBody?.mass = 4
        dieNode.physicsBody?.linearRestingThreshold = 10
        dieNode.physicsBody?.angularRestingThreshold = 3
        dieNode.physicsBody?.restitution = 0.9
    }
    
    func updateHolding(location: CGPoint, previousLocation: CGPoint, isHolding: Bool = true) {
        guard state == .holding else { return }
        
        touchLocation = location
        touchPreviousLocation = previousLocation
        
        if !isHolding {
            state = .released
        }
    }
    
    func render(at position: SCNVector3) {
        switch state {
        case .initializing:
            renderInitial(at: position)
        case .holding:
            renderHolding(at: position)
        case .released:
            renderRelease(at: position)
        case .rolling:
            renderRolling()
        case .resting:
            ()
        }
    }
    
    private func renderInitial(at position: SCNVector3) {
        guard
            let dieNode,
            let parentNode
        else { return }
        state = .holding

        dieNode.simdScale = .init(2, 2, 2)
        dieNode.simdEulerAngles = .random(in: 0...(.pi))
        dieNode.position = position
        
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
    
    private func renderHolding(at position: SCNVector3) {
        guard state == .holding else { return }
        
        guard let dieNode else { return }
        dieNode.position = position
        dieNode.physicsBody?.velocity = .init(0, 0, 0)
        dieNode.physicsBody?.angularVelocity = .init(0, 0, 0, 0)
    }
    
    private func renderRelease(at position: SCNVector3) {
        guard state == .released else { return }
        state = .rolling

        guard let dieNode else { return }
        
        dieNode.physicsBody?.isAffectedByGravity = true
        
        // Apply the linear force of the touch velocity
        let factor: Float = 30 // TODO: how to calculate this
        let vx = Float(touchLocation.x - touchPreviousLocation.x) * factor
        let vy = Float(touchLocation.y - touchPreviousLocation.y) * factor
        dieNode.physicsBody?.applyForce(.init(vx, 0, vy), asImpulse: false)
        
        // Apply a random spin
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
            let particle = SCNParticleSystem(named: "\(Loot.trails.currentItem).scnp", inDirectory: nil),
            let aura = SCNParticleSystem(named: "\(Loot.auras.currentItem).scnp", inDirectory: nil)
        {
            dieNode.addParticleSystem(particle)
            dieNode.addParticleSystem(aura)
        }
    }
    
    private func renderRolling() {
        guard
            state == .rolling,
            let dieNode,
            dieNode.physicsBody?.isResting ?? false
        else { return }
        state = .resting
    }

    func derender() {
        if let dieNode {
            dieNode.removeAllParticleSystems()
            dieNode.removeFromParentNode()
        }
        
        self.dieNode = nil
        self.surfaceNode = nil
        self.parentNode = nil
    }
    
    func renderWithinWalls(
        top topWallNode: SCNNode,
        bottom bottomWallNode: SCNNode,
        left leftWallNode: SCNNode,
        right rightWallNode: SCNNode,
        floor floorNode: SCNNode,
        ceiling ceilingNode: SCNNode
    ) {
        guard
            state == .holding || state == .rolling,
            let dieNode
        else { return }
        
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
}
