import Foundation
import SwiftMessengerCore

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

private let defaultOutput = "docs/assets/type-catalog.json"

private func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("type catalog export failed: \(message)\n".utf8))
    exit(EXIT_FAILURE)
}

private func encodedCatalog() -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

    do {
        var data = try encoder.encode(PublishedTypeCatalog.document)
        data.append(0x0A)
        return data
    } catch {
        fail("could not encode catalog: \(error)")
    }
}

let arguments = Array(CommandLine.arguments.dropFirst())
let checkOnly = arguments.first == "--check"
let outputPath: String

if checkOnly {
    outputPath = arguments.dropFirst().first ?? defaultOutput
} else {
    outputPath = arguments.first ?? defaultOutput
}

let outputURL = URL(fileURLWithPath: outputPath)
let expected = encodedCatalog()

if checkOnly {
    guard let current = try? Data(contentsOf: outputURL) else {
        fail("missing \(outputPath); run `make type-cards`")
    }
    guard current == expected else {
        fail("\(outputPath) is stale; run `make type-cards`")
    }
    print("Type catalog export: committed JSON matches Swift source")
} else {
    do {
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try expected.write(to: outputURL, options: .atomic)
        print("Type catalog export: wrote \(PublishedTypeCatalog.document.cards.count) cards to \(outputPath)")
    } catch {
        fail("could not write \(outputPath): \(error)")
    }
}
