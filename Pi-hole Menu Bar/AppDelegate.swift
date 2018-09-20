//
//  AppDelegate.swift
//  Pi-hole Menu Bar
//
//  Created by Brian Hanna on 9/20/18.
//  Copyright © 2018 Brian Hanna. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(printQuote(_:))
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func runCommand(cmd : String) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = "/usr/bin/ssh"
        task.arguments = ["bhanna@ftp.mymusicisbetterthanyours.com", "-t", cmd]
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
    
    // @see https://stackoverflow.com/questions/29514738/get-terminal-output-after-a-command-swift
    // @see https://stackoverflow.com/questions/48175937/swift-execute-command-line-command-in-sandbox-mode
    
//    @objc func getPhpVersion(_ sender: Any?) {
//        let (output) = runCommand(cmd: "/usr/bin/ssh", args: "-t", "bhanna@ftp.mymusicisbetterthanyours.com");
//        print(output);
//    }
    
    // @see https://stackoverflow.com/questions/31407991/ssh-connectivity-using-swift

//    @objc func runCmd(cmd: String) {
//        let task = Process()
//        task.launchPath = "/usr/bin/ssh"
//        task.arguments = ["bhanna@ftp.mymusicisbetterthanyours.com", "-t", cmd]
//        task.launch()
//        task.waitUntilExit()
//    }
    
    @objc func getPiholeStatus(_ sender: Any?) {
        let output = runCommand(cmd: "sudo pihole status web")
        print(output)
    }
    
    @objc func enablePihole(_ sender: Any?) {
        let output = runCommand(cmd: "sudo pihole enable")
        print(output)
    }
    
    @objc func disablePihole(_ sender: Any?) {
        let output = runCommand(cmd: "sudo pihole disable")
        print(output)
    }
    
    @objc func printQuote(_ sender: Any?) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
    }
    
    
    func constructMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Pause for 30 Seconds", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem(title: "Pause for 5 Minutes", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem(title: "Enable", action: #selector(AppDelegate.enablePihole(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Disable", action: #selector(AppDelegate.disablePihole(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }

}

