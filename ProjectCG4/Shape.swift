//
//  Shape.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 14/04/2023.
//

import Foundation
import AppKit

protocol Shape: Codable {
    var color: NSColor { get set }
    var thickness: Int { get set }
    var fillingColor: NSColor {get set}
    var fillingImage: NSBitmapImageRep? {get set}
    var gradientColor1: NSColor {get set}
    var gradientColor2: NSColor {get set}
    
    func Draw(image: NSBitmapImageRep, isAA: Bool)
    func Selected(point: Point) -> Bool
    mutating func Move(distanceX: Int, distanceY: Int)
    mutating func Modify(distanceX: Int, distanceY: Int, startingPoint: Point)
}

protocol CommonPolygonRectangle: Shape {
    func ClippingSutherlandHodgman(clipPolygonEdges: [Line]) -> [Line]
    func FillPolygon(image: NSBitmapImageRep, isAA: Bool)
    var edges: [Line] {get}
    var isConvex: Bool {get}
    var gradientPoints: [Point] {get set}
    var isLineargradient: Bool? {get set}
    var isNormalFillingMode: Bool {get set}
}

@propertyWrapper
struct CodableColor: Codable {
    var wrappedValue: NSColor
    
    enum CodingKeys: String, CodingKey {
        case redComponent
        case greenComponent
        case blueComponent
        case alphaComponenet
    }
    
    init(wrappedValue: NSColor) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        let color = wrappedValue.usingColorSpace(.displayP3) ?? wrappedValue
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color.redComponent, forKey: .redComponent)
        try container.encode(color.greenComponent, forKey: .greenComponent)
        try container.encode(color.blueComponent, forKey: .blueComponent)
        if wrappedValue == .clear{
            
            try container.encode(0.0, forKey: .alphaComponenet)
        } else {
            try container.encode(color.alphaComponent, forKey: .alphaComponenet)
        }
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let redComponent = try container.decode(CGFloat.self, forKey: .redComponent)
        let greenComponent = try container.decode(CGFloat.self, forKey: .greenComponent)
        let blueComponent = try container.decode(CGFloat.self, forKey: .blueComponent)
        let alphaComponent = try container.decode(CGFloat.self, forKey: .alphaComponenet)
        
        let color = NSColor(displayP3Red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
        if alphaComponent == 0.0 {
            self.wrappedValue = .clear
        } else {
            self.wrappedValue = color.usingColorSpace(.deviceRGB) ?? color
        }
    }
}



@propertyWrapper
struct CodableBitmap: Codable{
    var wrappedValue: NSBitmapImageRep?
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(wrappedValue: NSBitmapImageRep?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(
            wrappedValue?.tiffRepresentation, forKey: .data)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let bitmapData = try? container.decode(Data.self, forKey: .data)
        
        if let bitmapData = bitmapData {
            self.wrappedValue = NSBitmapImageRep(data: bitmapData)
        }
        
    }
}
