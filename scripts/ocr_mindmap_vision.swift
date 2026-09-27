#!/usr/bin/env swift
import Foundation
import Vision
import AppKit

/// OCR a mind-map image with Apple Vision and print JSON:
/// [{ "text": "...", "left": 0.1, "top": 0.2, "width": 0.05, "height": 0.03 }, ...]
/// Coordinates are normalized to the image (origin top-left).

guard CommandLine.arguments.count >= 2 else {
    fputs("Usage: ocr_mindmap_vision.swift <image-path>\n", stderr)
    exit(1)
}

let path = CommandLine.arguments[1]
guard let image = NSImage(contentsOfFile: path),
      let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let cgImage = rep.cgImage else {
    fputs("Failed to load image: \(path)\n", stderr)
    exit(1)
}

let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate
request.usesLanguageCorrection = false
request.recognitionLanguages = ["ja-JP", "en-US"]

let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
do {
    try handler.perform([request])
} catch {
    fputs("Vision failed: \(error)\n", stderr)
    exit(1)
}

struct Box: Codable {
    let text: String
    let left: Double
    let top: Double
    let width: Double
    let height: Double
    let confidence: Double
}

var boxes: [Box] = []
for observation in request.results ?? [] {
    guard let candidate = observation.topCandidates(1).first else { continue }
    // Vision bbox: origin bottom-left, normalized
    let r = observation.boundingBox
    let left = Double(r.origin.x)
    let width = Double(r.size.width)
    let height = Double(r.size.height)
    let top = Double(1.0 - r.origin.y - r.size.height)
    let text = candidate.string
        .replacingOccurrences(of: "\n", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    if text.isEmpty { continue }
    boxes.append(Box(
        text: text,
        left: left,
        top: top,
        width: width,
        height: height,
        confidence: Double(candidate.confidence)
    ))
}

boxes.sort { ($0.top, $0.left) < ($1.top, $1.left) }

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
if let data = try? encoder.encode(boxes),
   let json = String(data: data, encoding: .utf8) {
    print(json)
} else {
    fputs("JSON encode failed\n", stderr)
    exit(1)
}
