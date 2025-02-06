//
//  ViewController.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 13/04/2023.
//

import AppKit

class ViewController: NSViewController {
    var points: [Point] = []
    var polygonEdges: [Line] = []
    var rectangleEdges: [Line] = []
    var selectedShape: Int?
    var currentPoint: Point?
    var clippingSHShapes: [Int] = []
    var gradientPoints: [Point] = []
    var gradientColor1: NSColor = .blue
    var gradientColor2: NSColor = .blue
    
    var draggedShape: Shape?
        
    var document: Document?{
        self.view.window?.windowController?.document as? Document
    }
    var windowController: WindowController?{
        self.view.window?.windowController as? WindowController
    }
    
    var isLineSegmentSelected: Bool {
        self.windowController?.toolBox.isSelected(forSegment: 0) == true
    }
    var isCircleSegmentSelected: Bool {
        self.windowController?.toolBox.isSelected(forSegment: 1) == true
    }
    var isPolygonSegmentSelected: Bool {
        self.windowController?.toolBox.isSelected(forSegment: 2) == true
    }
    var isEllipseSegmentSelected: Bool {
        self.windowController?.toolBox.isSelected(forSegment: 3) == true
    }
    var isRectangleSegmentSelected: Bool {
        self.windowController?.toolBox.isSelected(forSegment: 4) == true
    }
    var isModificationSegmentSelected: Bool {
        self.windowController?.toolBox.isSelected(forSegment: 5) == true
    }
    
    var isLinearGradientSelected: Bool {
        get {
            self.windowController?.gradientToolbox.isSelected(forSegment: 0) == true
        } set {
            self.windowController?.gradientToolbox.setSelected(newValue, forSegment: 0)
        }
    }
    var isRadialGradientSelected: Bool {
        get {
            self.windowController?.gradientToolbox.isSelected(forSegment: 1) == true
        } set {
            self.windowController?.gradientToolbox.setSelected(newValue, forSegment: 1)
        }
    }
    
    var isNormalFillingMode: Bool {
        get {
            self.windowController?.fillingModeSegmentedControl.isSelected(forSegment: 0) == true
        } set {
            if newValue {
                self.windowController?.fillingModeSegmentedControl.setSelected(true, forSegment: 0)
                self.windowController?.fillingModeSegmentedControl.setSelected(false, forSegment: 1)
            } else {
                self.windowController?.fillingModeSegmentedControl.setSelected(true, forSegment: 1)
                self.windowController?.fillingModeSegmentedControl.setSelected(false, forSegment: 0)
            }
        }
    }
    
    @IBOutlet weak var ImageView: NSImageView!
    
    override var representedObject: Any? {
        didSet {
            updateLayout()
        }
    }
    
