//
//  NetworkHandler.swift
//  searchbar
//
//  Created by Paul Beattie on 07/08/2017.
//  Copyright © 2017 Paul Beattie. All rights reserved.
//

import Foundation

// A list of all the network calls and notification names.
enum NetworkNames : String {
    case search = "searchForRecipe"
}

typealias DataTaskResult = (NSData?, URLResponse?, NSError?) -> Void

protocol URLSessionDataTaskProtocol {
    func resume()
}

protocol URLSessionProtocol {
    func dataTaskWithURL(url: NSURL, completionHandler: DataTaskResult)
        -> URLSessionDataTaskProtocol
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }

extension URLSession : URLSessionProtocol {
    internal func dataTaskWithURL(url: NSURL, completionHandler: (NSData?, URLResponse?, NSError?) -> Void) -> URLSessionDataTaskProtocol {
        return (dataTaskWithURL(url: url, completionHandler: completionHandler)
            as! URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

class NetworkHandler {
    
    private var session : URLSessionProtocol
    var config : URLSessionConfiguration
    var url : String
    var delegate : NetworkHandlerDelegate
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session

        config = URLSessionConfiguration.default
        // Turn the cache off.
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        // Root URL
        url = "http://www.recipepuppy.com/api/"
        self.delegate = NetworkHandlerDelegate.shared
    }
    
    func obtainRecipies(containing searchTerm:String) {
        let preUrlString = url.appending("?q=\(searchTerm)")
            if let urlString = URL(string:preUrlString) {
            do {
                let data = try Data(contentsOf: urlString, options:.alwaysMapped)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String,AnyObject>
                    print("jaon = \(json)")
                    var recipeArray = [String]()
                    
                    if let individualDataDictionay = json["results"] {
                        for recipeInfo in individualDataDictionay as! Array<AnyObject> {
                            
                            let recipe = recipeInfo["title"] as? String ?? ""
                            
                            recipeArray.append(recipe)
                            
                        }
                    }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(NetworkNames.search.rawValue), object: self, userInfo: [NetworkNames.search.rawValue:recipeArray])
                    }
                } catch {
                    print("failed to convert data to json")
                }

            } catch {
                print("Failed to get data")
            }
            }

    }
    
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

    
    // MARK:- Common call to start network request.
    fileprivate func triggerRequest(_ networkQueue: NetworkNames, _ request: inout URLRequest) {

        let queue:OperationQueue = OperationQueue();
        queue.name = networkQueue.rawValue;
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount;
        let task = URLSession(configuration: config, delegate: delegate, delegateQueue: queue)
        task.sessionDescription = networkQueue.rawValue
        task.dataTask(with: request).resume()
    }
}
