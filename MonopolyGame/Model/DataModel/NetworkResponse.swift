//
//  NetworkResponse.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import Foundation

extension NetworkModel {
    enum RequestType:Codable {
        case support(SupportRequest)
        case fetchHTML(String)
        var isInvalid:Bool {
            switch self {
            case .support(let supportRequest):
                return [supportRequest.header.isEmpty, supportRequest.text.isEmpty, supportRequest.title.isEmpty].contains(true)
            case .fetchHTML(let url):
                return url.isEmpty
            }
        }
        struct SupportRequest:Codable {
            var text:String
            var header:String
            var title:String
        }
    }
    struct SupportResponse: Codable {
        private let data:Data?
        private var ok:String {
            NSString(data: data ?? .init(), encoding: String.Encoding.utf8.rawValue)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        init(data: Data?) {
            self.data = data
        }
        var success:Bool {
            return ok == "1"
        }
    }
}
