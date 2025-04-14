//
//  FileManagerModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 14.04.2025.
//

import UIKit

struct FileManagerModel {
    func deleteAllFiles(url:URL? = nil) {
        let url = url ?? icloudDirectoryURL!
        let fileManager = FileManager.default
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                do {
                    var isDirectory: ObjCBool = false
                    if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
                        deleteAllFiles(url: fileURL)
                    } else {
                        try fileManager.removeItem(at: fileURL)
                    }
                } catch {
                    print("Error deleting file at \(fileURL): \(error)")
                }
            }
            
            try fileManager.removeItem(at: url)
            print("Successfully deleted all data at \(url).")
            
        } catch {
            print("Error accessing directory at \(url): \(error)")
        }
    }
    private var icloudDirectoryURL: URL? {
        let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) ?? FileManager.default.temporaryDirectory
        
        let hiddenDirectoryURL = iCloudURL.appendingPathComponent("Documents").appendingPathComponent(".hiddenImages")
        do {
            try FileManager.default.createDirectory(at: hiddenDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
#if DEBUG
            print("Failed to create hidden iCloud directory: \(error)")
#endif
            return FileManager.default.temporaryDirectory
        }
        
        return hiddenDirectoryURL
    }
    
    func delete(imageName:String?, completion:@escaping(Bool)->()) {
        fatalError()
        guard let imageName else {
            completion(false)
            return
        }
        ImageQuality.allCases.forEach { quality in
            let key = quality == .original ? "" : quality.rawValue
            self.performDelete(imageName: imageName + key) { _ in
                if quality == ImageQuality.allCases.last {
                    completion(true)
                }
            }
        }
    }
    
    private func performDelete(imageName:String?, completion:@escaping(Bool)->()) {
        guard let imageName, imageName != "" else {
            completion(false)
            return
        }
        guard let iCloudDirectoryURL = icloudDirectoryURL else {
            completion(false)
            return
        }
        
        let fileURL = iCloudDirectoryURL.appendingPathComponent(imageName).appendingPathExtension("png")
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
            completion(true)
        } catch {
#if DEBUG
            print(error, "error deleting image at: ", fileURL.absoluteString)
#endif
            completion(false)
        }
    }
    
    func upload(_ qualities:[ImageQuality] = ImageQuality.allCases, _ original:UIImage, name:String, completion:@escaping()->(), error:@escaping()->()) {
        if let quality = qualities.first,
           let data = quality.data {
#if os(watchOS)
#else
            performUpload(image: original.changeSize(newWidth: data.width), imageName: name + quality.rawValue, compressionQuality: quality.data?.compression ?? 1) {
                if $0 {
                    var new = qualities
                    new.removeFirst()
                    self.upload(new, original, name: name, completion: completion, error: error)
                } else {
                    error()
                }
            }
#endif
        } else {
            self.performUpload(image: original, imageName: name) {
                if $0 {
                    completion()
                } else {
                    error()
                }
            }
        }
    }
    
    private func performUpload(image: UIImage, imageName: String, compressionQuality: CGFloat = 1, completion: @escaping (Bool) -> Void) {
        guard let iCloudDirectoryURL = icloudDirectoryURL else {
            completion(false)
            return
        }
        
        let fileURL = iCloudDirectoryURL.appendingPathComponent(imageName).appendingPathExtension("png")
        
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            completion(false)
            return
        }
        
        do {
            try imageData.write(to: fileURL)
            completion(true)
        } catch {
#if DEBUG
            print("Failed to save image: \(error)")
#endif
            completion(false)
        }
    }
    
    func load(imageName: String, quality:ImageQuality, completion: @escaping (UIImage?) -> Void) {
        var imageName = imageName
        if imageName.isEmpty {
            completion(nil)
        }
        if quality != .original {
            imageName += quality.rawValue
        }
        guard let iCloudDirectoryURL = icloudDirectoryURL else {
            completion(nil)
            return
        }
        
        let fileURL = iCloudDirectoryURL.appendingPathComponent(imageName).appendingPathExtension("png")
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            let originalImage = UIImage(data: imageData)
            DispatchQueue.main.async {
                guard let image = originalImage?.jpegData(compressionQuality: quality.data?.compression ?? 1) else {
                    completion(nil)
                    return
                }
                completion(UIImage(data:image))
            }
        } catch {
#if DEBUG
            print("Failed to load image: \(error)")
#endif
            completion(nil)
        }
    }
}

enum ImageQuality: String, CaseIterable {
    case belowLowest
    case lowest
    case middle
    case aboveMiddle
    case original
    
    var data:QualityData? {
        return switch self {
        case .belowLowest:.init(width: 40, compression: 0.01)
        case .lowest:.init(width: 60, compression: 0.01)
        case .middle:.init(width: 115, compression: 0.1)
        case .aboveMiddle: .init(width: 180, compression: 0.1)
        case .original:nil
        }
    }
    struct QualityData {
        var width:CGFloat
        var compression:CGFloat
    }
}
