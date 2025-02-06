//
//  Line.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 14/04/2023.
//

import Foundation
import AppKit

//Midpoint Algorithm
struct Line: Shape, CustomStringConvertible {
    
    @CodableColor
    var color = NSColor.black
    
    @CodableColor
    var gradientColor1: NSColor = .clear
    
    @CodableColor
    var gradientColor2: NSColor = .clear
    
    var thickness = 1
    
    @CodableColor
    var fillingColor: NSColor = .clear
    
    var startPoint: Point
    var endPoint: Point
    
    @CodableBitmap
    var fillingImage: NSBitmapImageRep? = nil
    
    init(color: NSColor = NSColor.black, thickness: Int = 1, startPoint: Point, endPoint: Point) {
        self.color = color
        self.thickness = thickness
        
        
        let dx = endPoint.x-startPoint.x
        let dy = endPoint.y-startPoint.y
        
        if Int(dx.magnitude) > Int(dy.magnitude){
            if startPoint.compareX(point: endPoint)
            {
                self.startPoint = startPoint
                self.endPoint = endPoint
            } else {
                self.startPoint = endPoint
                self.endPoint = startPoint
            }
        } else {
            if startPoint.compareY(point: endPoint)
            {
                self.startPoint = startPoint
                self.endPoint = endPoint
            } else {
                self.startPoint = endPoint
                self.endPoint = startPoint
            }
            
            
            
        }
        
        
    }
    
    mutating func Modify(distanceX: Int, distanceY: Int, startingPoint: Point) {
        if (self.startPoint.x - 20...self.startPoint.x + 20).contains(startingPoint.x) && (self.startPoint.y - 20...self.startPoint.y + 20).contains(startingPoint.y) {
            self.startPoint.x += distanceX
            self.startPoint.y += distanceY
            let dx = endPoint.x-startPoint.x
            let dy = endPoint.y-startPoint.y
            if Int(dx.magnitude) > Int(dy.magnitude) {
                if self.startPoint.x > self.endPoint.x {
                    let tmp = self.startPoint
                    self.startPoint = self.endPoint
                    self.endPoint = tmp
                }
            } else {
                if self.startPoint.y > self.endPoint.y {
                    let tmp = self.startPoint
                    self.startPoint = self.endPoint
                    self.endPoint = tmp
                }
            }
            
        } else if (self.endPoint.x - 20...self.endPoint.x + 20).contains(startingPoint.x) && (self.endPoint.y - 20...self.endPoint.y + 20).contains(startingPoint.y) {
            self.endPoint.x += distanceX
            self.endPoint.y += distanceY
            let dx = endPoint.x-startPoint.x
            let dy = endPoint.y-startPoint.y
            if Int(dx.magnitude) > Int(dy.magnitude) {
                if self.startPoint.x > self.endPoint.x {
                    let tmp = self.startPoint
                    self.startPoint = self.endPoint
                    self.endPoint = tmp
                }
            } else {
                if self.startPoint.y > self.endPoint.y {
                    let tmp = self.startPoint
                    self.startPoint = self.endPoint
                    self.endPoint = tmp
                }
            }
        } else {
            return
        }
    }
    
    
    mutating func Move(distanceX: Int, distanceY: Int) {
        self.startPoint.x += distanceX
        self.endPoint.x += distanceX
        self.startPoint.y += distanceY
        self.endPoint.y += distanceY
    }
    
