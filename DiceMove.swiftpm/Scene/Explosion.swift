import SceneKit

class Explosion: NSObject {
    
    static var all: Set<Explosion> = []
    static let emissionDuration = 0.25
    static let idleDuration = 0.1
    
    var timer: Timer? = nil
    let node: SCNNode
    let particleSystem: SCNParticleSystem
    
    init(position: SCNVector3, parentNode: SCNNode) {
        node = .init()
        particleSystem = .init(named: InventoryCategory.explosions.currentItem, inDirectory: nil)!
        
        super.init()
        
//        DispatchQueue.global(qos: .background).async {
//            parentNode.addChildNode(node)
//            node.addParticleSystem(particleSystem)
//        }
        node.addParticleSystem(particleSystem)
    }
}
