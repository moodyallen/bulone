//
//  AppDelegate.swift
//  Bulone
//
//  Created by Moody Allen on 01/03/16.
//  Copyright © 2016 Moody Allen. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let window = NSApplication.shared().windows.first!
        window.title = "Bulone"
        addDarkTransparentEffect(to: window)
    }
}

fileprivate extension AppDelegate {
    
    func addDarkTransparentEffect(to window: NSWindow) {
        window.titlebarAppearsTransparent = true
        window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
    }
}
