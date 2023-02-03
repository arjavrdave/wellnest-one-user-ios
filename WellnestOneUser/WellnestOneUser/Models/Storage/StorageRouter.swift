//
//  SASTokenRouter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 14/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import Alamofire

enum StorageRouter: URLRequestConvertible {
 
    case getUploadTokenForUser(Storage)
    case getReadTokenForUser(Storage)
    case getUploadTokenForECG(Storage)
    case getReadTokenForECG(Storage)
    case getReadTokenForSignature(Storage)
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .getUploadTokenForUser(_):
            return "/api/Storage/GetUploadTokenForOneUser"
        case .getReadTokenForUser(_):
            return "/api/Storage/GetReadTokenForOneUser"
       case .getUploadTokenForECG(let storage):
            return "/api/Storage/GetUploadTokenForECG/\(storage.fileName!)"
        case .getReadTokenForECG(let storage):
            return "/api/Storage/GetReadTokenForECG/\(storage.fileName ?? "")"
        case .getReadTokenForSignature(let storage):
            return "/api/Storage/GetReadTokenForSignature/\(storage.id ?? 0)"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try AppConfiguration.baseURLPath.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        #if DEBUG
            print("===== URL Request =====")
            print(request.url?.absoluteString ?? "Invalid URL")
            print(request.httpBody?.convertDataToJSON() ?? "No Parameters")
            print("===== Request End =====")
        #endif

        return try URLEncoding.default.encode(request ,with: nil)
    }
}

