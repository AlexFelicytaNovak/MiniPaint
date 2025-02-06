//
//  CommonPolygonRectangleExtention.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 29/06/2023.
//

import Foundation
import AppKit
import Vision

infix operator %%

extension Int {
    
    static  func %% (_ left: Int, _ right: Int) -> Int {
        let mod = left % right
        return mod >= 0 ? mod : mod + right
    }
    
}

extension CommonPolygonRectangle {
    //MARK: Common functions
    func OrderingVertices(edges: [Line]) -> [Point] {
        var vertices: [Point] = []
        vertices.append(edges[0].startPoint)
        while edges.contains(where: {!vertices.contains($0.startPoint) || !vertices.contains($0.endPoint)}){
            
            for edge in edges {
                if vertices.last == edge.endPoint &&  !vertices.contains(edge.startPoint){
                    vertices.append(edge.startPoint)
                } else if vertices.last == edge.startPoint && !vertices.contains(edge.endPoint){
                    vertices.append(edge.endPoint)
                }
                
            }
            
        }
        
        return vertices
    }
    // MARK: Clipping functions
    
    func Determinant(edges: [Line])->[Int] {
        let vertices = OrderingVertices(edges: edges)
        var verticesTriples: [(Point,Point,Point)] = stride(from: 0, to: vertices.count - 2, by: 1).map {
            (vertices[$0], vertices[$0+1], vertices[$0+2])
        }
        verticesTriples.append((vertices[vertices.count - 2], vertices[vertices.count - 1], vertices[0]))
        verticesTriples.append((vertices[vertices.count - 1], vertices[0], vertices[1]))
        
        var determinants: [Int] = []
        
        for triple in verticesTriples{
            
            let x1 = triple.0.x
            let y1 = triple.0.y
            let x2 = triple.1.x
            let y2 = triple.1.y
            let x3 = triple.2.x
            let y3 = triple.2.y
            determinants.append(x1*y2+x2*y3+x3*y1-(y2*x3+y3*x1+y1*x2))
            
        }
        return determinants
    }
    
    func Direction(edges: [Line]) -> Bool {
        let determinants = Determinant(edges: edges)
        
        return determinants.allSatisfy{ det in
            det > 0
        }
        
    }
    
    func PointLineCheck(polygonEdge:(Point, Point), clipEdge:(Point, Point)) -> Bool{
        
        let x1 = clipEdge.0.x
        let y1 =  clipEdge.0.y
        let x2 =  clipEdge.1.x
        let y2 =  clipEdge.1.y
        let x3ClipPoint1 = polygonEdge.0.x
        let y3ClipPoint1 = polygonEdge.0.y
        let x3ClipPoint2 = polygonEdge.1.x
        let y3ClipPoint2 = polygonEdge.1.y
        let det1 = x1*y2+x2*y3ClipPoint1+x3ClipPoint1*y1-(y2*x3ClipPoint1+y3ClipPoint1*x1+y1*x2)
        let det2 = x1*y2+x2*y3ClipPoint2+x3ClipPoint2*y1-(y2*x3ClipPoint2+y3ClipPoint2*x1+y1*x2)
        return (det1.signum() == det2.signum())
        
    }
    
