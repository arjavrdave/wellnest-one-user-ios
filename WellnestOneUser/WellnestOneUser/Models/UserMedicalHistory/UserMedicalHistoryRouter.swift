//
//  UserMedicalHistoryRouter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 17/02/21.
//  Copyright © 2021 Wellnest Inc. All rights reserved.
//

import Foundation
import Alamofire

enum UserMedicalHistoryRouter: URLRequestConvertible {
 
    case updateMedicalHistory(UserMedicalHistory)
    case getMedicalHistory (UserMedicalHistory)
    
    var method: HTTPMethod {
        switch self {
        case .updateMedicalHistory(_):
            return .put
        case .getMedicalHistory(_):
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .updateMedicalHistory(let patient):
            return "/api/Patient/UpdateMedicalHistory/\(patient.patientId ?? 0)"
        case .getMedicalHistory(_):
            return "/api/Patient/MedicalHistory"
        }
    }
    
    var parameters: UserMedicalHistory {
        switch self {
        case .updateMedicalHistory(let medicalHistory):
            return medicalHistory
        case .getMedicalHistory(let medicalHistory):
            return medicalHistory
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let url = try AppConfiguration.baseURLPath.asURL()
           
        var urlComponents = URLComponents(string: url.appendingPathComponent(self.path).absoluteString)!
        urlComponents.queryItems = []

        var request = try URLRequest(url: urlComponents.url!, method: self.method)
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        switch self {
        case .updateMedicalHistory(_):
            request.httpBody = self.parameters.convertToJSONEncoder()
        default:
            break
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
