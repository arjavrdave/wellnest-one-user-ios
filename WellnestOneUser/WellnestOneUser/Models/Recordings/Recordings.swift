//
//  Recordings.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 08/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

protocol IRecordings : Codable {
    
    var id: Int? { get set }
    var take : Int? { get set }
    var skip : Int? { get set }
    var createdAt: String? { get set }
    var reason: String? { get set }
    var bpm: Int? { get set }
    var reviewStatus: String? { get set }
    var routineCheckUp : Bool? { get set }
    var preOperativeAssessment : Bool? { get set }
    var preLifeInsurance : Bool? { get set }
    var preMediClaim : Bool? { get set }
    var preEmployment : Bool? { get set }
    var chestPain : Bool? { get set }
    var uneasiness : Bool? { get set }
    var jawPain : Bool? { get set }
    var upperBackPain : Bool? { get set }
    var palpitation : Bool? {get set}
    var vomiting : Bool? { get set }
    var unexplainedPerspiration : Bool? { get set }
    var breathlessnessOnExertion : Bool? { get set }
    var breathlessnessOnResting : Bool? { get set }
    var symptomatic : Bool? { get set }
    var others: String? { get set }
    var fileName : String? { get set }
    var cardiologyAdvice : String? { get set }
    var qrs : Double? { get set }
    var st : Double? { get set }
    var pr : Double? { get set }
    var qt : Double? { get set }
    var qtc : Double? { get set }
    var ecgDeviceId : Int? { get set }
    var displayDatewithTime : String { get }
    var patient : Patient? { get set }
    var pdfDate : String { get }
    var recordingRawData : Data? { get set }
    var reportedBy : Doctor? { get set }
    var patientImage : Data? { get set }
    var setup: String { get set }
    var forwarded: Bool? { get set }
    var risk: String? { get set }
    var searchPatientName : String { get set }
    var displayDateForLanding : String? { get set }
    var ecgFindings : String? {get set}
    var interpretations : String? {get set}
    var recommendations : String? {get set}
    
    func getRecordings (completion: @escaping ListCompletionHandler<Recordings>)
    func createRecordings (completion: @escaping ObjectCompletionHandler<Recordings>)
    func sendFeedback (completion: @escaping ErrorCompletionHandler)
    func approveFeedback (queryParameter: Bool, completion: @escaping ErrorCompletionHandler)
    func sendForFeedback (completion: @escaping ErrorCompletionHandler)
    func getRecording (completion: @escaping ObjectCompletionHandler<Recordings>)
    func updateRecording (completion: @escaping ObjectCompletionHandler<Recordings>)
    func reRecordRecording (completion: @escaping ErrorCompletionHandler)
    func saveOfflineRecording (completion: @escaping ObjectCompletionHandler<Recordings>)
}

class Recordings : NSObject, IRecordings {
    
    var patientImage: Data?
    
    var displayDateForLanding: String?
    var take : Int?
    var skip : Int?
    var searchPatientName = ""
    var id: Int?
    var ecgFindings: String?
    var interpretations: String?
    var recommendations: String?
    
    var createdAt: String?
    var reason: String?
    var bpm: Int?
    var reviewStatus: String?
    var reportedBy: Doctor?
    var recordingRawData: Data?
    var routineCheckUp: Bool?
    var preOperativeAssessment: Bool?
    var preLifeInsurance: Bool?
    var preMediClaim: Bool?
    var preEmployment: Bool?
    var chestPain: Bool?
    var uneasiness: Bool?
    var jawPain: Bool?
    var upperBackPain: Bool?
    var palpitation: Bool?
    var vomiting: Bool?
    var unexplainedPerspiration: Bool?
    var breathlessnessOnExertion: Bool?
    var breathlessnessOnResting: Bool?
    var others: String?
    var symptomatic: Bool?
    var risk: String?
    
    var ecgDeviceId: Int?
    var patient: Patient?
    var fileName: String?
    
    var cardiologyAdvice: String?
    
