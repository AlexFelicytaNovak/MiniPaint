//
//  Rectangle.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 18/06/2023.
//

import Foundation
import AppKit


struct Rectangle: CommonPolygonRectangle {
    mutating func ClippingSutherlandHodgman(clipPolygonEdges: [Line]) {
        return
    }
    
    
    @CodableColor
    var color: NSColor
    
    @CodableColor
    var fillingColor: NSColor
    
    @CodableColor
    var gradientColor1: NSColor = .clear
    
    @CodableColor
    var gradientColor2: NSColor = .clear
    
    var thickness: Int
    
    var gradientPoints: [Point] = []
    
    var isLineargradient: Bool? = nil
    var isNormalFillingMode: Bool = true
    
    @CodableBitmap
    var fillingImage: NSBitmapImageRep? = nil
    
    
    var rectangleEdges: [Line] = []
    var edges: [Line]{rectangleEdges}
    
    var isConvex: Bool {return true}
    init(color: NSColor = NSColor.black, thickness: Int = 1) {
        self.color = color
        self.thickness = thickness
        self.fillingColor = .clear
    }
    
    
    
    mutating func Modify(distanceX: Int, distanceY: Int, startingPoint: Point) {
        for selectedIndex in self.rectangleEdges.indices.filter( {self.rectangleEdges[$0].Selected(point: startingPoint)}
        ) {
            
            let selectedEdge = self.rectangleEdges[selectedIndex]
            var neighbouringEdges: [(Int, Point?)] = []

            for i in 0..<self.rectangleEdges.count {
                guard i != selectedIndex else {
                    continue
                }
                
                if  self.rectangleEdges[i].startPoint.compare(point: self.rectangleEdges[selectedIndex].endPoint) || self.rectangleEdges[i].endPoint.compare(point: self.rectangleEdges[selectedIndex].startPoint) || self.rectangleEdges[i].startPoint.compare(point: self.rectangleEdges[selectedIndex].startPoint) || self.rectangleEdges[i].endPoint.compare(point: self.rectangleEdges[selectedIndex].endPoint){
                    neighbouringEdges.append((i, nil))
                    print("index:\(i)")
                }
            }
            
            for i in 0..<neighbouringEdges.count {
                if self.rectangleEdges[neighbouringEdges[i].0].startPoint.compare(point: self.rectangleEdges[selectedIndex].endPoint){
                    neighbouringEdges[i].1=self.rectangleEdges[neighbouringEdges[i].0].startPoint
                } else if self.rectangleEdges[neighbouringEdges[i].0].endPoint.compare(point: self.rectangleEdges[selectedIndex].startPoint) {
                    neighbouringEdges[i].1=self.rectangleEdges[neighbouringEdges[i].0].endPoint
                } else if self.rectangleEdges[neighbouringEdges[i].0].endPoint.compare(point: self.rectangleEdges[selectedIndex].endPoint) {
                    neighbouringEdges[i].1=self.rectangleEdges[neighbouringEdges[i].0].endPoint
                } else if self.rectangleEdges[neighbouringEdges[i].0].startPoint.compare(point: self.rectangleEdges[selectedIndex].startPoint) {
                    neighbouringEdges[i].1=self.rectangleEdges[neighbouringEdges[i].0].startPoint
                }
            }
            guard neighbouringEdges.count >= 2 else {
                return
            }
            
            //parallel line
            var parallelLineIndex: Int?
            for i in 0..<self.rectangleEdges.count{
                
                guard i != selectedIndex && !neighbouringEdges.contains(where: { element in
                    element.0 == i
                }) else {
                    continue
                }
                parallelLineIndex = i
            }
            
            if selectedEdge.startPoint.x == selectedEdge.endPoint.x {
                let difference = self.rectangleEdges[selectedIndex].startPoint.x + distanceX - self.rectangleEdges[parallelLineIndex!].startPoint.x
                
                if abs(difference) >= 100 || (distanceX < 0 && difference < 0) || (distanceX > 0 && difference > 0) {
                    self.rectangleEdges[selectedIndex].Move(distanceX: distanceX, distanceY: 0)
                    self.rectangleEdges[neighbouringEdges[0].0].Modify(distanceX: distanceX, distanceY: 0, startingPoint: neighbouringEdges[0].1!)
                    self.rectangleEdges[neighbouringEdges[1].0].Modify(distanceX: distanceX, distanceY: 0, startingPoint: neighbouringEdges[1].1!)
                }

            } else if selectedEdge.startPoint.y == selectedEdge.endPoint.y {
                let difference = self.rectangleEdges[selectedIndex].startPoint.y + distanceY - self.rectangleEdges[parallelLineIndex!].startPoint.y
                if abs(difference) >= 100 || (distanceY < 0 && difference < 0) || (distanceY > 0 && difference > 0){
                    self.rectangleEdges[selectedIndex].Move(distanceX: 0, distanceY: distanceY)
                    self.rectangleEdges[neighbouringEdges[0].0].Modify(distanceX: 0, distanceY: distanceY, startingPoint: neighbouringEdges[0].1!)
                    self.rectangleEdges[neighbouringEdges[1].0].Modify(distanceX: 0, distanceY: distanceY, startingPoint: neighbouringEdges[1].1!)
                }
            }
        }
        
        
    }
    
    
    mutating func Move(distanceX: Int, distanceY: Int) {
        for i in 0..<self.rectangleEdges.count {
            self.rectangleEdges[i].Move(distanceX: distanceX, distanceY: distanceY)
        }
    }
    
    func Selected(point: Point) -> Bool {
        for edge in self.rectangleEdges {
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
        
        for edge in self.rectangleEdges {
            var edge = edge
            edge.color = color
            edge.thickness = thickness
            edge.Draw(image: image, isAA: isAA)
        }
        
        
    }
    
}

