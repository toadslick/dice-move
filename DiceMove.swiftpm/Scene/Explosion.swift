import SceneKit

class Explosion: NSObject {
    
    enum State {
        case active
        case idle
        case done
    }
    
    static var all: Set<Explosion> = []
    static let activeDuration = 0.25
    static let idleDuration = 2.0
    
    var state = State.active
    
    private let node: SCNNode
    
    init(position: SCNVector3, parentNode: SCNNode) {
        node = .init()
        
        super.init()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            
            parentNode.addChildNode(node)
            node.position = position
            node.addParticleSystem(.init(named: InventoryCategory.explosions.currentItem, inDirectory: nil)!)
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + Self.activeDuration) {
                self.state = .idle
                self.node.particleSystems?.forEach {
                    $0.birthRate = 0
                }
                
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + Self.idleDuration) {
                    self.state = .done
                    self.node.removeAllParticleSystems()
                    self.node.removeFromParentNode()
                }
            }
        }
    }
}
