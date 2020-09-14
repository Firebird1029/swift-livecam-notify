//
//  AppDelegate.swift
//  Quotes
//
//  Created by Brandon Yee on 9/13/20.
//  Copyright © 2020 Brandon Yee. All rights reserved.
//

// https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos
// https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer
// https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild
// https://www.iconsdb.com/black-icons/circle-outline-icon.html

import Cocoa
import Foundation

@discardableResult
func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/bash"
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let popover = NSPopover()
    var counter = 0
    
    @objc func fireTimer() {
        counter += 1
        //print("Timer fired!")
        let detection = shell("system_profiler SPUSBDataType 2>/dev/null | grep 'Live! Cam Chat'")
        var statusIconName: String!
        if detection.isEmpty {
            // Webcam not attached
            statusIconName = "StatusBarButtonImageBlackOpen"
        } else {
            // Webcam attached
            if counter % 2 == 0 {
                statusIconName = "StatusBarButtonImageRed"
            } else {
                statusIconName = "StatusBarButtonImageRedOpen"
            }
        }
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name(statusIconName))
            button.action = #selector(togglePopover(_:))
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            //button.action = #selector(togglePopover(_:))
        }
        popover.contentViewController = QuotesViewController.freshController()
        
        constructMenu()
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        timer.tolerance = 0.1
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    @objc func printQuote(_ sender: Any?) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        //menu.addItem(NSMenuItem(title: "Print Quote", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
        //menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
}

