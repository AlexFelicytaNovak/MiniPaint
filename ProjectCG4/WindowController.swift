//
//  WindowController.swift
//  ProjectCG3
//
//  Created by Aleksandra Novák on 14/04/2023.
//

import Cocoa


class WindowController: NSWindowController, NSToolbarItemValidation{
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        return item.isEnabled
    }
    var controller: ViewController?{
        self.contentViewController as? ViewController
    }
    
    
    @IBOutlet weak var toolBox: NSSegmentedControl!
    
    @IBOutlet weak var gradientToolbox: NSSegmentedControl!
    @IBOutlet weak var gradientToolBoxItem: NSToolbarItem!
    
    @IBOutlet weak var fillingModeToolBarItem: NSToolbarItem!
    @IBOutlet weak var fillingModeSegmentedControl: NSSegmentedControl!
    
    @IBOutlet weak var colorOneGradient: NSToolbarItem!
    @IBOutlet weak var colorTwoGradient: NSToolbarItem!
    
    @IBOutlet weak var clippingSH: NSToolbarItem!
    @IBOutlet weak var clippingSHButton: NSButton!
    
    @IBOutlet weak var moveItem: NSToolbarItem!
    @IBOutlet weak var move: NSButton!
    
    @IBOutlet weak var colorChoice: NSToolbarItem!
    @IBOutlet weak var shapeColor: NSColorWell!
    
    @IBOutlet weak var fillingColor: NSToolbarItem!
    @IBOutlet weak var fillingImage: NSToolbarItem!
    
    @IBOutlet weak var thicknessChoice: NSToolbarItem!
    
    @IBOutlet weak var deleteShape: NSToolbarItem!
    
    @IBOutlet weak var modifyItem: NSToolbarItem!
    @IBOutlet weak var modify: NSButton!
    
    @IBOutlet weak var aa: NSButton!
    
    var previousState = -1
    
    
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(ChangeColor(_:)),
//                                               name: NSColorPanel.colorDidChangeNotification, object: nil)
        EditMode(toolBox)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func EditMode(_ sender: NSSegmentedControl) {
        move.state = .off
        modify.state = .off
        if sender.isSelected(forSegment: 5) {
            moveItem.isEnabled = true
            colorChoice.isEnabled = true
            thicknessChoice.isEnabled = true
            deleteShape.isEnabled = true
            modifyItem.isEnabled = true
            fillingColor.isEnabled = true
            fillingImage.isEnabled = true
            colorOneGradient.isEnabled = true
            colorTwoGradient.isEnabled = true
            gradientToolBoxItem.isEnabled = true
            fillingModeToolBarItem.isEnabled = true
        } else {
            moveItem.isEnabled = false
            colorChoice.isEnabled = false
            thicknessChoice.isEnabled = false
            deleteShape.isEnabled = false
            modifyItem.isEnabled = false
            fillingColor.isEnabled = false
            fillingImage.isEnabled = false
            clippingSH.isEnabled = false
            colorOneGradient.isEnabled = false
            colorTwoGradient.isEnabled = false
            gradientToolBoxItem.isEnabled = false
            fillingModeToolBarItem.isEnabled = false
        }
    }
    
    
    @IBAction func ShowColorsPanel(_ sender: NSColorWell) {
        move.state = .off
        modify.state = .off
        let color = sender.color
        
        if let selectedIndex = controller?.selectedShape {
            controller?.changeColor(for: selectedIndex, newColor: color)
        }
    }
    
    
    @IBAction func FillingColorChange(_ sender: NSColorWell) {
        move.state = .off
        modify.state = .off
        let color = sender.color
        
        if let selectedIndex = controller?.selectedShape {
            if fillingModeSegmentedControl.isSelected(forSegment: 1) {
                controller?.changeFillingColor(for: selectedIndex, newColor: color, normalFillingMode: false)
            } else if fillingModeSegmentedControl.isSelected(forSegment: 0) {
                controller?.changeFillingColor(for: selectedIndex, newColor: color, normalFillingMode: true)
            }
        }
    }
    
    @IBAction func fillingModeChange(_ sender: NSSegmentedControl) {
        if let selectedIndex = controller?.selectedShape {
            if fillingModeSegmentedControl.isSelected(forSegment: 1) {
                controller?.changeFillingMode(for: selectedIndex, normalFillingMode: false)
            } else if fillingModeSegmentedControl.isSelected(forSegment: 0) {
                controller?.changeFillingMode(for: selectedIndex, normalFillingMode: true)
            }
        }
    }
    
    
    @IBAction func ClippingSHChange(_ sender: NSButton) {
        move.state = .off
        modify.state = .off
        
        if let selectedForClipping = controller?.clippingSHShapes, selectedForClipping.count == 2 {
            controller?.clipShape(clipPolygonIndex: selectedForClipping[0], subjectPolygonIndex: selectedForClipping[1])
        }
        
        controller?.clippingSHShapes = []
        clippingSH.isEnabled = false
    }
    
    @IBAction func ColorOneChange(_ sender: NSColorWell) {
        
        move.state = .off
        modify.state = .off
        let color = sender.color
        
        controller?.gradientColor1 = color
        
        if let selectedIndex = controller?.selectedShape {
            controller?.changeGradientColor1(for: selectedIndex, newColor: color)
        }
    }
    
    
    
    @IBAction func ColorTwoChange(_ sender: NSColorWell) {
        move.state = .off
        modify.state = .off
        let color = sender.color
        
        controller?.gradientColor2 = color
        
        if let selectedIndex = controller?.selectedShape {
            controller?.changeGradientColor2(for: selectedIndex, newColor: color)
        }
    }
    
    
    @IBAction func GradientSegmentedControlChange(_ sender: NSSegmentedControl) {

        if sender.selectedSegment == previousState {
            sender.setSelected(false, forSegment: previousState)
        }

        previousState = sender.selectedSegment
    }
    
    
    @IBAction func ChangeThickness(_ sender: NSPopUpButton) {
        move.state = .off
        modify.state = .off
        guard let thickness = Int(sender.selectedItem?.title ?? "") else {
            return
        }
        
        if let selectedIndex = controller?.selectedShape, let controller = controller {
            controller.changeThickness(for: selectedIndex, newThickness: thickness)
        }
    }
    
    @IBAction func Modify(_ sender: Any) {
        move.state = .off
        
    }
    
    @IBAction func Move(_ sender: Any) {
        modify.state = .off
    }
    
    @IBAction func DeleteShape(_ sender: NSToolbarItem) {
        move.state = .off
        modify.state = .off
        if let selectedIndex = controller?.selectedShape {
            controller?.removeShape(at: selectedIndex)
            controller?.selectedShape = nil
        }
        
    }
    
    @IBAction func ClearAll(_ sender: Any) {
        guard let controller = controller else { return }
        
        let oldShapes = controller.document?.shapes ?? []
        
        controller.document?.shapes = []
        controller.polygonEdges = []
        controller.rectangleEdges = []
        controller.points = []
        controller.clippingSHShapes = []
        controller.gradientPoints = []
        
        controller.updateLayout()

        controller.document?.undoManager?.registerUndo(withTarget: self, handler: { windowController in
            windowController.controller?.document?.shapes = oldShapes
            windowController.controller?.updateLayout()
            
            controller.document?.undoManager?.registerUndo(withTarget: windowController, handler: { windowController in
                windowController.ClearAll(sender)
            })
        })
    }
    
    
    @IBAction func AntiA(_ sender: NSButton) {
        controller?.updateLayout()
    }
    
    
    @IBAction func FillingImageChange(_ sender: NSButton) {
        
        move.state = .off
        modify.state = .off
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowedFileTypes =  NSImage.imageTypes
        openPanel.beginSheetModal(for:self.window!) { (response) in
            if response == .OK {
                if let selectedIndex = self.controller?.selectedShape {
                    guard let data = try? Data(contentsOf: openPanel.url!) else {
                        return
                    }
                    
                    let image = NSBitmapImageRep(data: data)
                    
                    if self.fillingModeSegmentedControl.isSelected(forSegment: 1) {
                        self.controller?.changeFillingImage(for: selectedIndex, newImage: image, normalFillingMode: false)
                    } else if self.fillingModeSegmentedControl.isSelected(forSegment: 0) {
                        self.controller?.changeFillingImage(for: selectedIndex, newImage: image, normalFillingMode: true)
                    }
                    
                }
            }
            openPanel.close()
        }
        
    }
}
