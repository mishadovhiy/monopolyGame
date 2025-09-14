//
//  Codable+Decodable.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import Foundation

extension Decodable {
    static func configure(_ data: Data?) -> Self? {
        guard let data else {
            return nil
        }
        do {
            let decoder = PropertyListDecoder()
            let decodedData = try decoder.decode(Self.self, from: data)
            return decodedData
        } catch {
#if DEBUG
            print("error decoding db data ", error)
#endif
            do {
                let decoderr = JSONDecoder()
                decoderr.nonConformingFloatDecodingStrategy = .throw

                return try decoderr.decode(Self.self, from: data)
            } catch {
                print("error decoding db data 22 ", error)

                return nil
            }
        }
    }
    
    static func configure(dict: [String: Any]) -> Self? {
        return .configure(try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted))
    }
}

extension Encodable {
    var decode: Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        do {
            return try encoder.encode(self)
        }
        catch {
#if DEBUG
            print("error encoding db ", error)
#endif
            return nil
        }
    }
    
    var encode: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    var dictionary:[String:Any]? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return json
        }
        return nil
    }
}
