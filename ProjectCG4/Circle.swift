//
//  Circle.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 16/04/2023.
//

import Foundation
import AppKit

struct Circle: Shape {
    
    @CodableColor
    var color: NSColor
    
    @CodableColor
    var fillingColor: NSColor = .clear
    
    @CodableColor
    var gradientColor1: NSColor = .clear
    
    @CodableColor
    var gradientColor2: NSColor = .clear
    
    var thickness: Int
    
    var centerPoint: Point
    
    var radius: Float
    
    @CodableBitmap
    var fillingImage: NSBitmapImageRep? = nil
    
    init(color: NSColor = NSColor.black, thickness: Int = 1, centerPoint: Point, circlePoint: Point) {
        self.color = color
        self.thickness = thickness
        self.centerPoint = centerPoint
        
        self.radius = sqrt(Float((circlePoint.x - centerPoint.x)*(circlePoint.x - centerPoint.x)) + Float(((circlePoint.y - centerPoint.y)*(circlePoint.y - centerPoint.y))))
    }
    
    
    mutating func Modify(distanceX: Int, distanceY: Int, startingPoint: Point) {
        var multiplier = 1.0 as Float
        if distanceX.magnitude >= distanceY.magnitude {
            if startingPoint.x < centerPoint.x {
                if distanceX < 0 {
                    multiplier = 1
                } else {
                    multiplier = -1
                }
            } else {
                if distanceX > 0 {
                    multiplier = 1
                } else {
                    multiplier = -1
                }
            }
        } else {
            if startingPoint.y < centerPoint.y {
                if distanceY < 0 {
                    multiplier = 1
                } else {
                    multiplier = -1
                }
            } else {
                if distanceY > 0 {
                    multiplier = 1
                } else {
                    multiplier = -1
                }
            }
        }
        
        self.radius += multiplier * sqrt(Float(distanceX * distanceX) + Float(distanceY * distanceY))
        
        if self.radius < 0 {
            self.radius = 1
        }
    }
    
    
    mutating func Move(distanceX: Int, distanceY: Int) {
        self.centerPoint.x += distanceX
        self.centerPoint.y += distanceY
    }
    
    
    
    
    func Selected(point: Point) -> Bool {
        let delta = sqrt(Float((centerPoint.x - point.x)*(centerPoint.x - point.x)) + Float(((centerPoint.y - point.y)*(centerPoint.y - point.y))))
        
        if ((Int(self.radius) - 10)...(Int(self.radius) + 10)).contains(Int(delta)) {
            return true
        } else {
            return false
        }
        
    }
    
    
    func Draw(image: NSBitmapImageRep, isAA: Bool) {
        var d = 1-Int(self.radius)
        var x = 0
        var y = Int(self.radius)
        let color = self.color.usingColorSpace(.deviceRGB) ?? self.color
        
        var pixelColor: [Int] = [Int(color.redComponent*255), Int(color.greenComponent*255), Int(color.blueComponent*255), Int(color.alphaComponent*255)]
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x + x, y: self.centerPoint.y - y)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x + y, y: self.centerPoint.y - x)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x + y , y: self.centerPoint.y + x)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x + x , y: self.centerPoint.y + y)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y + y)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x - y , y: self.centerPoint.y + x)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x - y , y: self.centerPoint.y - x)
        
        image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y - y)
        
        while (y >= x)
        {
            if ( d < 0 ) //move to E
            {
                d += 2 * x + 3
            }
            else //move to SE
            {
                
                d += 2*x-2*y+5
                y = y - 1
            }
            x = x + 1
            
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x + x, y: self.centerPoint.y - y)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x + y, y: self.centerPoint.y - x)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x + y , y: self.centerPoint.y + x)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x + x , y: self.centerPoint.y + y)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y + y)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x - y , y: self.centerPoint.y + x)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x - y , y: self.centerPoint.y - x)
            
            image.setPixel(&pixelColor, atX: self.centerPoint.x - x , y: self.centerPoint.y - y)
            
            
            
            
            
        }
    }
    
    
}
