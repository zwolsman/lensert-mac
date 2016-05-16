//
//  AppDelegate.swift
//  lensert-mac
//
//  Created by Marvin on 12/05/16.
//  Copyright © 2016 Marvin. All rights reserved.
//

import Cocoa
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    @IBOutlet weak var window: NSWindow!

    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuItem : NSMenuItem = NSMenuItem()
    
    override func awakeFromNib() {
               registerSelectArea()
        registerSelectWindow()
        registerFullscreen()
    }
    
    func registerSelectArea() {
        let keyMask = NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.ShiftKeyMask.rawValue
        
        let shortcut = MASShortcut(keyCode: UInt(kVK_ANSI_A), modifierFlags: keyMask)
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(shortcut, withAction: selectArea)
    }
    func registerSelectWindow() {
        let keyMask = NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.ShiftKeyMask.rawValue
        
        let shortcut = MASShortcut(keyCode: UInt(kVK_ANSI_W), modifierFlags: keyMask)
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(shortcut, withAction: selectWindow)
    }
    func registerFullscreen() {
        let keyMask = NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.ShiftKeyMask.rawValue
        
        let shortcut = MASShortcut(keyCode: UInt(kVK_ANSI_F), modifierFlags: keyMask)
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(shortcut, withAction: fullscreen)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        MASShortcutMonitor.sharedMonitor().unregisterAllShortcuts()

    }
    
    func selectArea() {
        let temp = tempFile();
        shell("screencapture", "-i", temp);
        print("created screenshot! path: \(temp)")
        
        Uploader.upload("http://lensert.com/upload", imagePath: temp)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(temp)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func selectWindow() {
        let temp = tempFile();
        shell("screencapture", "-iW", temp);
        print("created screenshot! path: \(temp)")
        
        Uploader.upload("http://lensert.com/upload", imagePath: temp)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(temp)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func fullscreen() {
        let temp = tempFile();
        shell("screencapture", "-S", temp);
        print("created screenshot! path: \(temp)")
        
        Uploader.upload("http://lensert.com/upload", imagePath: temp)
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(temp)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    func tempFile() -> String {
        let directory = NSTemporaryDirectory()
        let fileName = NSUUID().UUIDString
        
        return "\(directory)\(fileName).png"
    }
    func shell(args: String...) -> Int32 {
        let task = NSTask()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification){
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: notification.informativeText!)!)
        center.removeDeliveredNotification(notification)
    }
}

