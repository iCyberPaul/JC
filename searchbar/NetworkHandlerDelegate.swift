//
//  NetworkHandlerDelegate.swift
//  searchbar
//
//  Created by Paul Beattie on 07/08/2017.
//  Copyright © 2017 Paul Beattie. All rights reserved.
//

import Foundation


class NetworkHandlerDelegate: NSObject, URLSessionDownloadDelegate, URLSessionDataDelegate{
    
    // Provides a singleton
    static let shared = NetworkHandlerDelegate()
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        if let sessionDescriptionString = session.sessionDescription {
            switch sessionDescriptionString {
            case NetworkNames.search.rawValue :
            do {
                let fileData = try Data.init(contentsOf: location, options: .alwaysMapped)
                do {
                    let json = try JSONSerialization.jsonObject(with: fileData, options: .mutableContainers) as! Dictionary<String,AnyObject>
                    
                    print("recipe json \(json)")
                    
                    var recipeArray = [String]()
                    
                    if let individualDataDictionay = json["results"] {
                        for recipeInfo in individualDataDictionay as! Array<AnyObject> {

                            let recipe = recipeInfo["title"] as? String ?? ""

                            recipeArray.append(recipe)

                        }
                    }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: sessionDescriptionString), object: self, userInfo: [sessionDescriptionString:recipeArray])
                    }
                } catch {
                    print("Could not get JSON from the file data")
                }
            } catch {
                print("could not get data from file.")
                }
           
            default:
                print("The network response was not handled.")
            }
        }
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let sessionDescriptionString = session.sessionDescription {
            switch sessionDescriptionString {
            case NetworkNames.search.rawValue :
//                do {
//                    let fileData = try Data.init(contentsOf: location, options: .alwaysMapped)
                    do {
//                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String,AnyObject>
                        
                        print("recipe json \(json)")
                        
                        var recipeArray = [String]()
                        
                        if let individualDataDictionay = json["results"] {
                            for recipeInfo in individualDataDictionay as! Array<AnyObject> {

                                let recipe = recipeInfo["title"] as? String ?? ""

                                recipeArray.append(recipe)

                            }
                        }
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: sessionDescriptionString), object: self, userInfo: [sessionDescriptionString:recipeArray])
                        }
                    } catch {
                        print("Could not get JSON from the file data")
                    }
//            } catch {
//                print("could not get data from file.")
//            }


            default:
                print("The network response was not handled.")
            }
        }

    }
    
    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//
//        success = false
//
//        let httpResponse = response as! HTTPURLResponse
//        let statusCode = httpResponse.statusCode
//        if let sessionDescriptionString = session.sessionDescription {
//            switch sessionDescriptionString {
//            case networkNames.login.rawValue:
//                if statusCode == 200 {
//                    let keyValues = httpResponse.allHeaderFields.map { (String(describing: $0.key).lowercased(), String(describing: $0.value)) }
//
//                    // Now filter the array, searching for your header-key, also lowercased
//                    if let myHeaderValue = keyValues.filter({ $0.0 == "Set-Cookie".lowercased() }).first {
//                        log(message:"Headers \(myHeaderValue.1)")
//                        let cookies = myHeaderValue.1
//                        let cookieDict = cookies.components(separatedBy: ";")
//                        log(message:"Cookies \(cookieDict)")
//                        let tokenEntryParameter = cookieDict.filter({$0 .contains("token")})
//                        let tokenEntry = tokenEntryParameter.first
//                        token = (tokenEntry?.components(separatedBy: "=").last)!
//                    }
//                    success = true
//                }
//                log(message:"statusCode \(statusCode)")
//                DispatchQueue.main.async {
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: sessionDescriptionString), object: self, userInfo: [sessionDescriptionString:self.success])
//                }
//
//            default:
//                log(message:"Network call name missing")
//            }
//        }
        
//    }e
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("url session did become invalid with error")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("url session did receive challenge")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("url session did finish events for background session")
    }
    
    /// The Documents Directory
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    
    // MARK : - URLSessionTaskDelegate methods
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("url session did receive challenge")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("url session did send body data")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        print("url session need new body stream")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        print("url session will perform http redirect")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        print("url session did finish collecting metrics")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("url session did complete with error")
        print("task \(task)")
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("download task did resume")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("download task did write data")
    }
    
    // MARK : - URLSessionDataDelegate methods
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        print("url session data task did become download task")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        print("url session data task did become stream task")
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        print("url session data task will cache response")
    }


}