    func drawBitmap() {
        let pixelsWide = ImageView.frame.size.width*(view.window?.backingScaleFactor ?? 1.0)
        let pixelsHigh = ImageView.frame.size.height*(view.window?.backingScaleFactor ?? 1.0)
        
        let bitmapImage = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(pixelsWide), pixelsHigh: Int(pixelsHigh), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 4 * Int(pixelsWide), bitsPerPixel: 32)
        bitmapImage?.fill(with: NSColor.white)
        document?.canvas = bitmapImage
    }
    
    func drawShapes() {
        guard let canvas = document?.canvas else {
            return
        }
        for shape in document?.shapes ?? []{
            shape.Draw(image: canvas, isAA: windowController?.aa.state == .on)
        }
    }
    
    func updateLayout() {
        drawBitmap()
        drawShapes()
        guard let canvas = document?.canvas else {
            return
        }
        ImageView.image = NSImage(cgImage: canvas.cgImage!, size: ImageView.frame.size)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        points = []
        polygonEdges = []
        rectangleEdges = []
        updateLayout()
    }
    
    // ACTIONS
    
    func changeColor(for selectedIndex: Int, newColor color: NSColor) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        let oldColor = document.shapes[selectedIndex].color
        
        document.shapes[selectedIndex].color = color
        updateLayout()
        
        document.undoManager?.registerUndo(withTarget: self, handler: { controller in
            controller.changeColor(for: selectedIndex, newColor: oldColor)
        })
    }

    func changeThickness(for selectedIndex: Int, newThickness thickness: Int) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        if document.shapes[selectedIndex] is Line || document.shapes[selectedIndex] is Polygon ||
            document.shapes[selectedIndex] is Rectangle
            
        {
            let oldThickness = document.shapes[selectedIndex].thickness
            document.shapes[selectedIndex].thickness = thickness
            
            updateLayout()
            
            document.undoManager?.registerUndo(withTarget: self, handler: { controller in
                controller.changeThickness(for: selectedIndex, newThickness: oldThickness)
            })
        }
    }
    
    func changeFillingMode(for selectedIndex: Int, normalFillingMode: Bool) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        if var polygonRectangle = document.shapes[selectedIndex] as? CommonPolygonRectangle
        {
            let oldFillingMode = polygonRectangle.isNormalFillingMode
            polygonRectangle.isNormalFillingMode = normalFillingMode
            
            document.shapes[selectedIndex] = polygonRectangle
            updateLayout()
            
            document.undoManager?.registerUndo(withTarget: self, handler: { controller in
                controller.changeFillingMode(for: selectedIndex, normalFillingMode: oldFillingMode)
            })
        }
    }
    
    func changeFillingColor(for selectedIndex: Int, newColor color: NSColor, normalFillingMode: Bool = true) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        if var polygonRectangle = document.shapes[selectedIndex] as? CommonPolygonRectangle
        {
            let oldShape = polygonRectangle
            
            polygonRectangle.isNormalFillingMode = normalFillingMode
            polygonRectangle.gradientColor1 = .clear
            polygonRectangle.gradientColor2 = .clear
            polygonRectangle.fillingImage = nil
            polygonRectangle.fillingColor = color
            
            document.shapes[selectedIndex] = polygonRectangle
            
            updateLayout()
            
            document.undoManager?.registerUndo(withTarget: self, handler: { controller in
                controller.changeShape(at: selectedIndex, newShape: oldShape)
            })
        }
    }
    
    func changeFillingImage(for selectedIndex: Int, newImage: NSBitmapImageRep?, normalFillingMode: Bool = true) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        if var polygonRectangle = document.shapes[selectedIndex] as? CommonPolygonRectangle
        {
            let oldShape = polygonRectangle
            
            polygonRectangle.isNormalFillingMode = normalFillingMode
            polygonRectangle.fillingColor = .clear
            polygonRectangle.gradientColor1 = .clear
            polygonRectangle.gradientColor2 = .clear
            polygonRectangle.fillingColor = .clear
            polygonRectangle.fillingImage = newImage
            
            document.shapes[selectedIndex] = polygonRectangle
            updateLayout()
            
            document.undoManager?.registerUndo(withTarget: self, handler: { controller in
                controller.changeShape(at: selectedIndex, newShape: oldShape)
            })
        }
    }
    
    func changeGradientColor1(for selectedIndex: Int, newColor color: NSColor) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        if document.shapes[selectedIndex] is CommonPolygonRectangle
        {
            let oldColor = document.shapes[selectedIndex].gradientColor1 ?? .clear
            document.shapes[selectedIndex].gradientColor1 = color
            updateLayout()
            document.undoManager?.registerUndo(withTarget: self, handler: { controller in
                controller.changeGradientColor1(for: selectedIndex, newColor: oldColor)
            })
        }
    }
    
    func changeGradientColor2(for selectedIndex: Int, newColor color: NSColor) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        if document.shapes[selectedIndex] is CommonPolygonRectangle
        {
            let oldColor = document.shapes[selectedIndex].gradientColor2
            document.shapes[selectedIndex].gradientColor2 = color
            updateLayout()
            document.undoManager?.registerUndo(withTarget: self, handler: { controller in
                controller.changeGradientColor2(for: selectedIndex, newColor: oldColor)
            })
        }
    }

    func changeGradientPoints(for selectedIndex: Int, gradientPoints: [Point]) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        guard var polygonRectangle = document.shapes[selectedIndex] as? CommonPolygonRectangle else { return }
        
        let oldShape = polygonRectangle
        
        if !isNormalFillingMode {
            polygonRectangle.isNormalFillingMode = false
        } else if isNormalFillingMode {
            polygonRectangle.isNormalFillingMode = true
        }
        
        polygonRectangle.gradientPoints = gradientPoints
        
        if isLinearGradientSelected {
            polygonRectangle.isLineargradient = true
        } else if isRadialGradientSelected {
            polygonRectangle.isLineargradient = false
        }
        
        polygonRectangle.gradientColor1 = gradientColor1
        polygonRectangle.gradientColor2 = gradientColor2
        
        polygonRectangle.fillingColor = .clear
        polygonRectangle.fillingImage = nil
        
        document.shapes[selectedIndex] = polygonRectangle
        isLinearGradientSelected = false
        isRadialGradientSelected = false
        
        updateLayout()
        document.undoManager?.registerUndo(withTarget: self, handler: { controller in
            controller.changeShape(at: selectedIndex, newShape: oldShape)
        })
    }
    
    func changeShape(at selectedIndex: Int, newShape: Shape) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        let oldShape = document.shapes[selectedIndex]
        
        document.shapes[selectedIndex] = newShape
        updateLayout()
        
        document.undoManager?.registerUndo(withTarget: self, handler: { controller in
            controller.changeShape(at: selectedIndex, newShape: oldShape)
        })
    }
    
    func removeShape(at selectedIndex: Int) {
        guard let document = document, selectedIndex < document.shapes.endIndex else { return }
        let shape = document.shapes.remove(at: selectedIndex)
        updateLayout()
        
        selectedShape = nil
        
        document.undoManager?.registerUndo(withTarget: self, handler: { controller in
            controller.document?.shapes.insert(shape, at: selectedIndex)
            controller.updateLayout()
            controller.selectedShape = selectedIndex
            
            controller.document?.undoManager?.registerUndo(withTarget: controller, handler: { controller in
                controller.removeShape(at: selectedIndex)
            })
        })
    }
    
    func addShape(shape: Shape) {
        guard let document = document else { return }
        document.shapes.append(shape)
        let selectedIndex = document.shapes.endIndex - 1

        updateLayout()
        
        document.undoManager?.registerUndo(withTarget: self, handler: { controller in
            controller.removeShape(at: selectedIndex)
        })
    }
    
    func clipShape(clipPolygonIndex: Int, subjectPolygonIndex: Int) {
        guard let document = document, clipPolygonIndex < document.shapes.endIndex, subjectPolygonIndex < document.shapes.endIndex else { return }
        guard let clipPolygon = document.shapes[clipPolygonIndex] as? CommonPolygonRectangle,
              let subjectPolygon = document.shapes[subjectPolygonIndex] as? CommonPolygonRectangle else { return }
        
        let newEdges = subjectPolygon.ClippingSutherlandHodgman(clipPolygonEdges: clipPolygon.edges)
        
        var newPolygon = Polygon(color: subjectPolygon.color, thickness: subjectPolygon.thickness)
        newPolygon.edges = newEdges
        newPolygon.fillingColor = subjectPolygon.fillingColor
        newPolygon.fillingImage = subjectPolygon.fillingImage
        newPolygon.gradientColor1 = subjectPolygon.gradientColor1
        newPolygon.gradientColor2 = subjectPolygon.gradientColor2
        
        document.shapes[subjectPolygonIndex] = newPolygon
        
        updateLayout()
        
        document.undoManager?.registerUndo(withTarget: self, handler: { controller in
            controller.document?.shapes[subjectPolygonIndex] = subjectPolygon
            
            controller.updateLayout()
            
            controller.document?.undoManager?.registerUndo(withTarget: controller, handler: { controller in
                controller.clipShape(clipPolygonIndex: clipPolygonIndex, subjectPolygonIndex: subjectPolygonIndex)
            })
        })
    }
}

