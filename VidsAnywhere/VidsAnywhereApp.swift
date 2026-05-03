//
//  VidsAnywhereApp.swift
//  VidsAnywhere
//
//  Created by Chris Rios on 5/2/26.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct VidsAnywhereApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // We make the app quit when all windows are closed
    
    private let dependenciesInstalled: Bool // This is an initialization variable
    
    init() {
        dependenciesInstalled = checkDependenciesAreInstalled() // Check if all dependencies (ffmpeg and yt-dlp are installed)
    }
    
    var body: some Scene {
        WindowGroup {
            if dependenciesInstalled {
                ContentView() // If all dependencies are installed, initialize the main program
            } else {
                // Otherwise tell the user they're missing stuff
                InfoView(
                    title: "Missing Dependencies",
                    message: "Please be sure that FFmpeg and yt-dlp are installed via Homebrew"
                )
            }
        }
        .windowResizability(.contentSize) // Limit resizability by default
    }
}
