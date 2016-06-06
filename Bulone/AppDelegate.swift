//
//  AppDelegate.swift
//  Bulone
//
//  Created by Moody Allen on 01/03/16.
//  Copyright © 2016 Moody Allen. All rights reserved.
//

import Cocoa
import Mustache

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let w = NSApplication.sharedApplication().windows.first!
        addDarkTransparentEffectToWindow(w)
    }
    
    func addDarkTransparentEffectToWindow(window: NSWindow) {
        
//        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: window.frame.size.width, height: window.frame.size.height))
//        visualEffectView.material = NSVisualEffectMaterial.Dark
//        visualEffectView.blendingMode = NSVisualEffectBlendingMode.BehindWindow
//        visualEffectView.state = NSVisualEffectState.Active
        
        window.styleMask = window.styleMask | NSFullSizeContentViewWindowMask
        window.titlebarAppearsTransparent = true
        
        window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        
//        window.contentView?.addSubview(visualEffectView)
//        window.contentView?.addSubview(visualEffectView, positioned: NSWindowOrderingMode.Below, relativeTo: nil)
//        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

