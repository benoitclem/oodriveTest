//
//  oodNetApi.swift
//  PdfToText
//
//  Created by Clément on 02/06/2017.
//  Copyright © 2017 JACK. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class oodNetApi {
    
    static let sharedInstance = oodNetApi()
    
    var scheme: String!
    var baseUrl: String!
    
    var log: String!
    var pwd: String!

    private init(){
        print("init oodNetApi")

        // Look into plist for the
        let netApiConfig = Bundle.main.object(forInfoDictionaryKey: "oodNetApi")
        if(netApiConfig != nil) {
            let config = netApiConfig as! [String:String]
            self.scheme = config["scheme"]
            self.baseUrl = config["baseUrl"]
        }
    }
    
    func setCredentials( log:String, pwd: String){
        self.log = log
        self.pwd = pwd
    }
    
    func me(completion:@escaping (_ root: Node?, NSError?)->Void) {
        let fullUrl = self.scheme + "://" + self.baseUrl + "/me"
        Alamofire.request(fullUrl, method: .get)
            .authenticate(user: self.log, password: self.pwd)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(">>> /me: \(json)")
                    let rootNode = Node(fromJson: json["rootItem"])
                    var credentials:JSON = [:]
                    completion(rootNode,nil)
                case .failure(let error):
                    completion(nil, error as NSError)
                }
        }
    }
    
    func getNodes(with nodeId: String, and completion:@escaping (_ nodes: [Node]?, NSError?)->Void) {
        let fullUrl = self.scheme + "://" + self.baseUrl + "/items/" + nodeId
        Alamofire.request(fullUrl, method: .get)
            .authenticate(user: self.log, password: self.pwd)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var nodes = [Node]()
                    for (index,subJson):(String, JSON) in json {
                        nodes.append(Node(fromJson: subJson))
                    }
                    completion(nodes, nil)
                case .failure(let error):
                    completion(nil, error as NSError)
                }
        }
    }

    func createFolder(into nodeId: String, _ folderName:String, and completion:@escaping (_ node: Node?, NSError?)->Void) {
        let fullUrl = self.scheme + "://" + self.baseUrl + "/items/" + nodeId
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        let parameters: Parameters = ["name": folderName]
        Alamofire.request(fullUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .authenticate(user: self.log, password: self.pwd)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let node = Node(fromJson: json)
                    completion(node, nil)
                case .failure(let error):
                    NSLog("\(error)")
                    completion(nil, NSError(domain: "Error", code: 1, userInfo: ["netInfo":"error"]))
                }
        }
    }
    
    func createFile(into nodeId: String, _ fileName:String, _ fileData: Data,
                    completion completion:@escaping (_ node: Node?, NSError?)->Void,
                    andProgress uploadHandler: ((_ result: Double) -> Void)?) {
        let fullUrl = self.scheme + "://" + self.baseUrl + "/items/" + nodeId
        let headers: HTTPHeaders = [
            "Content-Type": "application/octet-stream",
            "Content-Disposition": "attachment;filename*=utf-8''" + fileName
        ]
        Alamofire.upload(fileData, to: fullUrl, headers: headers)
            .uploadProgress { progress in
                print("Upload Progress: \(progress.fractionCompleted)")
                uploadHandler?(progress.fractionCompleted)
            }
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(">>> /item/\(nodeId): \(json)")
                    let node = Node(fromJson: json)
                    completion(node, nil)
                case .failure(let error):
                    completion(nil, NSError(domain: "Error", code: 1, userInfo: ["netInfo":"error"]))
                }
        }
    }
    
    // Gettin issues when deleting
    func deleteNode(with nodeId: String, andCompletion completion:@escaping (NSError?)->Void) {
        let fullUrl = self.scheme + "://" + self.baseUrl + "/items/" + nodeId
        NSLog("\(fullUrl)")
        Alamofire.request(fullUrl, method: .delete)
            .authenticate(user: self.log, password: self.pwd)
            .validate(statusCode: 200..<300)
            .response { response in
                if let code = response.response?.statusCode {
                    if code == 204 {
                        completion(nil)
                    }
                }
            }
            .responseJSON{ response in
                switch response.result {
                case .failure(let error):
                    //NSLog("\(error)")
                    NSLog("\(response.data)")
                    completion(error as NSError)
                default:
                    break
                }
            }
        
    }
    
    func downloadFile(with nodeId: String, andCompletion completion:@escaping (Data?,NSError?)->Void) {
        let fullUrl = self.scheme + "://" + self.baseUrl + "/items/" + nodeId + "/data"
        NSLog("\(fullUrl)")
        Alamofire.request(fullUrl)
            .authenticate(user: self.log, password: self.pwd)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success:
                    // The response result value could be null, means that in call,
                    // user should care of checking data presence.
                    completion(response.result.value,nil)
                case .failure(let error):
                    completion(nil,error as Error as NSError)
                }
        }
    }
    
    
}
