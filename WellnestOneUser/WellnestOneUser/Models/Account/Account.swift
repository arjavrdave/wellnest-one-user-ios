//
//  Account.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 07/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftJWT

protocol IAccount : Codable {
    var phoneNumber : String? { get set }
    var code        : String? { get set }
    var email       : String? { get set }
    var firstName   : String? { get set }
    var lastName    : String? { get set }
    var gender      : String? { get set }
    var id          : Int?    { get set }
    var profileId   : String?    { get set }
    var countryCode : Int?    { get set }
    var fullName    : String? { get set }
    var fcmToken    : String? { get set }
    var dateOfBirth : String? { get set }
    var age         : Int? { get set }
    var height : Double? { get set }
    var heightUnit : String? { get set }
    var weight : Double? { get set }
    var weightUnit : String? { get set }
    var bmi : Double? { get set }
    var smoking : String? { get set }
    var tobaccoUse : String? { get set }
    var exerciseLevel : String? { get set }
    var userMedicalHistory : IUserMedicalHistory? { get set }
    
    func createProfile (completion: @escaping ErrorCompletionHandler)
    func login(completion: @escaping ErrorCompletionHandler)
    func verifyOTP (completion: @escaping ObjectCompletionHandler<IBearerToken>)
    func resendVerificationOTP (completion: @escaping ErrorCompletionHandler)
    func linkFamilyMember (recordingId: Int, completion: @escaping ErrorCompletionHandler)
    
    func getInTouch(completion: @escaping ErrorCompletionHandler)
    func getAccount (completion: @escaping ObjectCompletionHandler<Account>)
    func logout(completion: @escaping ErrorCompletionHandler)
    func deleteAccount(completion: @escaping ErrorCompletionHandler)
}

class Account : NSObject, IAccount {
    
    var code : String?
    
    var fcmToken: String?
        
    var gender: String?
    
    var id: Int?
    
    var profileId: String?
    
    var phoneNumber: String?
    
    var email: String?
    
    var firstName: String?
    
    var lastName: String?
    
    var countryCode: Int? = 91
    
    var fullName: String? {
        get {
            let first = (self.firstName?.capitalizingFirstLetter() ?? "") + " "
            let last = (self.lastName?.capitalizingFirstLetter() ?? "")
            return first + last
        } set {
            
        }
    }
    
    var dateOfBirth : String?
    
    var age: Int?
    
    var height: Double?
    
    var heightUnit: String?
    
    var weight: Double?
    
    var weightUnit: String?
    
    var bmi: Double?
    
    var smoking: String?
    
    var tobaccoUse: String?
    
    var exerciseLevel: String?
    
    var userMedicalHistory: IUserMedicalHistory?
    
    private let alamoRequest: IAlamoRequest?
    
    init(_ _alamoRequest: IAlamoRequest){
        alamoRequest = _alamoRequest
    }

