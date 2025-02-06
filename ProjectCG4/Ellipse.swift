//
//  Ellipse.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 17/04/2023.
//

import Foundation
import AppKit

struct Ellipse: Shape{
    
    @CodableColor
    var color: NSColor
    
    @CodableColor
    var fillingColor: NSColor = .clear
    
    @CodableBitmap
    var fillingImage: NSBitmapImageRep? = nil
    
    @CodableColor
    var gradientColor1: NSColor = .clear
    @CodableColor
    var gradientColor2: NSColor = .clear
    
    var thickness: Int
    
    var centerPoint: Point
    
    var bRadius: Float
    var aRadius: Float
    
    init(color: NSColor = NSColor.black, thickness: Int = 1, centerPoint: Point, bPoint: Point, aPoint: Point) {
        self.color = color
        self.thickness = thickness
        self.centerPoint = centerPoint
        self.bRadius = sqrt(Float((bPoint.x - centerPoint.x)*(bPoint.x - centerPoint.x)) + Float(((bPoint.y - centerPoint.y)*(bPoint.y - centerPoint.y))))
        self.aRadius = sqrt(Float((aPoint.x - centerPoint.x)*(aPoint.x - centerPoint.x)) + Float(((aPoint.y - centerPoint.y)*(aPoint.y - centerPoint.y))))
    }
    
    
    mutating func Modify(distanceX: Int, distanceY: Int, startingPoint: Point) {
        var multiplier = 1.0 as Float
        if startingPoint.x < centerPoint.x {
            multiplier = -1
        } else {
            multiplier = 1
        }
        self.aRadius += multiplier * Float(distanceX)
        if startingPoint.y < centerPoint.y {
            multiplier = -1
        } else {
            multiplier = 1
        }
        self.bRadius += multiplier * Float(distanceY)
    }
    
    
    
    mutating func Move(distanceX: Int, distanceY: Int) {
        self.centerPoint.x += distanceX
        self.centerPoint.y += distanceY
    }
    
    
    func Selected(point: Point) -> Bool {
        let a = Int(self.aRadius)
        let b = Int(self.bRadius)
        
        let distanceCenterToPoint = sqrt(Float((centerPoint.x - point.x)*(centerPoint.x - point.x)) + Float(((centerPoint.y - point.y)*(centerPoint.y - point.y))))
        
        let theta = atan2(Double(point.y - centerPoint.y), Double(point.x - centerPoint.x))
        
        let phi = atan2(Double(a) * sin(theta), Double(b) * cos(theta))
        let part1 = Float(a * a) * Float(cos(phi)) * Float(cos(phi))
        let part2 =  Float(b * b) * Float(sin(phi)) * Float(sin(phi))
        
        let distanceCenterToEllipse = sqrt(Float(part1 + part2))
        let distanceFromEllipseToPoint = Int((distanceCenterToPoint - distanceCenterToEllipse).magnitude)
        
        if (-10...10).contains(distanceFromEllipseToPoint) {
            return true
        } else {
            return false
        }
    }
    
    func Draw(image: NSBitmapImageRep, isAA: Bool) {
        var x = 0
        var y = Int(self.bRadius)
        let a = Int(self.aRadius)
        let  b = Int(self.bRadius)
        
        var d = 4 * b * b - 4 * a * a * b + a * a
        
        var dx = 2 * b * b * x;
        var dy = 2 * a * a * y;
        
        let color = self.color.usingColorSpace(.deviceRGB) ?? self.color
        var pixelColor: [Int] = [Int(color.redComponent*255), Int(color.greenComponent*255), Int(color.blueComponent*255), Int(color.alphaComponent*255)]
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x + x, y: self.centerPoint.y + y)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x + x, y: self.centerPoint.y - y)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y + y)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y - y)
        
        while (dy >= dx)
        {
            x = x + 1
            if ( d < 0 ) //move to E
            {
                d += 4 * (2 * b * b * x + b * b)
                dx = 2 * b * b * x
            }
            else //move to SE
            {
                
                y = y - 1
                d += 4 * (2 * b * b * x - 2 * a * a * y + b * b)
                dx = 2 * b * b * x
                dy = 2 * a * a * y
                
            }
            
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x + x, y: self.centerPoint.y + y)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x + x, y: self.centerPoint.y - y)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y + y)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y - y)
        }
        
        
        d += b * b * (-4 * x - 3) + a * a * (-4 * y + 3)
        
        while (y >= 0)
        {
            y = y - 1
            if ( d < 0 ) //move to SE
            {
                
                x = x + 1
                d += 4 * (2 * b * b * x - 2 * a * a * y + a * a)
                
            }
            else //move to S
            {
                
                d += 4 * (-2 * a * a * y + a * a)
            }
            
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x + x, y: self.centerPoint.y + y)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x + x, y: self.centerPoint.y - y)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y + y)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y - y)
        }
        
        
        
        
    }
    
    
}

