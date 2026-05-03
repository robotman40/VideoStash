//
//  yt-dlp.swift
//  VidsAnywhere
//
//  Created by Chris Rios on 5/2/26.
//

import Foundation
import Subprocess
internal import System

// Error Enums (work on later)
enum YTDLPError: Error {
    case Unknown
}

// Result struct for yt-dlp calls
struct YTDLPResult {
    var pid: ProcessIdentifier
    var success: Bool
    var output: String?
}

func checkDependenciesAreInstalled() -> Bool {
    // Checks if all dependencies are installed via homebrew (A better implementation can be made later)
    return FileManager.default.fileExists(atPath: "/opt/homebrew/bin/yt-dlp")
    && FileManager.default.fileExists(atPath: "/opt/homebrew/bin/ffmpeg")
}

func YTDLPDownload(format: String, url: String) async throws -> YTDLPResult {
    // Download a video
    do {
        // Get the resulting call from running yt-dlp
        let result = try await run(
            .path("/opt/homebrew/bin/yt-dlp"),
            arguments: ["-t", format,
                        "-o", "Downloads/VideoStash/%(title)s.%(ext)s",
                        "--ffmpeg-location", "/opt/homebrew/bin/ffmpeg",
                        "--embed-thumbnail",
                        url],
            workingDirectory: FilePath(.homeDirectory),
            output: .string(limit: 16384)
        )
        // Return the result of the process when completed
        return YTDLPResult(pid: result.processIdentifier, success: result.terminationStatus.isSuccess, output: result.standardOutput)
    } catch {
        // Stuff error handling (work on later)
        throw YTDLPError.Unknown
    }
}

