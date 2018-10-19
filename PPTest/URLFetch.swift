//
//  URLFetch.swift
//  PPTest
//
//  Created by r leseberg on 10/17/18.
//  Copyright © 2018 starion. All rights reserved.
//

import Foundation
import SystemConfiguration

/// Request error type
public enum RequestErrorType: Error {
    /// Download Canceled
    case cancel
    /// Download request too large
    case tooLarge
    /// URL not found
    case notFound
    /// not connect to the internet
    case notConnected
    
    public var localizedDescription: String {
        switch self {
        case .cancel: return "Download canceled"
        case .tooLarge: return "Download request too large"
        case .notFound: return "URL not found"
        case .notConnected: return "Not connected to the internet"
        }
    }
}

class URLFetch {
    typealias RequestCompletion = (_ html: String) -> Void
    typealias FailureCompletion = (_ error: RequestErrorType) -> Void

    let kHeadSplit = "<head>"
    let kHeadEndSplit = "</head>"
    let kBodySplit = "<body>"
    let kShortBodySplit = "<body"
    let kEndBodySplit = "</body>"

    func updateHTML(blankHTML: String, url: URL?,
                    success: @escaping RequestCompletion,
                    failure: @escaping FailureCompletion) {
        
        guard let url = url else {
            return failure(RequestErrorType.notFound)
        }
        guard isConnectedToNetwork() else {
            return failure(RequestErrorType.notConnected)
        }
        
        if let data = try? Data(contentsOf: url), data.count > 0 {
            print("updateHTML count: \(data.count)")
            let downloadedHTML = String(decoding: data, as: UTF8.self)
            let htmlString = mergeHTML(blankHTML: blankHTML, html: downloadedHTML)
            return success(htmlString)
        } else {
            print("no data")
            return failure(RequestErrorType.notFound)
        }
    }
    
    private func mergeHTML(blankHTML: String, html: String) -> String {
        var merged = ""
        
        // move <head> info to blank
        let headerSplit = blankHTML.components(separatedBy: kHeadSplit)
        let htmlHeaderSplit = html.components(separatedBy: kHeadSplit)
        guard htmlHeaderSplit.count > 1, headerSplit.count > 1 else {
            print("<head> not found")
            return ""
        }
        let htmlEndHeaderSplit = htmlHeaderSplit[1].components(separatedBy: kHeadEndSplit)
        merged = headerSplit[0] + kHeadSplit + "\n" + htmlEndHeaderSplit[0] + headerSplit[1]
        
        // move <body> attributes and body to blank
        let bodySplit = merged.components(separatedBy: kBodySplit)
        let htmlBodySplit = html.components(separatedBy: kShortBodySplit)

        guard bodySplit.count > 1, htmlBodySplit.count > 1 else {
            print("<head> not found")
            return ""
        }
        let htmlBody = htmlBodySplit[1].components(separatedBy: kEndBodySplit)
        merged = bodySplit[0] + kShortBodySplit + htmlBody[0] + bodySplit[1]
        
        print(merged)
        return merged
    }
}

// from https://stackoverflow.com/questions/30743408/check-for-internet-connection-with-swift
extension URLFetch {
    private func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
}
