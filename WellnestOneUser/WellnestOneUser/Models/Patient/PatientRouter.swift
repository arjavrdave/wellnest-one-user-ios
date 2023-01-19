//
//  PatientRouter.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 02/12/22.
//

import Foundation
import Foundation
import Alamofire

enum PatientRouter: URLRequestConvertible {
    case linkFamilyMember(Patient, Int)
    case getInTouch(Patient)
    var method: HTTPMethod {
        switch self {
        case .linkFamilyMember(_,_):
            return .put
        case .getInTouch(_):
            return .post
        }
    }
    var path: String {
        switch self {
        case .linkFamilyMember(_,let recordingId):
            return "/api/Patient/LinkFamilyMember/\(recordingId)"
        case .getInTouch(_):
            return "/api/Account/GetInTouch"
        }
    }
    var parameters: Patient {
        switch self {
        case .linkFamilyMember(let account, _):
            return account
        case .getInTouch(let account):
            return account
        }
    }
    public func asURLRequest() throws -> URLRequest {
        let url = try AppConfiguration.baseURLPath.asURL()
        
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        switch self {
        case .linkFamilyMember(_, _), .getInTouch(_):
            request.httpBody = self.parameters.convertToJSONEncoder()
        }
        if AppConfiguration.debugOn {
            print("===== URL Request =====")
            print(request.url?.absoluteString ?? "Invalid URL")
            print(request.httpBody?.convertDataToJSON() ?? "No Parameters")
            print("===== Request End =====")
        }

        return try URLEncoding.default.encode(request ,with: nil)
    }
}
