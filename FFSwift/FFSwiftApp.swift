//
//  FFSwiftApp.swift
//  FFSwift
//
//  Created by Jake Sulpice on 11/21/24.
//

import SwiftUI

@main
struct FFSwiftApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
    func checkFFmpegAvailability() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: Bundle.main.path(forResource: "ffmpeg", ofType: nil)!)
        process.arguments = ["-version"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let output = pipe.fileHandleForReading.readDataToEndOfFile()
            if let outputString = String(data: output, encoding: .utf8) {
                print(outputString)
                return true
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }

        return false
    }
}
