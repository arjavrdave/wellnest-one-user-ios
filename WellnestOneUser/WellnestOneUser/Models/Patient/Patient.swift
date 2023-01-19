//
//  Patient.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 02/12/22.
//

import Foundation
import Alamofire
protocol IPatient: Codable {
    var id: Int? { get set }
    var profileId: String? { get set }
    
    var patientFirstName: String? { get set }
    var patientLastName: String? { get set }
    var fullName: String? { get set }
    var patientDateOfBirth: String? { get set }
    var patientGender: String? { get set }
    var age: Int? { get set }
    var phoneNumber: String? { get set }
    var countryCode: Int? { get set }
    var subject: String? { get set }
    var notes: String? { get set }
    var email: String? { get set }
    var source: String? { get set }
    func linkFamilyMember (recordingId: Int, completion: @escaping ErrorCompletionHandler)
    func getInTouch (completion: @escaping ErrorCompletionHandler)
    
}
class Patient: IPatient {
    
    var id: Int?
    var profileId: String?
    var patientFirstName: String?
    var patientLastName: String?
    var patientDateOfBirth: String?
    var patientGender: String?
    var age: Int? {
        get {
            if let birthday = CommonConfiguration.DATE_FORMATTER_ISO_Convert_ForDOB.date(from: self.patientDateOfBirth ?? "") {
                let calendar = Calendar.current
                
                let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date.init())
                if let age = ageComponents.year {
                    return age
                }
            } else {
                if !(self.patientDateOfBirth?.contains("Z") ?? false) {
                    self.patientDateOfBirth?.append("Z")
                }
                let formatter = DateFormatter.init()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                if let birthday = formatter.date(from: self.patientDateOfBirth ?? "") {
                    let calendar = Calendar.current
                    
                    let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date.init())
                    if let age = ageComponents.year {
                        return age
                    }
                }
            }
            return nil
        } set {
            
        }
        
    }
    var fullName: String? {
        get {
            let first = (self.patientFirstName?.capitalizingFirstLetter() ?? "") + " "
            let last = (self.patientLastName?.capitalizingFirstLetter() ?? "")
            return first + last
        } set {
            
        }
    }
    var phoneNumber: String?
    var countryCode: Int?
    var email: String?
    var subject: String?
    var notes: String?
    var source: String? = "ios"
    private let alamoRequest: IAlamoRequest?
    
    init(_ _alamoRequest: IAlamoRequest){
        alamoRequest = _alamoRequest
    }

    required init(from decoder: Decoder) throws {
        self.alamoRequest = Initializers.shared.container.resolve(IAlamoRequest.self)
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.id                     = try? container?.decodeIfPresent(Int.self, forKey: .id)
        self.patientFirstName        = try? container?.decodeIfPresent(String.self, forKey: .patientFirstName)
        self.patientLastName        = try? container?.decodeIfPresent(String.self, forKey: .patientLastName)
        self.patientDateOfBirth        = try? container?.decodeIfPresent(String.self, forKey: .patientDateOfBirth)
        self.patientGender        = try? container?.decodeIfPresent(String.self, forKey: .patientGender)
        self.phoneNumber            = try? container?.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.countryCode            = try? container?.decodeIfPresent(Int.self, forKey: .countryCode)
        self.email                  = try? container?.decodeIfPresent(String.self, forKey: .emailAddress)
        self.subject                = try? container?.decodeIfPresent(String.self, forKey: .subject)
        self.notes                  = try? container?.decodeIfPresent(String.self, forKey: .notes)
        self.profileId              = try? container?.decodeIfPresent(String.self, forKey: .profileId)
    }
    enum CodingKeys: String, CodingKey {
        case id
        case patientFirstName
        case patientLastName
        case patientDateOfBirth
        case patientGender
        case countryCode
        case emailAddress
        case subject
        case notes
        case fullName
        case source
        case profileId
        
        case firstName
        case lastName
        case gender
        case age
        case phoneNumber
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(self.patientFirstName, forKey: .firstName)
        try? container.encodeIfPresent(self.patientLastName, forKey: .lastName)
        try? container.encodeIfPresent(self.patientGender, forKey: .gender)
        try? container.encodeIfPresent(self.age, forKey: .age)
        try? container.encodeIfPresent(self.phoneNumber, forKey: .phoneNumber)
        try? container.encodeIfPresent(self.fullName, forKey: .fullName)
        try? container.encodeIfPresent(self.subject, forKey: .subject)
        try? container.encodeIfPresent(self.notes, forKey: .notes)
        try? container.encodeIfPresent(self.email, forKey: .emailAddress)
        try? container.encodeIfPresent(self.countryCode, forKey: .countryCode)
        try? container.encodeIfPresent(self.source, forKey: .source)
    }
    
    func linkFamilyMember(recordingId: Int, completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: PatientRouter.linkFamilyMember(self, recordingId)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    func getInTouch(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: PatientRouter.getInTouch(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
}
