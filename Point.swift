//
//  Point.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 14/04/2023.
//

import Foundation
import AppKit

struct Point: CustomStringConvertible, Equatable, Codable, Hashable {
    
    var description: String{
        "(x: \(self.x), y: \(self.y))"
    }
    
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    func compareX(point: Point) -> Bool {
        // right->left to false
        if self.x > point.x {
            return false
        }
        //left->right to true
        return true
        
    }
    
    func compareY(point: Point) -> Bool {
        // top->bottom to false
        if self.y > point.y {
            return false
        }
        //bottom->top to true
        return true
        
    }
    
    func compare(point: Point) -> Bool {
        if self.x == point.x && self.y == point.y {
            return true
        }
        return false
    }
    
}