    required init(from decoder: Decoder) throws {
        self.alamoRequest = Initializers.shared.container.resolve(IAlamoRequest.self)
        
        let container       = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.firstName      = try container?.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName       = try container?.decodeIfPresent(String.self, forKey: .lastName)
        self.phoneNumber    = try container?.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.countryCode    = try container?.decodeIfPresent(Int.self, forKey: .countryCode)
        self.gender         = try container?.decodeIfPresent(String.self, forKey: .gender)
        self.id             = try container?.decodeIfPresent(Int.self, forKey: .id)
        self.profileId      = try container?.decodeIfPresent(String.self, forKey: .profileId)
        self.email          = try container?.decodeIfPresent(String.self, forKey: .email)
        self.dateOfBirth    = try? container?.decodeIfPresent(String.self, forKey: .dateOfBirth)
        self.height         = try? container?.decodeIfPresent(Double.self, forKey: .height)
        self.heightUnit     = try? container?.decodeIfPresent(String.self, forKey: .heightUnit)
        self.weight         = try? container?.decodeIfPresent(Double.self, forKey: .weight)
        self.weightUnit     = try? container?.decodeIfPresent(String.self, forKey: .weightUnit)
        self.bmi            = try? container?.decodeIfPresent(Double.self, forKey: .bmi)
        self.smoking        = try? container?.decodeIfPresent(String.self, forKey: .smoking)
        self.tobaccoUse     = try? container?.decodeIfPresent(String.self, forKey: .tobaccoUse)
        self.exerciseLevel  = try? container?.decodeIfPresent(String.self, forKey: .exerciseLevel)
        self.age            = try? container?.decodeIfPresent(Int.self, forKey: .age)
        if let medicalHistory = try? container?.superDecoder(forKey: .medicalHstory) {
            self.userMedicalHistory = try? UserMedicalHistory.init(from: medicalHistory)
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case code
        case firstName
        case lastName
        case countryCode
        case phoneNumber
        case gender
        case id
        case fullName
        case fcmToken
        case dateOfBirth
        case height
        case heightUnit
        case weight
        case weightUnit
        case bmi
        case smoking
        case tobaccoUse
        case exerciseLevel
        case medicalHstory
        case age
        case profileId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.code, forKey: .code)
        try container.encodeIfPresent(self.email?.lowercased()  , forKey: .email)
        try container.encodeIfPresent(self.firstName, forKey: .firstName)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(self.gender, forKey: .gender)
        try container.encodeIfPresent(self.fullName, forKey: .fullName)
        try container.encodeIfPresent(self.countryCode, forKey: .countryCode)
        try container.encodeIfPresent(self.id , forKey: .id)
        try container.encodeIfPresent(self.fcmToken, forKey: .fcmToken)
        try container.encodeIfPresent(self.dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(self.height, forKey: .height)
        try container.encodeIfPresent(self.heightUnit, forKey: .heightUnit)
        try container.encodeIfPresent(self.weight, forKey: .weight)
        try container.encodeIfPresent(self.weightUnit, forKey: .weightUnit)
        try container.encodeIfPresent(self.smoking, forKey: .smoking)
        try container.encodeIfPresent(self.tobaccoUse, forKey: .tobaccoUse)
        try container.encodeIfPresent(self.exerciseLevel, forKey: .exerciseLevel)
        try container.encodeIfPresent(self.age, forKey: .age)
        try container.encodeIfPresent(self.profileId, forKey: .profileId)
        if let medicalHistory = self.userMedicalHistory as? UserMedicalHistory {
            try medicalHistory.encode(to: container.superEncoder(forKey: .medicalHstory))
        }
    }
    func login(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: AccountRouter.login(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    func verifyOTP(completion: @escaping ObjectCompletionHandler<IBearerToken>) {
        self.alamoRequest?.makeRequest(url: AccountRouter.verifyOTP(self)).responseString(completionHandler: { (response) in
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    if let bearerToken = jsonString.convertJSONToClass(type: BearerToken.self){
                        bearerToken.saveToken()
                    }
                }
            }
            completion(nil, response.getError())
        })
    }
    func resendVerificationOTP(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: AccountRouter.resendVerificationCode(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    func createProfile(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: AccountRouter.createProfile(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    func getAccount(completion: @escaping ObjectCompletionHandler<Account>) {
        self.alamoRequest?.makeRequest(url: AccountRouter.getAccount(self)).responseString(completionHandler: { (response) in
            var account : Account?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    account = jsonString.convertJSONToClass(type: Account.self)
                }
            }
            completion(account, response.getError())

        })
    }
    
    func deleteAccount(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: AccountRouter.deleteAccount(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    
    func linkFamilyMember(recordingId: Int, completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: AccountRouter.linkFamilyMember(self, recordingId)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    
    //TODO: NOT USED YET
    func getInTouch(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: AccountRouter.getInTouch(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }

    
    func logout(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: AccountRouter.logout(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    
    
}