    //CLIPPING SH
    func ClippingSutherlandHodgman(clipPolygonEdges: [Line]) -> [Line]{
        
        let verticesSubjetcPolygon = OrderingVertices(edges: self.edges)
        let verticesClipPolygon = OrderingVertices(edges: clipPolygonEdges)
        
        var edgesFromVerticesSubjectPolygon = stride(from: 0, to: verticesSubjetcPolygon.count - 1, by: 1).map {
            (verticesSubjetcPolygon[$0], verticesSubjetcPolygon[$0+1])
        }
        edgesFromVerticesSubjectPolygon.append((verticesSubjetcPolygon[verticesSubjetcPolygon.count - 1], verticesSubjetcPolygon[0]))
        
        var edgesFromVerticesClipPolygon = stride(from: 0, to: verticesClipPolygon.count - 1, by: 1).map {
            (verticesClipPolygon[$0], verticesClipPolygon[$0+1])
        }
        edgesFromVerticesClipPolygon.append((verticesClipPolygon[verticesClipPolygon.count - 1], verticesClipPolygon[0]))
        
        
        for clipEdge in edgesFromVerticesClipPolygon{
            let vectorLength = sqrt(Double((clipEdge.1.x - clipEdge.0.x)*(clipEdge.1.x - clipEdge.0.x)+(clipEdge.1.y - clipEdge.0.y)*(clipEdge.1.y - clipEdge.0.y)))
            let unitVector = (Double(clipEdge.1.x - clipEdge.0.x)/vectorLength, Double(clipEdge.1.y - clipEdge.0.y)/vectorLength )
            var normalVector: VNVector

            if Direction(edges: clipPolygonEdges) {
                normalVector = VNVector(xComponent: unitVector.1, yComponent: -unitVector.0)
            } else {
                normalVector = VNVector(xComponent: -unitVector.1, yComponent: unitVector.0)
            }
            
            var newPolygonVertices: [Point] = []
            
            for polygonEdge in edgesFromVerticesSubjectPolygon {
                if PointLineCheck(polygonEdge: polygonEdge, clipEdge: clipEdge){
                    let difference = VNVector(xComponent:  Double(polygonEdge.1.x - clipEdge.0.x), yComponent: Double(polygonEdge.1.y - clipEdge.0.y))
                    let dotProduct = VNVector.dotProduct(of: normalVector, vector: difference)
                    if dotProduct < 0 {
                        newPolygonVertices.append(polygonEdge.1)
                    }
                    
                } else {
                    let D = VNVector(xComponent: Double(polygonEdge.1.x - polygonEdge.0.x), yComponent: Double(polygonEdge.1.y - polygonEdge.0.y))
                    let diff = VNVector(xComponent: Double(polygonEdge.0.x - clipEdge.0.x), yComponent: Double(polygonEdge.0.y - clipEdge.0.y))
                    let t = VNVector.dotProduct(of: normalVector, vector: diff)/VNVector.dotProduct(of: VNVector.init(bySubtracting: normalVector, from: .zero), vector: D)
                    
                    let intersectionPoint = Point(x: polygonEdge.0.x  + Int(t*Double(polygonEdge.1.x - polygonEdge.0.x)), y: polygonEdge.0.y  + Int(t*Double(polygonEdge.1.y - polygonEdge.0.y )))
                    if VNVector.dotProduct(of: normalVector, vector: D) > 0 {
                        newPolygonVertices.append(intersectionPoint)
                    } else if VNVector.dotProduct(of: normalVector, vector: D) < 0 {
                        newPolygonVertices.append(intersectionPoint)
                        newPolygonVertices.append(polygonEdge.1)
                    }
                    
                }
                
            }
            
            if newPolygonVertices.count == 0{
                print("count:\(newPolygonVertices.count)")
            } else {
                edgesFromVerticesSubjectPolygon = stride(from: 0, to: newPolygonVertices.count - 1, by: 1).map {
                    (newPolygonVertices[$0], newPolygonVertices[$0+1])
                }
                edgesFromVerticesSubjectPolygon.append((newPolygonVertices[newPolygonVertices.count - 1], newPolygonVertices[0]))
            }
            
            
            
            
        }
        
        return edgesFromVerticesSubjectPolygon.map({ pair in
            Line( startPoint: pair.0, endPoint: pair.1)
        })
    }
    
    //MARK: FILLING VERTEX SORTING
    
    func AETUpdate(AET: inout [(Int, Double, Double, Int)], currentPoint: Point, point: Point, dy: Int ) {
        AET.append((point.y, Double(currentPoint.x), Double(Double(point.y-currentPoint.y)/Double(point.x-currentPoint.x)), dy))
    }
    
