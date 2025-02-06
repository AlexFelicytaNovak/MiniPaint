//
//  Extensions.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 02/02/2025.
//

import AppKit

extension NSBitmapImageRep {
    func fill(with color: NSColor) {
        guard bitsPerPixel == 32 else { return }
        let color = color.usingColorSpace(self.colorSpace) ?? color
        
        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: self)
        NSGraphicsContext.current = context
        color.set()
        NSMakeRect(0, 0, CGFloat(pixelsWide), CGFloat(pixelsHigh)).fill()
        NSGraphicsContext.restoreGraphicsState()
    }
}

extension NSResponder {
    public var parentViewController: NSViewController? {
        return self.nextResponder as? NSViewController ?? self.nextResponder?.parentViewController
    }
}