// ADDING SHAPE

extension NSImageView {
    open override func mouseDown(with event: NSEvent) {
        guard let controller = self.parentViewController as? ViewController else {
            return super.mouseDown(with: event)
        }
        
        let point = self.convert(event.locationInWindow, from: nil)
        let convertedPoint = Point(x: Int(point.x)*Int(controller.view.window!.backingScaleFactor), y: (Int(self.frame.height)-Int(point.y))*Int(controller.view.window!.backingScaleFactor))
        
        if !controller.isModificationSegmentSelected
        {
            controller.windowController?.move.state = .off
            controller.windowController?.modify.state = .off
            controller.points.append(convertedPoint)
        }
        
        controller.currentPoint = convertedPoint
        
        if let selectedIndex = controller.selectedShape {
            guard selectedIndex < controller.document?.shapes.endIndex ?? 0 else { return }
        }
        
        if controller.isLineSegmentSelected
        {
            
            if controller.points.count == 2
            {
                guard controller.points[0] != controller.points[1] else {
                    controller.points = []
                    return
                }
                
                let line = Line(startPoint: controller.points[0], endPoint: controller.points[1])
                controller.points = []

                controller.addShape(shape: line)
            }
        } else if controller.isPolygonSegmentSelected {
            let index = controller.points.count - 2
            if controller.points.count >= 2 {
                
                guard controller.points[0] != controller.points[1] else {
                    controller.points.removeLast()
                    return
                }
                
                if !(((controller.points[0].x - 10)...(controller.points[0].x + 10)).contains(convertedPoint.x) && ((controller.points[0].y - 10)...(controller.points[0].y + 10)).contains(convertedPoint.y)) {
                    
                    
                    let line = Line(startPoint: controller.points[index], endPoint: controller.points[index+1])
                    controller.polygonEdges.append(line)
                    line.Draw(image: (controller.document?.canvas)!, isAA: controller.windowController?.aa.state == .on)
                    self.image = NSImage(cgImage: (controller.document?.canvas)!.cgImage!, size: self.frame.size )
                    
                } else if (((controller.points[0].x - 10)...(controller.points[0].x + 10)).contains(convertedPoint.x) && ((controller.points[0].y - 10)...(controller.points[0].y + 10)).contains(convertedPoint.y)) && controller.points.count == 3 {
                    controller.points.removeLast()
                    
                } else {
                    let line = Line(startPoint: controller.points[index], endPoint: controller.points[0])
                    controller.polygonEdges.append(line)

                    var polygon = Polygon()
                    for polygonEdge in controller.polygonEdges {
                        polygon.edges.append(polygonEdge)
                    }

                    controller.points = []
                    controller.polygonEdges = []
                    
                    controller.addShape(shape: polygon)
                }
            }
        } else if controller.isCircleSegmentSelected {
            if controller.points.count == 2
            {
                guard controller.points[0] != controller.points[1] else {
                    controller.points = []
                    return
                }
                
                let circle = Circle(centerPoint: controller.points[0], circlePoint: controller.points[1])
                controller.points = []
                
                controller.addShape(shape: circle)
            }
        } else if controller.isEllipseSegmentSelected {
            
            if controller.points.count == 3
            {
                guard controller.points[0] != controller.points[1] else {
                    controller.points = []
                    return
                }
                
                let ellipse = Ellipse(centerPoint: controller.points[1], bPoint: controller.points[0], aPoint: controller.points[2])
                controller.points = []

                controller.addShape(shape: ellipse)
            }
            
        } else if controller.isModificationSegmentSelected {
            var selectedIndex: Int?
            if (controller.isLinearGradientSelected || controller.isRadialGradientSelected) && controller.selectedShape != nil && controller.document?.shapes[controller.selectedShape!] is CommonPolygonRectangle && (controller.gradientPoints.count == 0 || controller.gradientPoints.count == 1) {
                
                controller.gradientPoints.append(convertedPoint)
                
                if controller.gradientPoints.count == 2 {
                    controller.changeGradientPoints(for: controller.selectedShape!, gradientPoints: controller.gradientPoints)
                    controller.gradientPoints = []
                }
            } else {
                for (index, shape) in (controller.document?.shapes ?? []).enumerated() {
                    if shape.Selected(point: convertedPoint) {
                        selectedIndex = index
                        
                        if let selectedShape = shape as? CommonPolygonRectangle {
                            if controller.clippingSHShapes.count == 0 && selectedShape.isConvex {
                                controller.clippingSHShapes.append(index)
                            } else if controller.clippingSHShapes.count == 1 && !controller.clippingSHShapes.contains(index){
                                controller.clippingSHShapes.append(index)
                                controller.windowController?.clippingSH.isEnabled = true
                                
                            } else if controller.clippingSHShapes.count == 2 {
                                controller.windowController?.clippingSH.isEnabled = false
                                controller.clippingSHShapes = []
                            }
                        } else {
                            controller.clippingSHShapes = []
                        }
                    }
                }
                controller.selectedShape = selectedIndex
            }
            
            
        } else if controller.isRectangleSegmentSelected {
            
            if controller.points.count == 2
            {
                guard controller.points[0] != controller.points[1] else {
                    controller.points = []
                    return
                }
                if controller.points[0].x == controller.points[1].x || controller.points[0].y == controller.points[1].y {
                    let line = Line(startPoint: controller.points[0], endPoint: controller.points[1])
                    controller.points = []
                    controller.rectangleEdges = []
                    
                    controller.addShape(shape: line)
                    
                } else {
                    let rectangle = controller.constructRectangleFromRecordedPoints()
                    controller.addShape(shape: rectangle)
                }
                
            }
            
        }
        
    }
    
