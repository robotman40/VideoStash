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

struct SuccessView: View {
    @Environment(\.dismiss) private var dismiss // This is to allow us to close the window
    
    var body: some View {
        VStack {
            // Title of the message
            Text("Success")
                .fontWeight(.bold)
                .font(.system(size: 16))
                .padding()
            
            // Message
            Text("The video has successfully downloaded!")
                .padding()
            
            // Button to view in Finder
            Button("Show in Finder", action: { openInFinder(path: URL(fileURLWithPath: "~/Downloads/VideoStash")) })
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
    @State private var successfulDownload: Bool = false
    @State private var infoData: InfoData? // Current infoData
    @State private var currentlyBusy: Bool = false // Blocks UI elements if an operation is happening
    @State private var videoToggle: Bool = false
    
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
                .frame(width: 500)
                .disabled(currentlyBusy)
                .padding()
            
            HStack {
                Image(systemName: "music.note")
                Text("Audio")
                Toggle("", isOn: $videoToggle).toggleStyle(.switch).labelsHidden()
                Text("Video")
                Image(systemName: "video")
            }
            .padding()
            
            Button("Download") {
                Task {
                    currentlyBusy = true
                    if !videoToggle {
                        await downloadAudio(url: currentUrl)
                    } else {
                        await downloadVideo(url: currentUrl)
                    }
                    currentUrl = ""
                    currentlyBusy = false
                }
            }
            
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
        .sheet(isPresented: $successfulDownload) {
            SuccessView()
        }
    }
    
    @MainActor
    func downloadAudio(url: String) async {
        do {
            // Block the UI while we're running yt-dlp
            let result = try await YTDLPDownload(format: "mp3", url: url)
            
            // Get data about the call and display it to the user
            if result.success {
                successfulDownload = true;
            } else {
                infoData = InfoData(
                    title: result.success ? "Success" : "Error",
                    message: result.success
                    ? "The audio has successfully downloaded"
                    : "The video failed to download: \(result.output ?? "unknown")",
                    result: result
                )
            }
        } catch {
            // Show an error box if something went wrong
            infoData = InfoData(
                title: "Error",
                message: "An unknown error occurred",
                result: nil
            )
        }
    }
    
    @MainActor
    func downloadVideo(url: String) async {
        // Download video
        do {
            // Block the UI while we're running yt-dlp
            let result = try await YTDLPDownload(format: "mp3", url: url)
            
            // Get data about the call and display it to the user
            if result.success {
                successfulDownload = true;
            } else {
                infoData = InfoData(
                    title: result.success ? "Success" : "Error",
                    message: result.success
                    ? "The video has successfully downloaded"
                    : "The video failed to download: \(result.output ?? "unknown")",
                    result: result
                )
            }
        } catch {
            // Show an error box if something went wrong
            infoData = InfoData(
                title: "Error",
                message: "An unknown error occurred",
                result: nil
            )
        }
    }
}

#Preview {
    ContentView()
}
