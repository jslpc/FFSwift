//
//  ContentView.swift
//  FFSwift
//
//  Created by Jake Sulpice on 11/21/24.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct MainView: View {
    @State private var selectedFile: String = "No file selected"
    @State private var outputPath: String = "No output path selected"
    @State private var frameRate: String = defaultFrameRate
    @State private var encoder: String = defaultEncoder
    @State private var useHardwareAcceleration: Bool = false
    @State private var crf: String = defaultCrf
    @State private var preset: String = defaultPreset
    @State private var tune: String = defaultTune
    @State private var profile: String = defaultProfile
    @State private var frameWidth: String = defaultFrameWidth
    @State private var frameHeight: String = defaultFrameHeight
    @State private var padWidth: String = ""
    @State private var padHeight: String = ""
    @State private var colorSpace: String = "Unknown"
    @State private var bitDepth: String = "Unknown"
    @State private var aspectRatio: String = "Unknown"
    @State private var isHDR: Bool = false
    @State private var outputFileName: String = "output.mp4"
    @State private var x265Params: String = ""
    
    // Available frame rates and encoders
    private let frameRates = ["23.976", "24", "25", "29.97", "30", "50", "59.94", "60"]
    private let encoders = ["x264 (avc)", "x265 (hevc)", "vp9", "av1"]
    
    // Separate presets and profiles for each encoder
    private let x264Presets = ["ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow"]
    private let x265Presets = ["ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow"]
    private let videotoolboxPresets = ["fast", "medium", "slow"]
    
    private let x264Profiles = ["baseline", "main", "high", "high10", "high422", "high444"]
    private let x265Profiles = ["main", "main10", "main444-10"]
    private let videotoolboxProfiles = ["auto"]
    private let tunes = ["film", "animation", "grain", "stillimage", "fastdecode", "zerolatency"]
    private let crfValues = ["18", "20", "22", "23", "24", "26", "28"]
    
    // Computed properties for dynamic presets and profiles
    private var currentPresets: [String] {
        switch encoder {
        case "x265 (hevc)":
            return useHardwareAcceleration ? videotoolboxPresets : x265Presets
        case "x264 (avc)":
            return x264Presets
        default:
            return []
        }
    }
    
    private var currentProfiles: [String] {
        switch encoder {
        case "x265 (hevc)":
            return useHardwareAcceleration ? videotoolboxProfiles : x265Profiles
        case "x264 (avc)":
            return x264Profiles
        default:
            return []
        }
    }
    func parseFFprobeOutput(_ output: String) {
        let lines = output.split(separator: "\n")
        for line in lines {
            if line.contains("color_space") {
                colorSpace = String(line.split(separator: "=").last ?? "Unknown")
            } else if line.contains("bit_depth") {
                bitDepth = String(line.split(separator: "=").last ?? "Unknown")
            } else if line.contains("display_aspect_ratio") {
                aspectRatio = String(line.split(separator: "=").last ?? "Unknown")
            }
        }
    }
    func updateMediaInfo(for url: URL) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/ffprobe") // Adjust path to ffprobe
        process.arguments = [
            "-v", "error",
            "-show_entries", "stream=color_space,bit_depth,display_aspect_ratio",
            "-of", "default=noprint_wrappers=1",
            url.path
        ]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                parseFFprobeOutput(output)
            }
        } catch {
            print("Error running ffprobe: \(error.localizedDescription)")
        }
    }
    func selectFile(isInput: Bool) {
        let panel = NSOpenPanel()
        panel.title = isInput ? "Select a Video or Audio File" : "Select Output Path"
        panel.allowedContentTypes = isInput ? [
            UTType(filenameExtension: "mp4") ?? UTType.video,
            UTType(filenameExtension: "mkv") ?? UTType.video,
            UTType(filenameExtension: "avi") ?? UTType.video,
            UTType(filenameExtension: "mov") ?? UTType.video,
            UTType(filenameExtension: "mp3") ?? UTType.audio,
            UTType(filenameExtension: "aac") ?? UTType.audio,
            UTType(filenameExtension: "wav") ?? UTType.audio,
            UTType(filenameExtension: "flac") ?? UTType.audio
        ] : []
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = !isInput
        panel.canChooseFiles = isInput

        if panel.runModal() == .OK {
            if let url = panel.url {
                if isInput {
                    selectedFile = url.path
                    updateMediaInfo(for: url)
                } else {
                    outputPath = url.path
                }
            } else {
                if isInput {
                    selectedFile = "No file selected"
                } else {
                    outputPath = "No output path selected"
                }
            }
        } else {
            if isInput {
                selectedFile = "No file selected"
            } else {
                outputPath = "No output path selected"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // File Selection Section
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Button(action: { selectFile(isInput: true) }) {
                                Label("Input", systemImage: "folder")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            Text(selectedFile)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        VStack(alignment: .leading) {
                            Button(action: { selectFile(isInput: false) }) {
                                Label("Output", systemImage: "folder.badge.plus")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            Text(outputPath)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Video Conversion Title
                    Text("Video Conversion")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 8)
                    
                    // Encoding Options and Frame Settings
                    HStack(alignment: .top, spacing: 16) {
                        // Encoding Options
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Encoding Options")
                                .font(.headline)
                            
                            Picker("Frames p/s (fps)", selection: $frameRate) {
                                ForEach(frameRates, id: \.self) { Text($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Picker("Encoder", selection: $encoder) {
                                ForEach(encoders, id: \.self) { Text($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: encoder) { oldValue, newValue in
                                useHardwareAcceleration = (newValue == "x265 (hevc)")
                            }
                            
                            if encoder == "x265 (hevc)" {
                                Toggle("Hardware Acceleration", isOn: $useHardwareAcceleration)
                            }
                        }
                        
                        // Encoder Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Encoder Settings")
                                .font(.headline)
                            
                            Picker("CRF", selection: $crf) {
                                ForEach(crfValues, id: \.self) { Text($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Picker("Preset", selection: $preset) {
                                ForEach(currentPresets, id: \.self) { Text($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Picker("Tune", selection: $tune) {
                                ForEach(tunes, id: \.self) { Text($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Picker("Profile", selection: $profile) {
                                ForEach(currentProfiles, id: \.self) { Text($0) }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            // Show x265-params input only if x265 is selected
                            if encoder == "x265 (hevc)" && !useHardwareAcceleration {
                                TextField("Additional x265 Parameters", text: $x265Params)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .help("Enter additional x265 parameters (e.g., hdr10=1:aud=1:colorprim=bt2020).")
                            }
                        }
                        
                        // Frame Size
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Frame Size")
                                .font(.headline)
                            
                            TextField("Width", text: $frameWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Height", text: $frameHeight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Pad Width", text: $padWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Pad Height", text: $padHeight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    Divider()
                    
                    // Media Information
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Media Information")
                            .font(.headline)
                        
                        Text("Color Space: \(colorSpace)")
                        Text("Bit Depth: \(bitDepth)")
                        Text("Aspect Ratio: \(aspectRatio)")
                        Text("HDR: \(isHDR ? "Yes" : "No")")
                    }
                    
                    // Output File Name
                    HStack {
                        Text("Output File Name:")
                            .fontWeight(.medium)
                        TextField("Enter file name", text: $outputFileName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 300)
                    }
                    
                    // Convert Button
                    Button("Convert") {
                        let command = generateFFmpegCommand(outputFileName: outputFileName)
                        print(command) // Replace with actual execution logic
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                }
                .padding()
            }
        }
    }
    
    func generateFFmpegCommand(outputFileName: String) -> String {
        let inputFilePath = selectedFile
        let outputFilePath = "\(outputPath)/\(outputFileName)"
        
        // Determine the video codec based on encoder and hardware acceleration settings
        let videoCodec: String
        if encoder == "x265 (hevc)" {
            videoCodec = useHardwareAcceleration ? "hevc_videotoolbox" : "libx265"
        } else {
            videoCodec = "libx264" // Default to x264
        }
        
        // Build the command
        var commandComponents = [
            "ffmpeg",
            "-i", "\"\(inputFilePath)\"",
            "-c:v", videoCodec,
            "-crf", crf,
            "-preset", preset,
            "-tune", tune,
            "-profile:v", profile,
            "-r",             frameRate,
            "-vf", "\"scale=\(frameWidth):\(frameHeight),pad=\(padWidth):\(padHeight)\"",
            "\"\(outputFilePath)\""
        ]
        
        // Add HEVC-specific options if not using hardware acceleration
        if encoder == "x265 (hevc)" && !useHardwareAcceleration {
            if !x265Params.isEmpty {
                commandComponents.insert(contentsOf: ["-x265-params", "\"\(x265Params)\""], at: commandComponents.count - 1)
            }
            commandComponents.insert(contentsOf: ["-tag:v", "hvc1"], at: commandComponents.count - 1)
        }

        // Join the command components into a single string and return it
        return commandComponents.joined(separator: " ")
    }
}
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

private let defaultFrameRate = "23.976"
private let defaultEncoder = "x264 (avc)"
private let defaultCrf = "23"
private let defaultPreset = "veryfast"
private let defaultTune = "film"
private let defaultProfile = "auto"
private let defaultFrameWidth = "1920"
private let defaultFrameHeight = "1080"
private let defaultCropWidth = "1920"
private let defaultCropHeight = "1080"