    open override func mouseDragged(with event: NSEvent) {
        guard let controller = self.parentViewController as? ViewController else {
            return super.mouseDragged(with: event)
        }
        
        let p = self.convert(event.locationInWindow, from: nil)
        let draggedPoint = Point(x: Int(p.x)*Int(controller.view.window!.backingScaleFactor), y: (Int(self.frame.height)-Int(p.y))*Int(controller.view.window!.backingScaleFactor))
        
        guard let point = controller.currentPoint, let selectedShape = controller.selectedShape else {
            return
        }
        
        if controller.draggedShape == nil, selectedShape < (controller.document?.shapes.endIndex ?? 0) {
            controller.draggedShape = controller.document?.shapes[selectedShape]
        }
        
        if controller.isModificationSegmentSelected && controller.windowController?.move.state == .on {
            
            controller.document?.shapes[selectedShape].Move(distanceX: draggedPoint.x - point.x, distanceY: draggedPoint.y - point.y)
            
        } else if controller.isModificationSegmentSelected && controller.windowController?.modify.state == .on {
            
            controller.document?.shapes[selectedShape].Modify(distanceX: draggedPoint.x - point.x, distanceY: draggedPoint.y - point.y, startingPoint: point)
        } else {
            return
        }
        
        controller.currentPoint = draggedPoint
        controller.updateLayout()
    }
    