    func FillPolygon(image: NSBitmapImageRep, isAA: Bool){
        let vertices = OrderingVertices(edges: self.edges)
        
        var verticesIndexes: [(Point, Int)] = []
        
        var index = 0
        for vertex in vertices {
            verticesIndexes.append((vertex, index))
            index = index + 1
        }
        
        let indices = verticesIndexes.sorted { lhs, rhs in
            lhs.0.compareY(point: rhs.0)
        }.map(\.1)
        
        
        var AET: [(Int, Double, Double, Int)] = []
        
        var k=0
        var i = indices[k]
        var y =  vertices[indices[0]].y
        let ymin = vertices[indices[0]].y
        let minVertex = vertices.min {$0.compareX(point: $1)}
        
        guard let xmin = minVertex?.x else {
            return
        }
        let indicesCount = indices.count - 1
        let ymax = vertices[indices[indicesCount]].y
        
        while  y < ymax  {
            while vertices[i].y == y {
                let previousIndex = (i-1)%%vertices.count
                let nextIndex = (i+1)%%vertices.count
                if vertices[previousIndex].y > vertices[i].y {
                    AETUpdate(AET: &AET, currentPoint: vertices[i], point: vertices[previousIndex], dy: vertices[previousIndex].y - vertices[i].y)
                }
                if vertices[nextIndex].y > vertices[i].y {
                    AETUpdate(AET: &AET, currentPoint: vertices[i], point: vertices[nextIndex], dy: vertices[i].y - vertices[nextIndex].y)
                    
                }
                k = k+1
                i = indices[k]
            }
            
            AET.sort { lhs, rhs in
                lhs.1 < rhs.1
            }
            
            
            
            
            if self.isNormalFillingMode {
                let intersectionsPairs = stride(from: 0, to: AET.count - 1, by: 2).map {
                    (AET[$0], AET[$0+1])
                }
                for pair in intersectionsPairs {
                    
                    if y != ymin{
                        for x in Int(pair.0.1)..<Int(pair.1.1) {
                            if self.fillingColor != .clear{
                                FillingWithColor(point: Point(x: x, y: y), image: image, isAA: isAA)
                            } else if self.fillingImage != nil {
                                FillingWithImage(point: Point(x: x, y: y), image: image, isAA: isAA, xmin:xmin, ymin:ymin)
                            } else if self.isLineargradient == false && self.gradientPoints.count == 2 && self.gradientColor1 != .clear && self.gradientColor2 != .clear{
                                FillingWithRadialGradient(point: Point(x: x, y: y), image: image, isAA: isAA)
                            } else if self.isLineargradient == true && self.gradientPoints.count == 2 && self.gradientColor1 != .clear && self.gradientColor2 != .clear {
                                FillingWithLinearGradient(point: Point(x: x, y: y), image: image, isAA: isAA)
                            }
                        }
                        
                    }
                }
            } else if self.isNormalFillingMode == false {
                var j = 0
                var counter = 0
                var x = Int(AET[0].1.rounded())
                
                while x < Int(AET[AET.count - 1].1.rounded()) {
                    while x == Int(AET[j].1.rounded()) {
                        if AET[j].3 < 0 {
                            
                            counter = counter - 1
                            
                        } else {
                            
                            counter = counter + 1
                            
                        }
                        j = j + 1
                    }
                    if counter != 0 {
                        if self.fillingColor != .clear{
                            FillingWithColor(point: Point(x: Int(x), y: y), image: image, isAA: isAA)
                        } else if self.fillingImage != nil {
                            FillingWithImage(point: Point(x: Int(x), y: y), image: image, isAA: isAA, xmin:xmin, ymin:ymin)
                        } else if self.isLineargradient == false && self.gradientPoints.count == 2 && self.gradientColor1 != .clear && self.gradientColor2 != .clear{
                            FillingWithRadialGradient(point: Point(x: Int(x), y: y), image: image, isAA: isAA)
                        } else if self.isLineargradient == true && self.gradientPoints.count == 2 && self.gradientColor1 != .clear && self.gradientColor2 != .clear {
                            FillingWithLinearGradient(point: Point(x: Int(x), y: y), image: image, isAA: isAA)
                        }
                    }
                    x = x + 1
                }
                
            }
            
            y = y + 1
            
            AET.removeAll { (y_max, x, inverse, dy) in
                y_max == y
            }
            
            for i in 0..<AET.count{
                if AET[i].2 != 0 {
                    AET[i].1 = AET[i].1 + Double(1/AET[i].2)
                }
            }
            
        }
        
    }
    
