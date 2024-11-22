//
//  FFmpegConverter.swift
//  FFSwift
//
//  Created by Jake Sulpice on 11/21/24.
//

import Foundation

struct FFmpegHelper {
    static func convertToX265(inputFile: String, outputFile: String) {
        // Path to FFmpeg binary bundled in your app
        guard let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: nil) else {
            print("FFmpeg binary not found in app bundle.")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: ffmpegPath)
        process.arguments = [
            "-i", inputFile,           // Input file
            "-c:v", "libx265",         // Use x265 codec
            "-crf", "28",              // Quality setting (lower = higher quality)
            "-preset", "fast",         // Speed preset
            outputFile                 // Output file
        ]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe

        do {
            try process.run()
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let outputString = String(data: outputData, encoding: .utf8) {
                print(outputString)
            }

            if process.terminationStatus == 0 {
                print("Conversion to x265 completed successfully!")
            } else {
                print("Conversion failed with status: \(process.terminationStatus)")
            }
        } catch {
            print("Error running FFmpeg: \(error.localizedDescription)")
        }
    }
}
