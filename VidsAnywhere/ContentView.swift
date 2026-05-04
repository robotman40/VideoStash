//
//  ContentView.swift
//  VidsAnywhere
//
//  Created by Chris Rios on 5/2/26.
//

import SwiftUI

struct InfoView: View {
    // Local variables for the Information dialogue
    @Environment(\.dismiss) private var dismiss // This is to allow us to close the window
    var title: String
    var message: String
    var result: YTDLPResult?
    
    var body: some View {
        VStack {
            // Title of the message
            Text(title)
                .fontWeight(.bold)
                .font(.system(size: 16))
                .padding()
            
            // Message
            Text(message)
                .padding()
            
            // Button to dismiss the dialogue
            Button("Ok", action: { dismiss() })
                .padding()
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
}

struct ContentView: View {
    // State variables for the program
    @State private var currentUrl: String = "" // URL in the textbox
    @State private var infoData: InfoData? // Current infoData
    @State private var currentlyBusy: Bool = false // Blocks UI elements if an operation is happening
    
    // Struct so we can efficiently manage information gained from yt-dlp calls
    struct InfoData : Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let result: YTDLPResult?
    }
    
    var body: some View {
        VStack {
            Text("VideoStash")
                .fontWeight(.bold)
                .font(.system(size: 32))
                .padding()
            
            Text("Download videos in audio and video formats for free!")
            TextField("Enter a URL", text: $currentUrl)
                .disabled(currentlyBusy)
                .padding()
            
            HStack {
                Button("Audio", systemImage: "music.note") {
                    Task {
                        await downloadAudio(url: currentUrl)
                    }
                }
                .disabled(currentlyBusy)
                Button("Video", systemImage: "video") {
                    Task {
                        await downloadVideo(url: currentUrl)
                    }
                }
                .disabled(currentlyBusy)
            }
            .padding()
            
            HStack {
                ProgressView()
                Text("Currently in Progress")
            }
            .opacity(currentlyBusy ? 1 : 0)
        }
        .padding()
        .frame(alignment: .center)
        // This will display a dialogue if infoData is updated
        .sheet(item: $infoData) { data in
            InfoView(title: data.title, message: data.message, result: data.result)
        }
    }
    
    @MainActor
    func downloadAudio(url: String) async {
        // Download audio
        currentlyBusy = true;
        do {
            // Block the UI while we're running yt-dlp
            let result = try await YTDLPDownload(format: "mp3", url: url)
            
            // Get data about the call and display it to the user
            infoData = InfoData(
                title: result.success ? "Success" : "Error",
                message: result.success
                    ? "The audio has successfully downloaded"
                    : "The video failed to download: \(result.output ?? "unknown")",
                result: result
            )
        } catch {
            // Show an error box if something went wrong
            infoData = InfoData(
                title: "Error",
                message: "An unknown error occurred",
                result: nil
            )
        }
        currentlyBusy = false;
    }
    
    @MainActor
    func downloadVideo(url: String) async {
        // Download video
        currentlyBusy = true;
        do {
            // Block the UI while we're running yt-dlp
            let result = try await YTDLPDownload(format: "mp3", url: url)
            
            // Get data about the call and display it to the user
            infoData = InfoData(
                title: result.success ? "Success" : "Error",
                message: result.success
                    ? "The video has successfully downloaded"
                : "The video failed to download: \(result.output ?? "unknown")",
                result: result
            )
        } catch {
            // Show an error box if something went wrong
            infoData = InfoData(
                title: "Error",
                message: "An unknown error occurred",
                result: nil
            )
        }
        currentlyBusy = false;
    }
}

#Preview {
    ContentView()
}