    open override func mouseUp(with event: NSEvent) {
        guard let controller = self.parentViewController as? ViewController else {
            return super.mouseUp(with: event)
        }
        guard let _ = controller.currentPoint, let selectedShape = controller.selectedShape else {
            return
        }
        
        if let oldShape = controller.draggedShape {
            controller.document?.undoManager?.registerUndo(withTarget: controller, handler: { controller in
                controller.changeShape(at: selectedShape, newShape: oldShape)
            })
        }
        
        controller.draggedShape = nil
    }
}

extension ViewController {
    func constructRectangleFromRecordedPoints() -> Rectangle {
        let line1 = Line(startPoint: points[0], endPoint: Point(x: points[1].x, y: points[0].y))
        let line2 = Line(startPoint:Point(x: points[1].x, y: points[0].y), endPoint: points[1])
        let line3 = Line(startPoint: points[1], endPoint: Point(x: points[0].x, y: points[1].y))
        let line4 = Line(startPoint: Point(x: points[0].x, y: points[1].y), endPoint: points[0])
        rectangleEdges.append(line1)
        rectangleEdges.append(line2)
        rectangleEdges.append(line3)
        rectangleEdges.append(line4)

        points = []
        
        var rectangle = Rectangle()
        for rectangleEdge in rectangleEdges {
            rectangle.rectangleEdges.append(rectangleEdge)
        }
        points = []
        rectangleEdges = []
        
        return rectangle
    }
}
