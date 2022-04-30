//
//  RogueDriver.swift
//  iBrogueCE_iPad
//
//  Created by Robert Taylor on 4/28/22.
//  Copyright © 2022 Seth howard. All rights reserved.
//

import Foundation

let skviewPort = SKViewPort()
let brogueViewController = BrogueViewController()

typealias Short = UInt16

func plotChar(inputChar: displayGlyph,
              xLoc: Int,  yLoc: Int,
              foreRed: Short,  foreGreen: Short, foreBlue: Short,
              backRed: Short, backGreen: Short, backBlue: Short) {
    
    var glyphCode: UInt32
    
    
//    CGFloat backComponents[] = {(CGFloat)(backRed * .01), (CGFloat)(backGreen * .01), (CGFloat)(backBlue * .01), 1.};
//    CGColorRef backColor = CGColorCreate(_colorSpace, backComponents);
//
//    CGFloat foreComponents[] = {(CGFloat)(foreRed * .01), (CGFloat)(foreGreen * .01), (CGFloat)(foreBlue * .01), 1.};
//    CGColorRef foreColor = CGColorCreate(_colorSpace, foreComponents);

    let foreColor = CGColor(red: CGFloat(foreRed) * 0.01, green: CGFloat(foreGreen) * 0.01, blue: CGFloat(foreBlue) * 0.01, alpha: 1.0)
    let backColor = CGColor(red: CGFloat(backRed) * 0.01, green: CGFloat(backGreen) * 0.01, blue: CGFloat(backBlue) * 0.01, alpha: 1.0)
   
    if ( (inputChar.rawValue > 128) &&
         ((graphicsMode == TILES_GRAPHICS) ||
         ((graphicsMode == HYBRID_GRAPHICS) && (isEnvironmentGlyph(inputChar) != 0 ))) ) {
        glyphCode = (inputChar.rawValue-130) + 0x4000
    } else {
        glyphCode = glyphToUnicode(inputChar)
    }
    
    skviewPort!.setCell(x:xLoc, y:yLoc, code:glyphCode, bgColor:backColor ,fgColor:foreColor);
    
}


// Returns true if the player interrupted the wait with a keystroke; otherwise false.
func pauseForMilliseconds(milliseconds: Short) -> Bool {
    Thread.sleep(forTimeInterval: Double(milliseconds)/1000.0)
    if (brogueViewController.hasTouchEvent() || brogueViewController.hasKeyEvent()) {
        return true
    }
    return false
}

func nextKeyOrMouseEvent(returnEvent: inout rogueEvent, textInput: Bool, boolean colorsDance: Bool) {
    var  x,y: Int
    let TRUE: Int8 = 1
    let width: CGFloat = UIScreen.main.bounds.width
    let height: CGFloat = UIScreen.safeBounds.height
    while true {
        // we should be ok to block here. We don't seem to call pauseForMilli and this at the same time
        // 60Hz
        Thread.sleep(forTimeInterval: 0.016667)
        
        if (colorsDance) {
            shuffleTerrainColors(3, TRUE);
            commitDraws();
        }
        
        if (brogueViewController.hasKeyEvent)() {
            returnEvent.eventType = KEYSTROKE
            returnEvent.param1 = Int(brogueViewController.dequeKeyEvent())
            //printf("\nKey pressed: %i", returnEvent->param1);
            returnEvent.param2 = 0
            returnEvent.controlKey = 0;//([theEvent modifierFlags] & NSControlKeyMask ? 1 : 0);
            returnEvent.shiftKey = 0;//([theEvent modifierFlags] & NSShiftKeyMask ? 1 : 0);
            
            // since we detected a keypress, check flag for a mechanical keyboard
            keyboardPresent = brogueViewController.keyboardDetected()
            
            break;
        }
        if (brogueViewController.hasTouchEvent)() {
            let touch: UIBrogueTouchEvent = brogueViewController.dequeTouchEvent()!
            if (touch.phase != UITouch.Phase.cancelled) {
                switch (touch.phase) {
                case UITouch.Phase.began:  returnEvent.eventType = MOUSE_DOWN
                case UITouch.Phase.stationary: returnEvent.eventType = MOUSE_DOWN
                case UITouch.Phase.ended: returnEvent.eventType = MOUSE_UP
                case UITouch.Phase.moved: returnEvent.eventType = MOUSE_ENTERED_CELL
                    default:
                        break
                }
                
                x = Int(CGFloat(COLS) * CGFloat(touch.location.x) / width)
                y = Int(CGFloat(ROWS) * CGFloat(touch.location.y) / height)
                
                returnEvent.param1 = x
                returnEvent.param2 = y
                returnEvent.controlKey = 0
                returnEvent.shiftKey = 0
                
                break;
            }
        }
    }
}


// main constants and set up driver structure

// "Returns whether a keyboard modifier is active -- 0 for Shift, 1 for Ctrl."
// I guess that means:
// return TRUE or FALSE, and change the modifier to 0 or 1. What about both?
// i don't see that it's ever used, anyways
// nb:
// a better choice would be 0 for none, 1 for Shift, 2 for Ctrl, 3 for both
func modifierHeld(modifier: inout Int32) -> Int8 {
    modifier = -1
    if (shiftKeyIsDown() != 0) {
        modifier = 0
    } else if (controlKeyIsDown() != 0 ) {
        modifier = 1
    }
    return (modifier == -1) ? 0 : 1
}

func _setGraphicsMode(newMode: graphicsModes) -> graphicsModes {
    return newMode;
}

// makes sure the application support directory exists. not clear if that's the default location, though
func initializeBrogueSaveLocation() -> Void {
    _ = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}

// initialize data structures, call main Brogue game to start
func rogueMain() -> Void {
    previousGameSeed = 0
    initializeBrogueSaveLocation()
    fillGameStruct()
    mainBrogueJunction()
}


var hasGraphics = true;
var serverMode = false;
var keyboardPresent = false;                            // no keyboard until key pressed, set in nextKeyOrMouseEvent()
var graphicsMode: graphicsModes = TEXT_GRAPHICS;        // start in TEXT_GRAPHICS till mode switched


let currentConsole = UnsafeMutablePointer<brogueConsole>.allocate(capacity: 1)

func fillGameStruct() -> Void {
    currentConsole.pointee.gameLoop = rogueMain
    currentConsole.pointee.pauseForMilliseconds = pauseForMilliseconds
    currentConsole.pointee.nextKeyOrMouseEvent = nextKeyOrMouseEvent
    currentConsole.pointee.remap = nil
    currentConsole.pointee.plotChar = plotChar
    currentConsole.pointee.modifierHeld = nil    // couldn't get the type to line up for Swift. Not used in C engine anyways
    currentConsole.pointee.notifyEvent = nil
    currentConsole.pointee.takeScreenshot = nil
    currentConsole.pointee.setGraphicsMode = _setGraphicsMode
}


