import UIKit
import QuartzCore
import SceneKit
import SceneKit.ModelIO

class DieController: UIViewController, SCNSceneRendererDelegate {
    
    enum DieState {
        case resting
        case holding
        case rolling
    }
    
    protocol Delegate {
        func dieDidBeginRoll()
        func dieDidBeginHold()
        func dieDidStopAtValue(_ value: Int)
    }
    
    var sceneFrame: CGRect!
    var sceneView: SCNView!
    var dieState = DieState.resting
    var delegate: Delegate?

    var cameraNode: SCNNode!
    var dieNode: SCNNode!
    
    var topWallNode: SCNNode!
    var leftWallNode: SCNNode!
    var bottomWallNode: SCNNode!
    var rightWallNode: SCNNode!
    var floorNode: SCNNode!
    var ceilingNode: SCNNode!
    
    var emitter: SCNParticleSystem!
    
    let dieFaceNodes = [
        SCNNode(),
        SCNNode(),
        SCNNode(),
        SCNNode(),
        SCNNode(),
        SCNNode(),
    ]
    
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
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(tapAction)))

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
        
        let asset = MDLAsset(url: Bundle.main.url(forResource: "die", withExtension: "usdz")!)
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
        dieNode.physicsBody!.rollingFriction = 0
        dieNode.physicsBody!.mass = 4
        dieNode.physicsBody!.linearRestingThreshold = 10
        dieNode.physicsBody!.angularRestingThreshold = 3
        dieNode.physicsBody!.restitution = 0.9
        scene.rootNode.addChildNode(dieNode)
        
        for node in dieFaceNodes {
            dieNode.addChildNode(node)
        }
        dieFaceNodes[0].position = .init( 0,  0,  1)
        dieFaceNodes[1].position = .init( 0, -1,  0)
        dieFaceNodes[2].position = .init( 1,  0,  0)
        dieFaceNodes[3].position = .init( 0,  1,  0)
        dieFaceNodes[4].position = .init(-1,  0,  0)
        dieFaceNodes[5].position = .init( 0,  0, -1)
        
        emitter = SCNParticleSystem(named: "sparkles.scnp", inDirectory: nil)
    }
    
    override func viewDidLayoutSubviews() {
        sceneFrame = sceneView.frame
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Prevent the die from clipping through walls
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
    
    func renderer(_ renderer: any SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // Update the position of the walls to match the viewport.
        let topLeftPoint = CGPoint(x: sceneFrame.minX, y: sceneFrame.minY)
        let topLeftPosition = viewPointToScene(topLeftPoint)
        let bottomRightPoint = CGPoint(x: sceneFrame.maxX, y: sceneFrame.maxY)
        let bottomRightPosition = viewPointToScene(bottomRightPoint)
        leftWallNode.position = topLeftPosition
        topWallNode.position = topLeftPosition
        rightWallNode.position = bottomRightPosition
        bottomWallNode.position = bottomRightPosition
                
        // Update the dieState once the die is at rest
        if (dieNode.physicsBody?.isResting ?? false) && (dieState == .rolling) {
            delegate?.dieDidStopAtValue(dieRollValue())
            dieNode.removeAllParticleSystems()
            dieState = .resting
        }
    }
    
    @objc private func tapAction(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
            
        case .began:
            guard dieState == .resting else { return }
            dieState = .holding
            delegate?.dieDidBeginHold()
            dieNode.simdEulerAngles = .random(in: 0...(.pi))
            fallthrough
            
        case .changed:
            guard dieState == .holding else { return }
            dieNode.physicsBody?.velocity = .init(x: 0, y: 0, z: 0)
            dieNode.physicsBody?.angularVelocity = .init(0, 0, 0, 0)
            dieNode.position = viewPointToScene(recognizer.location(in: sceneView))
            
        case .ended:
            guard dieState == .holding else { return }
            dieState = .rolling
            delegate?.dieDidBeginRoll()
            let velocity = recognizer.velocity(in: sceneView)
            var vx = Float(velocity.x)
            var vy = Float(velocity.y)
            let maxVelocity: Float = 3000
            while vx > maxVelocity || vy > maxVelocity {
                vx *= 0.9
                vy *= 0.9
            }
            
            // Apply a random rotation speed to the die
            let minTorque = 0
            let maxTorque = 1
            dieNode.physicsBody?.applyForce(.init(vx, 0, vy), asImpulse: false)
            dieNode.physicsBody?.applyTorque(.init(
                .random(in: minTorque...maxTorque),
                .random(in: minTorque...maxTorque),
                .random(in: minTorque...maxTorque),
                .random(in: minTorque...maxTorque)
            ), asImpulse: true)
            
            if (dieNode.particleSystems ?? []).isEmpty {
                dieNode.addParticleSystem(emitter)
            }
        default:
            ()
        }
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
    
    private func dieRollValue() -> Int {
        let upwardFaceNode = dieFaceNodes.sorted(by: {
            $0.presentation.worldPosition.y > $1.presentation.worldPosition.y
        }).first!
        return dieFaceNodes.firstIndex(of: upwardFaceNode)! + 1
    }
}
