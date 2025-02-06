//
//  Document.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 13/04/2023.
//

import Cocoa

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

struct ShapeDecodable: Decodable {
    public let shape: Shape
    
    public init(from decoder: Decoder) throws {
        if let line = try? Line(from: decoder) {
            shape = line
        } else if let polygon = try? Polygon(from: decoder) {
            shape = polygon
        } else if let circle = try? Circle(from: decoder) {
            shape = circle
        } else if let rectangle = try? Rectangle(from: decoder) {
            shape = rectangle
        } else {
            shape = try Ellipse(from: decoder)
        }
    }
}

class Document: NSDocument {
    var canvas: NSBitmapImageRep!
    var shapes: [Shape] = []
    override init() {
        super.init()
       
    }
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        return try JSONEncoder().encode(shapes.map({ AnyEncodable($0) }))
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        self.shapes = try JSONDecoder().decode([ShapeDecodable].self, from: data).map(\.shape)
    }
    
    
}