    func Selected(point: Point) -> Bool {
        let A = self.startPoint.y - self.endPoint.y
        let B = self.endPoint.x - self.startPoint.x
        let C = self.startPoint.x * self.endPoint.y - self.startPoint.y  * self.endPoint.x
        let denominator = sqrt(Float(A * A + B * B))
        let nominator = (A * point.x + B * point.y + C).magnitude
        let d = Float(nominator)/denominator
        
        let startX = min(startPoint.x, endPoint.x)
        let endX = max(startPoint.x, endPoint.x)
        let startY = min(startPoint.y, endPoint.y)
        let endY = max(startPoint.y, endPoint.y)
        
        if (-10.0...10.0).contains(d), point.x >= startX-10, point.x <= endX+10, point.y >= startY-10, point.y <= endY+10 {
            return true
        }
        return false
        
    }
    
    
    var description: String{
        "(start: \(self.startPoint), end: \(self.endPoint))"
    }
    
    
    
    
    func Draw(image: NSBitmapImageRep, isAA: Bool) {
        if isAA == false {
            var dx = self.endPoint.x-self.startPoint.x
            var dy = self.endPoint.y-self.startPoint.y
            let color = self.color.usingColorSpace(.deviceRGB) ?? self.color
            var pixelColor: [Int] = [Int(color.redComponent*255), Int(color.greenComponent*255), Int(color.blueComponent*255), Int(color.alphaComponent*255)]
            
            //horizontal
            if Int(dx).magnitude > Int(dy).magnitude {
                var incrementDecrement = 1
                if self.startPoint.y > self.endPoint.y {
                    dy = Int(dy.magnitude)
                    incrementDecrement = -1
                }
                var d = 2*dy-dx
                let dE = 2*dy
                let dNE = 2*(dy-dx)
                var x = self.startPoint.x
                var y = self.startPoint.y
                
                image.setPixel(&pixelColor, atX: x, y: y)
                while (x < self.endPoint.x)
                {
                    if d < 0  // move to E
                    {
                        d += Int(dE);
                        x = x+1
                    }
                    else // move to NE
                    {
                        d += Int(dNE)
                        x = x + 1
                        y = y + incrementDecrement
                    }
                    
                    if self.thickness > 1 {
                        for index in -(self.thickness - 1)/2..<(self.thickness - 1)/2 {
                            image.setPixel(&pixelColor, atX: x, y: y + index)
                        }
                    } else {
                        image.setPixel(&pixelColor, atX: x, y: y)
                    }
                }
                
            } else {
                var incrementDecrement = 1
                
                dx = self.endPoint.y-self.startPoint.y
                dy = self.endPoint.x-self.startPoint.x
                if self.startPoint.x > self.endPoint.x {
                    dy = Int(dy.magnitude)
                    incrementDecrement = -1
                }
                
                var d = 2*dy-dx
                let dE = 2*dy
                let dNE = 2*(dy-dx)
                var x = self.startPoint.x
                var y = self.startPoint.y
                
                while (y < self.endPoint.y)
                {
                    if d < 0  // move to E
                    {
                        d += Int(dE);
                        y = y+1
                    }
                    else // move to NE
                    {
                        d += Int(dNE)
                        x = x + incrementDecrement
                        y = y + 1
                    }
                    
                    if self.thickness > 1 {
                        for index in -(self.thickness - 1)/2..<(self.thickness - 1)/2 {
                            image.setPixel(&pixelColor, atX: x + index, y: y)
                        }
                    }else {
                        image.setPixel(&pixelColor, atX: x, y: y)
                    }
                }
            }
        } else {
            self.AntialiasedLine(image: image)
        }
    }
    
    func cov(d: Float, r: Float) -> Float {
        if r >= d {
            return (Float(1)/Float.pi * Float(acos(d/r)) - (d/Float.pi * r * r) * sqrt(r * r - d * d))
        } else {
            return 0
        }
    }
    
    func coverage(D: Float, r: Float) -> Float{
        let w = Float(self.thickness)/2
        
        
        if w <= r {
            if (0...w).contains(D) {
                return (Float(1) - cov(d: w - D, r: r) - cov(d: w + D, r: r))
            } else if (D >= w && D <= (r - w)) {
                return (cov(d: w - D, r: r) - cov(d: w + D, r: r))
            } else if (D >= (r - w) && D <= (r + w)){
                return cov(d: D - w, r: r)
            }
        } else {
            if D >= w {
                return cov(d: D - w, r: r)
            } else if (0...w).contains(D) {
                return (Float(1) - cov(d: w - D, r: r))
            }
        }
        return 0
        
    }
    
    
    func IntensifyPixel(x: Int, y: Int, distance: Float, image: NSBitmapImageRep) -> Float
    {
        let r = Float(0.5)
        let cov = coverage(D: distance, r: r)
        var color = self.color.usingColorSpace(.deviceRGB) ?? self.color
        color = color.blended(withFraction: 1 - CGFloat(cov), of: NSColor.white) ?? color
        var pixelColor: [Int] = [Int(color.redComponent*255), Int(color.greenComponent*255), Int(color.blueComponent*255), Int(color.alphaComponent*255)]
        if cov > 0 {
            image.setPixel(&pixelColor, atX: x, y: y)
        }
        
        return cov
    }
    
