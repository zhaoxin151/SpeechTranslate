//
//  HttpRequest.swift
//  SpeechTranslate
//
//  Created by NATON on 2017/6/1.
//  Copyright © 2017年 NATON. All rights reserved.
//

import UIKit

enum HTResqustMethod:String {
    case Post = "post"
    case Get = "get"
}

class HttpRequest: AFHTTPSessionManager {

    static let instanceRequst:HttpRequest = {
        let instance = HttpRequest()
        instance.responseSerializer.acceptableContentTypes?.insert("text/html")
        return instance
    }()
    
    func request(method: HTResqustMethod, usrString: String, params:AnyObject?, resultBlock: @escaping([String : Any]?, Error?) -> ()) {
        
        //定义一个请求成功之后要执行的闭包
        //成功闭包
        let successBlock = { (task: URLSessionDataTask, responseObj: Any?) in
            resultBlock(responseObj as? [String : Any], nil)
        }
        
        // 失败的闭包
        let failureBlock = { (task: URLSessionDataTask?, error: Error) in
            resultBlock(nil, error)
        }
        
        // Get 请求
        if method == .Get {
            get(usrString, parameters: params, progress: nil, success: successBlock, failure: failureBlock)
        }
        
        // Post 请求
        if method == .Post {
            post(usrString, parameters: params, progress: nil, success: successBlock, failure: failureBlock)
        }
    }
    
//    /// 发送请求(上传文件)
//    func requestWithData(data: NSData, name: String, urlString: String, parameters: AnyObject?, resultBlock: @escaping([String : Any]?, Error?) ->()){
//        // 定义请求成功的闭包
//        let successBlock = { (dataTask: URLSessionDataTask, responseObject: AnyObject?) -> Void in
//            resultBlock(responseObject as? [String : Any], nil)
//        }
//        
//        // 定义请求失败的闭包
//        let failureBlock = { (dataTask: URLSessionDataTask?, error: NSError) -> Void in
//            resultBlock(nil, error)
//        }
//        post(urlString, parameters: parameters, constructingBodyWith: { (<#AFMultipartFormData#>) in
//            <#code#>
//        }, progress: { (<#Progress#>) in
//            <#code#>
//        }, success: successBlock, failure: failureBlock)
//    }
}

//调用代码
/*
NetworkTools.shardTools.request(method: .Post, urlString: urlString, parameters: params as AnyObject?) { (responseObject, error) in
    
    if error != nil {
        print(error!)
        return
    }
    
    guard (responseObject as? [String : AnyObject]) != nil else{
        
        return
    }
    
    print(responseObject!)
    
}*/
