//
//  UserMedicalHistory.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 10/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation

protocol IUserMedicalHistory: Codable {
    var patientId: Int? { get set }
    var bloodPressure: Bool? { get set }
    var diabetes: Bool? { get set }
    var hypothyroidism: Bool? { get set }
    var lipidsIssue: Bool? { get set }
    var kidneyProblem: Bool? { get set }
    var stroke: Bool? { get set }
    var heartProblem: Bool? { get set }
    var siblingHeartProblem: Bool? { get set }
    var healthComment: String? { get set }
    
    func updateMedicalHistory(completion: @escaping ErrorCompletionHandler)
    func getMedicalHistory(completion: @escaping ObjectCompletionHandler<UserMedicalHistory>)
}

class UserMedicalHistory: NSObject, IUserMedicalHistory {
    
    var patientId: Int?
    var bloodPressure: Bool?
    var diabetes: Bool?
    var hypothyroidism: Bool?
    var lipidsIssue: Bool?
    var kidneyProblem: Bool?
    var stroke: Bool?
    var heartProblem: Bool?
    var siblingHeartProblem: Bool?
    var healthComment: String?

    private let alamoRequest: IAlamoRequest?
    
    init(_ _alamoRequest: IAlamoRequest){
        alamoRequest = _alamoRequest
    }

    required init(from decoder: Decoder) throws {
        self.alamoRequest = Initializers.shared.container.resolve(IAlamoRequest.self)

        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.bloodPressure = try? container?.decodeIfPresent(Bool.self, forKey: .bloodPressure)
        self.diabetes = try? container?.decodeIfPresent(Bool.self, forKey: .diabetes)
        self.hypothyroidism = try? container?.decodeIfPresent(Bool.self, forKey: .hypothyroidism)
        self.lipidsIssue = try? container?.decodeIfPresent(Bool.self, forKey: .lipidsIssue)
        self.kidneyProblem = try? container?.decodeIfPresent(Bool.self, forKey: .kidneyProblem)
        self.stroke = try? container?.decodeIfPresent(Bool.self, forKey: .stroke)
        self.heartProblem = try? container?.decodeIfPresent(Bool.self, forKey: .heartProblem)
        self.siblingHeartProblem = try? container?.decodeIfPresent(Bool.self, forKey: .siblingHeartProblem)
        self.healthComment = try? container?.decodeIfPresent(String.self, forKey: .healthComment)

    }

    enum CodingKeys: String, CodingKey {
        case bloodPressure
        case diabetes
        case hypothyroidism
        case lipidsIssue
        case kidneyProblem
        case stroke
        case heartProblem
        case siblingHeartProblem
        case healthComment
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(bloodPressure, forKey: .bloodPressure)
        try? container.encodeIfPresent(diabetes, forKey: .diabetes)
        try? container.encodeIfPresent(hypothyroidism, forKey: .hypothyroidism)
        try? container.encodeIfPresent(lipidsIssue, forKey: .lipidsIssue)
        try? container.encodeIfPresent(kidneyProblem, forKey: .kidneyProblem)
        try? container.encodeIfPresent(stroke, forKey: .stroke)
        try? container.encodeIfPresent(heartProblem, forKey: .heartProblem)
        try? container.encodeIfPresent(siblingHeartProblem, forKey: .siblingHeartProblem)
        try? container.encodeIfPresent(healthComment, forKey: .healthComment)
    }
        
    func updateMedicalHistory(completion: @escaping ErrorCompletionHandler) {
        self.alamoRequest?.makeRequest(url: UserMedicalHistoryRouter.updateMedicalHistory(self)).responseString(completionHandler: { (response) in
            completion(response.getError())
        })
    }
    func getMedicalHistory(completion: @escaping ObjectCompletionHandler<UserMedicalHistory>) {
        self.alamoRequest?.makeRequest(url: UserMedicalHistoryRouter.getMedicalHistory(self)).responseString(completionHandler: { (response) in
            var userMedicalHistory : UserMedicalHistory?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    userMedicalHistory = jsonString.convertJSONToClass(type: UserMedicalHistory.self)
                }
            }
            completion(userMedicalHistory, response.getError())
        })
    }
}