    var qrs: Double?
    var st: Double?
    var pr: Double?
    var qt: Double?
    var qtc: Double?
    var setup = "standard"
    var forwarded: Bool?
    var displayDatewithTime : String {
        get {
            if !(self.createdAt?.contains("Z") ?? false) {
                self.createdAt?.append("Z")
            }
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: createdAt ?? "")
            let dateFormat2 = DateFormatter.init()
            dateFormat2.dateFormat = "dd MMM, yyyy | h:mm a"
            return dateFormat2.string(from: date ?? Date.init())
        }
    }
    
    
    var displayDate : String {
        get {
            if !(self.createdAt?.contains("Z") ?? false) {
                self.createdAt?.append("Z")
            }
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: createdAt ?? "")
            let dateFormat2 = DateFormatter.init()
            if Calendar.current.isDateInToday(date ?? Date.init()) {
                dateFormat2.dateFormat = "h:mm a"
                return dateFormat2.string(from: date ?? Date.init())
            } else if Calendar.current.isDateInYesterday(date ?? Date.init()) {
                return "Yesterday"
            } else {
                dateFormat2.dateFormat = "dd MMM, yyyy"
                return dateFormat2.string(from: date ?? Date.init())
            }
        
        }
    }
    var pdfDate : String {
        get {
            if !(self.createdAt?.contains("Z") ?? false) {
                self.createdAt?.append("Z")
            }
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: createdAt ?? "")
            let dateFormat2 = DateFormatter.init()
            dateFormat2.dateFormat = "ddMMMyyyy"
            return dateFormat2.string(from: date ?? Date.init())
        
        }
    }

    
    private let alamoRequest: IAlamoRequest?
    
    init(_ _alamoRequest: IAlamoRequest){
        alamoRequest = _alamoRequest
    }

    required init(from decoder: Decoder) throws {
        self.alamoRequest = Initializers.shared.container.resolve(IAlamoRequest.self)
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.id             = try? container?.decodeIfPresent(Int.self, forKey: .id)
        self.createdAt      = try? container?.decodeIfPresent(String.self, forKey: .createdAt)
        self.reason         = try? container?.decodeIfPresent(String.self, forKey: .reason)
        self.bpm            = try? container?.decodeIfPresent(Int.self, forKey: .bpm)
        self.reviewStatus   = try? container?.decodeIfPresent(String.self, forKey: .reviewStatus)
        self.routineCheckUp = try? container?.decodeIfPresent(Bool.self, forKey: .routineCheckUp)
        self.preOperativeAssessment = try? container?.decodeIfPresent(Bool.self, forKey: .preOperativeAssessment)
        self.preLifeInsurance = try? container?.decodeIfPresent(Bool.self, forKey: .preLifeInsurance)
        self.preMediClaim   = try? container?.decodeIfPresent(Bool.self, forKey: .preMediClaim)
        self.preEmployment  = try? container?.decodeIfPresent(Bool.self, forKey: .preEmployment)
        self.chestPain      = try? container?.decodeIfPresent(Bool.self, forKey: .chestPain)
        self.uneasiness     = try? container?.decodeIfPresent(Bool.self, forKey: .uneasiness)
        self.jawPain        = try? container?.decodeIfPresent(Bool.self, forKey: .jawPain)
        self.upperBackPain  = try? container?.decodeIfPresent(Bool.self, forKey: .upperBackPain)
        self.palpitation    = try? container?.decodeIfPresent(Bool.self, forKey: .palpitation)
        self.vomiting       = try? container?.decodeIfPresent(Bool.self, forKey: .vomiting)
        self.unexplainedPerspiration = try? container?.decodeIfPresent(Bool.self, forKey: .unexplainedPerspiration)
        self.breathlessnessOnExertion = try? container?.decodeIfPresent(Bool.self, forKey: .breathlessnessOnExertion)
        self.breathlessnessOnResting = try? container?.decodeIfPresent(Bool.self, forKey: .breathlessnessOnResting)
        self.others                 = try? container?.decodeIfPresent(String.self, forKey: .others)
        self.fileName       = try? container?.decodeIfPresent(String.self, forKey: .fileName)
        self.cardiologyAdvice = try? container?.decodeIfPresent(String.self, forKey: .cardiologyAdvice)
        self.qrs            = try? container?.decodeIfPresent(Double.self, forKey: .qrs)
        self.st             = try? container?.decodeIfPresent(Double.self, forKey: .st)
        self.pr             = try? container?.decodeIfPresent(Double.self, forKey: .pr)
        self.qt             = try? container?.decodeIfPresent(Double.self, forKey: .qt)
        self.qtc             = try? container?.decodeIfPresent(Double.self, forKey: .qtc)
        self.patient      = try? container?.decodeIfPresent(Patient.self, forKey: .patient)
        self.symptomatic    = try? container?.decodeIfPresent(Bool.self, forKey: .symptomatic)
        self.ecgFindings = try? container?.decodeIfPresent(String.self, forKey: .ecgFindings)
        self.interpretations = try? container?.decodeIfPresent(String.self, forKey: .interpretations)
        self.recommendations = try? container?.decodeIfPresent(String.self, forKey: .recommendations)
        self.reportedBy   = try? container?.decodeIfPresent(Doctor.self, forKey: .reportedBy)
        self.forwarded      = try? container?.decodeIfPresent(Bool.self, forKey: .forwarded)
        self.risk           = try? container?.decodeIfPresent(String.self, forKey: .risk)
        if !(self.createdAt?.contains("Z") ?? false) {
            self.createdAt?.append("Z")
        }
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: createdAt ?? "")
        let dateFormat2 = DateFormatter.init()
        if Calendar.current.isDateInToday(date ?? Date.init()) {
            self.displayDateForLanding = "Today"
        } else if Calendar.current.isDateInYesterday(date ?? Date.init()) {
            self.displayDateForLanding = "Yesterday"
        } else {
            dateFormat2.dateFormat = "dd MMM, yyyy"
            self.displayDateForLanding = dateFormat2.string(from: date ?? Date.init())
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case patient
        case ecgDeviceId
        case symptomatic
        case id
        case createdAt
        case reason
        case bpm
        case reviewStatus
        case routineCheckUp
        case preOperativeAssessment
        case preLifeInsurance
        case preMediClaim
        case preEmployment
        case chestPain
        case uneasiness
        case jawPain
        case upperBackPain
        case palpitation
        case vomiting
        case unexplainedPerspiration
        case breathlessnessOnExertion
        case breathlessnessOnResting
        case fileName
        case cardiologyAdvice
        case qrs
        case st
        case pr
        case qt
        case qtc
        case setup
        case reportedBy
        case ecgFindings
        case interpretations
        case recommendations
        case forwarded
        case risk
        case others
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(bpm, forKey: .bpm)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(reviewStatus, forKey: .reviewStatus)
        try container.encodeIfPresent(routineCheckUp, forKey: .routineCheckUp)
        try container.encodeIfPresent(preOperativeAssessment, forKey: .preOperativeAssessment)
        try container.encodeIfPresent(preLifeInsurance, forKey: .preLifeInsurance)
        try container.encodeIfPresent(preMediClaim, forKey: .preMediClaim)
        try container.encodeIfPresent(preEmployment, forKey: .preEmployment)
        try container.encodeIfPresent(chestPain, forKey: .chestPain)
        try container.encodeIfPresent(uneasiness, forKey: .uneasiness)
        try container.encodeIfPresent(jawPain, forKey: .jawPain)
        try container.encodeIfPresent(upperBackPain, forKey: .upperBackPain)
        try container.encodeIfPresent(palpitation, forKey: .palpitation)
        try container.encodeIfPresent(vomiting, forKey: .vomiting)
        try container.encodeIfPresent(unexplainedPerspiration, forKey: .unexplainedPerspiration)
        try container.encodeIfPresent(breathlessnessOnExertion, forKey: .breathlessnessOnExertion)
        try container.encodeIfPresent(breathlessnessOnResting, forKey: .breathlessnessOnResting)
        try container.encodeIfPresent(reviewStatus, forKey: .reviewStatus)
        try container.encodeIfPresent(fileName, forKey: .fileName)
        try container.encodeIfPresent(cardiologyAdvice, forKey: .cardiologyAdvice)
        try container.encodeIfPresent(ecgFindings, forKey: .ecgFindings)
        try container.encodeIfPresent(interpretations, forKey: .interpretations)
        try container.encodeIfPresent(recommendations, forKey: .recommendations)
        try container.encodeIfPresent(qrs, forKey: .qrs)
        try container.encodeIfPresent(st, forKey: .st)
        try container.encodeIfPresent(pr, forKey: .pr)
        try container.encodeIfPresent(qt, forKey: .qt)
        try container.encodeIfPresent(qtc, forKey: .qtc)
        try container.encodeIfPresent(patient, forKey: .patient)
        try container.encodeIfPresent(symptomatic, forKey: .symptomatic)
        if ecgDeviceId == 0 {
            ecgDeviceId = 201
        }
        try container.encodeIfPresent(ecgDeviceId, forKey: .ecgDeviceId)
        try container.encodeIfPresent(reason, forKey: .reason)
        try? container.encodeIfPresent(setup, forKey: .setup)
        try? container.encodeIfPresent(others, forKey: .others)
    }
    
    
    
    func getRecordings(completion: @escaping ListCompletionHandler<Recordings>) {
        self.alamoRequest?.makeRequest(url: RecordingsRouter.getRecordings(self)).responseString(completionHandler: { (response) in
            var recordings : [Recordings]?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    recordings = jsonString.convertJSONToClass(type: [Recordings].self)
                }
            }
            completion(recordings, response.getError())
        })
    }
    
    func getRecording(completion: @escaping ObjectCompletionHandler<Recordings>) {
        self.alamoRequest?.makeRequest(url: RecordingsRouter.recordingDetails(self)).responseString(completionHandler: { (response) in
            var recordings : Recordings?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    #if DEBUG
                        print("========Received Response=========")
                        print(jsonString)
                        print("========End Received Response=========")
                    #endif
                    recordings = jsonString.convertJSONToClass(type: Recordings.self)
                }
            }
            completion(recordings, response.getError())
        })
    }
    
    func createRecordings(completion: @escaping ObjectCompletionHandler<Recordings>) {
        self.alamoRequest?.makeRequest(url: RecordingsRouter.createRecording(self)).responseString(completionHandler: { (response) in
            var recordings : Recordings?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    recordings = jsonString.convertJSONToClass(type: Recordings.self)
                }
            }
            completion(recordings, response.getError())
        })
    }
    
    func sendFeedback(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: RecordingsRouter.sendFeedback(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    func approveFeedback(queryParameter: Bool, completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: RecordingsRouter.approveFeedback(self, queryParameter)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    
    func sendForFeedback(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: RecordingsRouter.sendForFeedback(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }

    func updateRecording(completion: @escaping ObjectCompletionHandler<Recordings>) {
        self.alamoRequest?.makeRequest(url: RecordingsRouter.updateRecording(self)).responseString(completionHandler: { (response) in
            var recordings : Recordings?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    recordings = jsonString.convertJSONToClass(type: Recordings.self)
                }
            }
            completion(recordings, response.getError())
        })
    }
    
    func reRecordRecording(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: RecordingsRouter.reRecordRecording(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    
    func saveOfflineRecording(completion: @escaping ObjectCompletionHandler<Recordings>) {
        self.alamoRequest?.makeRequest(url: RecordingsRouter.offlineRecording(self)).responseString(completionHandler: { (response) in
            var recordings : Recordings?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    recordings = jsonString.convertJSONToClass(type: Recordings.self)
                }
            }
            completion(recordings, response.getError())
        })
    }
}
