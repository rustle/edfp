//
//  EmojiDataFileParser.swift
//  EmojiDataFileParser
//
//  Created by Doug Russell on 8/17/18.
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

private enum StringError: Swift.Error {
    case badInput
}

private extension StringProtocol {
    func edfp_scanHexToUnicodeScalar() throws -> Unicode.Scalar {
        guard count < 6 else {
            throw StringError.badInput
        }
        let value = withCString { buffer in
            return strtol(buffer, nil, 16)
        }
        guard let scalar = Unicode.Scalar(value) else {
            throw StringError.badInput
        }
        return scalar
    }
}

public class EmojiDataFileParser {
    public enum Error: Swift.Error {
        case invalidInputData
    }
    public static func parse(data: Data) throws -> Data {
        guard let string = String(data: data, encoding: .utf8) else {
            throw Error.invalidInputData
        }
        var characterSet = CharacterSet()
        string.enumerateLines { line, stop in
            guard line.count > 0 else {
                return
            }
            guard !line.hasPrefix("#") else {
                return
            }
            guard let range = line.rangeOfCharacter(from: .whitespaces) else {
                return
            }
            let substring = line[..<range.lowerBound]
            if let range = substring.range(of: "..") {
                let lowerBoundSubstring = substring[..<range.lowerBound]
                let upperBoundSubstring = substring[range.upperBound...]
                do {
                    let lowerBound = try lowerBoundSubstring.edfp_scanHexToUnicodeScalar()
                    let upperBound = try upperBoundSubstring.edfp_scanHexToUnicodeScalar()
                    characterSet.insert(charactersIn: lowerBound...upperBound)
                } catch {
                    
                }
            } else {
                if substring.count == 4 || substring.count == 5 {
                    do {
                        characterSet.insert(try substring.edfp_scanHexToUnicodeScalar())
                    } catch {
                        
                    }
                }
            }
        }
        return characterSet.bitmapRepresentation
    }
}