    func AntialiasedLine(image: NSBitmapImageRep){
        var dx = self.endPoint.x-self.startPoint.x
        var dy = self.endPoint.y-self.startPoint.y
        //horizontal
        if Int(dx).magnitude > Int(dy).magnitude {
            var incrementDecrement = 1
            //czy w dol idzie czy w gore
            if self.startPoint.y > self.endPoint.y {
                dy = Int(dy.magnitude)
                incrementDecrement = -1
            }
            var d = 2*dy-dx
            let dE = 2*dy
            let dNE = 2*(dy-dx)
            
            var two_v_dx = Int(0)
            let invDenom = Float(1)/Float(2*sqrt(Float(dx * dx + dy * dy)))
            let two_dx_invDenom = Float(2 * Float(dx) * invDenom)
            var x = self.startPoint.x
            var y = self.startPoint.y
            
            _ = self.IntensifyPixel(x: x, y: y, distance: 0, image: image)
            
            var i = 1
            var j = 1
            
            while IntensifyPixel(x: x, y: y + i, distance: Float(i) * two_dx_invDenom, image: image) > 0 {
                i += 1
                
            }
            
            while IntensifyPixel(x: x, y: y - j, distance: Float(j) * two_dx_invDenom, image: image) > 0 {
                j += 1
            }
            while x < self.endPoint.x
            {
                x = x + 1
                if ( d < 0 ) // move to E
                {
                    two_v_dx = d + dx
                    d += dE
                }
                else // move to NE
                {
                    two_v_dx = d - dx
                    d += dNE
                    y = y + incrementDecrement
                }
                
                _ = IntensifyPixel(x: x, y: y, distance: 0, image: image)
                
                var i = 1
                var j = 1
                
                while IntensifyPixel(x: x, y: y + (i * incrementDecrement), distance: Float(i) * two_dx_invDenom - Float(two_v_dx) * invDenom, image: image) > 0 {
                    i += 1
                }
                
                while IntensifyPixel(x: x, y: y - (j*incrementDecrement), distance: Float(j) * two_dx_invDenom + Float(two_v_dx) * invDenom, image: image) > 0 {
                    j += 1
                }
            }
        } else {
            
            var incrementDecrement = 1
            
            dx = self.endPoint.y-self.startPoint.y
            dy = self.endPoint.x-self.startPoint.x
            if self.startPoint.x > self.endPoint.x {
                dy = Int(dy.magnitude)
                incrementDecrement = -1
            }
            
            var d = 2*dy-dx
            let dE = 2*dy
            let dNE = 2*(dy-dx)
            var two_v_dx = Int(0)
            let invDenom = Float(1)/Float(2*sqrt(Float(dx * dx + dy * dy)))
            let two_dx_invDenom = Float(2 * Float(dx) * invDenom)
            var x = self.startPoint.x
            var y = self.startPoint.y
            
            _ = self.IntensifyPixel(x: x, y: y, distance: 0, image: image)
            
            var i = 1
            var j = 1
            
            while IntensifyPixel(x: x + i, y: y, distance: Float(i) * two_dx_invDenom, image: image) > 0 {
                i += 1
                
            }
            
            while IntensifyPixel(x: x - j, y: y, distance: Float(j) * two_dx_invDenom, image: image) > 0 {
                j += 1
            }
            while (y < self.endPoint.y)
            {
                y = y + 1
                if d < 0  // move to E
                {
                    two_v_dx = d + dx
                    d += dE
                    
                }
                else // move to NE
                {
                    two_v_dx = d - dx
                    d += dNE
                    x = x + incrementDecrement
                    
                }
                
                _ = IntensifyPixel(x: x, y: y, distance: 0, image: image)
                
                var i = 1
                var j = 1
                
                while IntensifyPixel(x: x + (i * incrementDecrement), y: y, distance: Float(i) * two_dx_invDenom - Float(two_v_dx) * invDenom, image: image) > 0 {
                    i += 1
                }
                
                while IntensifyPixel(x: x - (j * incrementDecrement), y: y, distance: Float(j) * two_dx_invDenom + Float(two_v_dx) * invDenom, image: image) > 0 {
                    j += 1
                }
            }
            
        }
    }
}

