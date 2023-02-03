//
//  RecordingRouter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 08/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import Alamofire

enum RecordingsRouter: URLRequestConvertible {
 
    case getECGSuggestions(Recordings)
    case getRecordings(Recordings)
    case createRecording(Recordings)
    case sendFeedback(Recordings)
    case approveFeedback(Recordings, Bool)
    case sendForFeedback(Recordings)
    case recordingDetails(Recordings)
    case updateRecording(Recordings)
    case reRecordRecording(Recordings)
    case offlineRecording(Recordings)
    
    var method: HTTPMethod {
        switch self {
        case .getECGSuggestions(_):
            return .get
        case .getRecordings(_):
            return .get
        case .createRecording(_):
            return .post
        case .sendFeedback(_):
            return .post
        case .approveFeedback(_,_):
            return .put
        case .sendForFeedback(_),.reRecordRecording(_):
            return .post
        case .recordingDetails(_):
            return .get
        case .updateRecording(_):
            return .put
        case .offlineRecording(_):
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .getECGSuggestions(_):
            return "/api/ECGRecording/Suggestion"
        case .getRecordings(_) :
            return "/api/ECGRecording"
        case .createRecording(_):
            return "/api/ECGRecording"
        case .sendFeedback(let recording):
            return "/api/ECGRecording/\(recording.id ?? 0)/SendFeedback"
        case .approveFeedback(let recording, _):
            return "/api/ECGRecording/\(recording.id ?? 0)/ApproveFeedback"
        case .sendForFeedback(let recording):
            return "/api/ECGRecording/\(recording.id ?? 0)/SendForFeedback"
        case .recordingDetails(let recording):
            return "/api/ECGRecording/\(String.init(describing: recording.id ?? 0))"
        case .updateRecording(let recording):
            return "/api/ECGRecording/UpdateRecording/\(recording.id ?? 0)"
        case .reRecordRecording(let recording):
            return "/api/ECGRecording/ReRecord/\(recording.id ?? 0)"
        case .offlineRecording(_):
            return "/api/ECGRecording/OfflineRecording"
        }
    }
    
    var parameters: Recordings {
        switch self {
        case .getECGSuggestions(let record):
            return record
        case .getRecordings(let record):
            return record
        case .createRecording(let record):
            return record
        case .sendFeedback(let record):
            return record
        case .approveFeedback(let record, _):
            return record
        case .sendForFeedback(let record):
            return record
        case .recordingDetails(let record):
            return record
        case .updateRecording(let record):
            return record
        case .reRecordRecording(let record):
            return record
        case .offlineRecording(let record):
            return record
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let url = try AppConfiguration.baseURLPath.asURL()
           
        var urlComponents = URLComponents(string: url.appendingPathComponent(self.path).absoluteString)!
        urlComponents.queryItems = []

        switch self {
        case .getRecordings(let recording):
            if recording.searchPatientName.trim() != "" {
                let queryItemSearchText = URLQueryItem(name: "PatientName", value: recording.searchPatientName)
                urlComponents.queryItems?.append(queryItemSearchText)
            }
            let queryTake = URLQueryItem.init(name: "Take", value: "\(recording.take ?? 30)")
            urlComponents.queryItems?.append(queryTake)
            let querySkip = URLQueryItem.init(name: "Skip", value: "\(recording.skip ?? 0)")
            urlComponents.queryItems?.append(querySkip)
            break
        case .approveFeedback(_,let isFeedbackUpdated):
            let queryTake = URLQueryItem.init(name: "FeedBackUpdated", value: String.init(isFeedbackUpdated))
            urlComponents.queryItems?.append(queryTake)
        default:
            break
        }
        var request = try URLRequest(url: urlComponents.url!, method: self.method)
        request.httpMethod = self.method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        switch self {
        case .createRecording(_),.sendFeedback(_):
            request.httpBody = self.parameters.convertToJSONEncoder()
        case .sendForFeedback(_):
            request.httpBody = Array<Int>().convertToJSONEncoder()
        case .approveFeedback(_, _):
            request.httpBody = self.parameters.convertToJSONEncoder()
        default:
            break
        }
        #if DEBUG
            print("===== URL Request =====")
            print(request.url?.absoluteString ?? "Invalid URL")
            print(request.httpBody?.convertDataToJSON() ?? "No Parameters")
            print("===== Request End =====")
        #endif

        return try URLEncoding.default.encode(request, with: nil)

    }
}
