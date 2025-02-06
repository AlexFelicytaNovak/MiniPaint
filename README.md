# 🎨 Vector Drawing Application ("Mini Paint")
MacOS application built using **Swift** and **AppKit**.
This application allows users to create and manipulate vector graphics, offering a flexible interface for creating documents composed of shapes such as lines, polygons, rectangles, circles, and ellipses.

## ✨ Key Features
### Document-Based Architecture
The application supports **autosave** and an **undo/redo** stack to enhance usability and reliability.
  
### Shape Types
  - **Lines**
  - **Polygons**
  - **Rectangles**
  - **Circles**
  - **Ellipses**

### Shape Styling Options
  - Change **stroke thickness** and color.
  - Fill shapes with a **solid color**.
  - Apply **gradient fills**.
  - Use **bitmap images** as fills.
  
### Shape Clipping
Select two shapes to clip them using Sutherland-Hodgman algorithm. The clip polygon (the one defining the boundary) has to be convex for clipping to take place.
  
### Interactive Canvas
  - The canvas is represented using an `NSBitmapImageRep`.
  - The canvas is displayed in an extended `NSImageView`.
  - Overloaded mouse events allow for capturing clicks, shape placement, resizing, and dragging operations.
  - Canvas supports anti-aliasing using a custom implementation which can be turned on and off from the toolbar.

## 🏗️ Application Architecture
This application follows Model-View-Controller architecture, where *Model* is the Document which represents the drawing canvas, as well as the Shape objects representing vector shapes. *View* is the extended `NSImageView` which handles events such as mouse clicks, while *Controller* is the ViewController responsible for laying out shapes on the view, resizing canvas and performing actions in response to UI events.

- **NSDocument Subclass**: Manages document-based workflows such as opening, saving, and autosaving vector image files.
  - Handles undo/redo using the built-in `NSUndoManager`.
  
- **Canvas Rendering**: Utilizes `NSBitmapImageRep` for bitmap representation of the canvas.

- **Custom Image View**: Extends `NSImageView` to handle interactive shape operations and captures user events for resizing, dragging, and placing shapes on the canvas.

- **NSUndoManager**: Tracks and manages undo/redo actions, ensuring user edits can be safely reversed or redone.


## 🔨 Installation 
In order to install the project you need a Mac with **Xcode 14 or later** installed.
1. Open `CGProject3.xcodeproj` in Xcode.
2. Select CGProject3 build target and My Mac as run destination.
3. Build and Run the project.

## 📸 Screenshots

<img width="1412" alt="Mini Paint Window with canvas" src="https://github.com/user-attachments/assets/789933a8-3a5c-491b-9502-67bac1aea7f4" />


## 📚 Usage
1. Create a new document by selecting **File > New**.
2. Place shapes on the canvas using the window toolbar.
3. Drag, resize, or modify shapes directly on the canvas.
4. Customize fills using the color, gradient, or image fill options.
5. Save your work using **File > Save**.

## 📄 Credits
Project was developed as part of the **Computer Graphics** course at **Warsaw University of Technology**
