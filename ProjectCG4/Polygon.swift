//
//  Polygon.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 16/04/2023.
//

import Foundation
import AppKit
import Vision

struct Polygon: CommonPolygonRectangle {
    
    @CodableColor
    var color: NSColor
    
    var thickness: Int
    
    @CodableColor
    var fillingColor: NSColor
    
    @CodableColor
    var gradientColor1: NSColor = .clear
    
    @CodableColor
    var gradientColor2: NSColor = .clear
    
    @CodableBitmap
    var fillingImage: NSBitmapImageRep? = nil
    
    var edges: [Line] = []
    
    var gradientPoints: [Point] = []
    
    var isLineargradient: Bool? = nil
    var isNormalFillingMode: Bool = true
    //sprawdzanie czy jest convex
    var isConvex: Bool{ let determinants = Determinant(edges: self.edges)
        return determinants.allSatisfy{ det in
            det > 0
        } || determinants.allSatisfy{ det in
            det < 0
        }}
    
    func Direction(edges: [Line]) -> Bool {
        let determinants = Determinant(edges: edges)
        
        return determinants.allSatisfy{ det in
            det > 0
        }
        
    }
    
    init(color: NSColor = NSColor.black, thickness: Int = 1) {
        self.color = color
        self.thickness = thickness
        self.fillingColor = .clear
    }
    
    mutating func Modify(distanceX: Int, distanceY: Int, startingPoint: Point) {
        for i in 0..<self.edges.count {
            self.edges[i].Modify(distanceX: distanceX, distanceY: distanceY, startingPoint: startingPoint)
        }
        let selectedCount = self.edges.filter({$0.Selected(point: startingPoint)}).count
        let selectedIndex = self.edges.firstIndex(where: {$0.Selected(point: startingPoint)})
        
        if selectedCount == 1 {
            for i in 0..<self.edges.count {
                guard i != selectedIndex else {
                    continue
                }
                self.edges[i].Modify(distanceX: distanceX, distanceY: distanceY, startingPoint: self.edges[selectedIndex!].startPoint)
                self.edges[i].Modify(distanceX: distanceX, distanceY: distanceY, startingPoint: self.edges[selectedIndex!].endPoint)
            }
            self.edges[selectedIndex!].Move(distanceX: distanceX, distanceY: distanceY)
            
        }
    }
    
    
    mutating func Move(distanceX: Int, distanceY: Int) {
        for i in 0..<self.edges.count {
            self.edges[i].Move(distanceX: distanceX, distanceY: distanceY)
        }
    }
    
    func Selected(point: Point) -> Bool {
        for edge in self.edges {
            let isSelected = edge.Selected(point: point)
            if isSelected == true {
                return true
            }
        }
        return false
    }
    
    func Draw(image: NSBitmapImageRep, isAA: Bool) {
        if self.fillingColor != .clear || self.fillingImage != nil || (self.isLineargradient == false && self.gradientPoints.count == 2 && self.gradientColor1 != .clear && self.gradientColor2 != .clear) || (self.isLineargradient == true && self.gradientPoints.count == 2 && self.gradientColor1 != .clear && self.gradientColor2 != .clear) {
            FillPolygon(image: image, isAA: isAA)
            
            
        }
        
        for edge in self.edges {
            var edge = edge
            edge.color = color
            edge.thickness = thickness
            edge.Draw(image: image, isAA: isAA)
        }
        
        
        
    }
    
    
}