    func FillingWithColor(point: Point, image: NSBitmapImageRep, isAA: Bool) {
        var pixelsRGBA: [Int] = [0, 0, 0, 255]
        let red = Int(255*self.fillingColor.redComponent)
        let blue = Int(255*self.fillingColor.blueComponent)
        let green = Int(255*self.fillingColor.greenComponent)
        pixelsRGBA = [red,green,blue, 255]
        image.setPixel(&pixelsRGBA, atX: point.x, y: point.y)
    }
    
    func FillingWithImage(point: Point, image: NSBitmapImageRep, isAA: Bool, xmin: Int, ymin: Int) {
        
        
        var pixelsRGBA: [Int] = [0, 0, 0, 255]
        fillingImage!.getPixel(&pixelsRGBA, atX: (point.x-xmin)%fillingImage!.pixelsWide, y: (point.y-ymin)%fillingImage!.pixelsHigh)
        image.setPixel(&pixelsRGBA, atX: point.x, y: point.y)
        
    }
    
    func FillingWithRadialGradient(point: Point, image: NSBitmapImageRep, isAA: Bool) {
        
        var pixelsRGBA: [Int] = [0, 0, 0, 255]
        
        let diff1 = Point(x: point.x - self.gradientPoints[0].x, y: point.y - self.gradientPoints[0].y)
        let diff2 = Point(x: self.gradientPoints[1].x - self.gradientPoints[0].x, y: self.gradientPoints[1].y - self.gradientPoints[0].y )
        let t = min(sqrt(Double(diff1.x*diff1.x+diff1.y*diff1.y))/sqrt(Double(diff2.x*diff2.x+diff2.y*diff2.y)), 1)
        let red = Int(255*(self.gradientColor1.redComponent * (1 - t) + self.gradientColor2.redComponent*t))
        let blue = Int(255*(self.gradientColor1.blueComponent * (1 - t) + self.gradientColor2.blueComponent*t))
        let green = Int(255*(self.gradientColor1.greenComponent * (1 - t) + self.gradientColor2.greenComponent*t))
        pixelsRGBA = [red,green,blue, 255]
        image.setPixel(&pixelsRGBA, atX: point.x, y: point.y)
        
    }
    
    func FillingWithLinearGradient(point: Point, image: NSBitmapImageRep, isAA: Bool) {
        
        var pixelsRGBA: [Int] = [0, 0, 0, 255]
        let diff1 = VNVector(xComponent: Double(point.x - self.gradientPoints[0].x), yComponent: Double(point.y - self.gradientPoints[0].y))
        let diff2 = VNVector(xComponent: Double(self.gradientPoints[1].x - self.gradientPoints[0].x), yComponent: Double(self.gradientPoints[1].y - self.gradientPoints[0].y))
        
        let dotProduct = VNVector.dotProduct(of: diff1, vector: diff2)
        var t = dotProduct/Double(diff2.x*diff2.x+diff2.y*diff2.y)
        if t < 0.1 {
            t = 0.1
        } else if t > 1 {
            t = 1
        }
        let red = Int(255*(self.gradientColor1.redComponent * (1 - t) + self.gradientColor2.redComponent*t))
        let blue = Int(255*(self.gradientColor1.blueComponent * (1 - t) + self.gradientColor2.blueComponent*t))
        let green = Int(255*(self.gradientColor1.greenComponent * (1 - t) + self.gradientColor2.greenComponent*t))
        pixelsRGBA = [red,green,blue, 255]
        image.setPixel(&pixelsRGBA, atX: point.x, y: point.y)
        
    }
}
