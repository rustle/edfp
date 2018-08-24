//
//  main.swift
//  edfp
//
//  Created by Doug Russell on 8/20/18.
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import EmojiDataFileParser
import Darwin
import Utility

enum EDFPError : Swift.Error {
    case networkError(String)
    case malformedURL(String)
    case unableToLoadData(String)
    case noInput
}

func fetch(url: Foundation.URL) throws -> Data {
    enum Result {
        case some(Data)
        case none(Error)
    }
    var r: Result?
    let sema = DispatchSemaphore(value: 0)
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        if let data = data {
            r = .some(data)
        } else if let error = error {
            r = .none(error)
        }
        sema.signal()
    }
    task.resume()
    sema.wait()
    guard let result = r else {
        throw EDFPError.networkError("Unknown Network Error")
    }
    switch result {
    case .some(let data):
        return data
    case .none(let error):
        throw error
    }
}

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
let parser = ArgumentParser(usage: "<options>",
                            overview: "Parse unicode emoji data file into CharacterSet bitmap file data.")
let urlArgument = parser.add(option: "--url",
                             shortName: "-u",
                             kind: String.self,
                             usage: "remote url of data file")
let inputArgument = parser.add(option: "--input",
                               shortName: "-i",
                               kind: String.self,
                               usage: "local path of data file")
let outputArgument = parser.add(option: "--output",
                                shortName: "-0",
                                kind: String.self,
                                usage: "local path of output file")

func processArguments(arguments: ArgumentParser.Result) throws {
    let read: () throws -> Data
    let write: (Data) throws -> Void
    if let urlString = arguments.get(urlArgument) {
        guard let url = URL(string: urlString) else {
            throw EDFPError.malformedURL(urlString)
        }
        read = {
            try fetch(url: url)
        }
    } else if let input = arguments.get(inputArgument) {
        read = {
            guard let data = FileManager.default.contents(atPath: input) else {
                throw EDFPError.unableToLoadData(input)
            }
            return data
        }
    } else {
        read = {
            throw EDFPError.noInput
        }
    }
    if let output = arguments.get(outputArgument) {
        write = {
            try ($0 as NSData).write(toFile: output, options: [])
        }
    } else {
        write = {
            FileHandle.standardOutput.write($0)
        }
    }
    let data = try read()
    let bitmap = try EmojiDataFileParser.parse(data: data)
    try write(bitmap)
}

do {
    let parsedArguments = try parser.parse(arguments)
    try processArguments(arguments: parsedArguments)
} catch let error as ArgumentParserError {
    print(error.description)
} catch let error as EDFPError {
    switch error {
    case .networkError(let description):
        print("Network Error: \(description)")
    case .malformedURL(let description):
        print("Malformed URL: \(description)")
    case .unableToLoadData(let description):
        print("Unable to read data from: \(description)")
    case .noInput:
        print("No Input")
    }
}catch let error {
    print(error.localizedDescription)
}
