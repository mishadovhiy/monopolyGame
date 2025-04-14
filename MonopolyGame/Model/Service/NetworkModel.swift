//
//  NetworkModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import Foundation

struct NetworkModel {
    func support(_ request:RequestType.SupportRequest, completion:@escaping(_ response:SupportResponse?)->()) {
        PerformRequest(.support(request)).start(completion: {
            completion(.init(data: $0))
        })
    }
}

extension NetworkModel {
    struct PerformRequest {
        var request:URLRequest?
        /// example, api secret key
        private var requestData:String?
        
        init(_ type:RequestType) {
            if type.isInvalid {
                request = nil
                return
            }
            switch type {
            case .support(let support):
                let toDataString = "emailTitle=\(support.title)&emailHead=\(support.header)&emailBody=\(support.text)"
                requestData = "44fdcv8jf3"
                guard let url:URL = .init(string: "https://www.mishadovhiy.com/apps/" + "budget-tracker-db/sendEmail.php?\(toDataString)") else {
                    request = nil
                    return
                }
                request = URLRequest(url: url)
                request?.httpMethod = "POST"
            }
        }
        
        func start(completion:@escaping(_ data: Data?)->()) {
            if request?.httpMethod == "POST" {
                self.uploadRequest(data: self.requestData ?? "", completion: completion)
            } else {
                self.performRequest(completion: completion)
            }
        }
        
        private func performRequest(data:String = "", completion:@escaping(_ data: Data?)->()) {
            guard let request else {
                completion(nil)
                return
            }
            let session = URLSession.shared.dataTask(with: request) { data, response, error in
                completion(data)
            }
            session.resume()
        }
        
        private func uploadRequest(data:String = "", completion:@escaping(_ data: Data?)->()) {
            guard let request else {
                completion(nil)
                return
            }
            let data = data.data(using: .utf8)
            
            let uploadJob = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                let returnedData = NSString(data: data ?? .init(), encoding: String.Encoding.utf8.rawValue)
                if error != nil {
                    completion(nil)
                    return
                }
                completion(data)
            }
            uploadJob.resume()
        }
    }
}
