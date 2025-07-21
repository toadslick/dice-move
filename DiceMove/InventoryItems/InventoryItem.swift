import Foundation

protocol InventoryItem: Identifiable {
    static var defaultValue: String { get }
    static var fileExtension: String { get }
    static var storageKey: String { get }
    static var all: [Self] { get }
    
    init(fileName: String)
    
    var fileName: String { get set }
    var id: String { get }
    var url: URL { get }
}

extension InventoryItem {
    static var all: [Self] {
        let urls = Bundle.main.urls(forResourcesWithExtension: Self.fileExtension, subdirectory: nil) ?? []
        return urls.map { url in
            let fileName = (url.pathComponents.last ?? "").replacingOccurrences(of: ".\(Self.fileExtension)", with: "")
            return .init(fileName: fileName)
        }
    }
    
    var id: String {
        fileName
    }
    
    var url: URL {
        Bundle.main.url(forResource: fileName, withExtension: Self.fileExtension)!
    }
}
