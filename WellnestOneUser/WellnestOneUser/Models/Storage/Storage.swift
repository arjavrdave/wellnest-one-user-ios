//
//  SASToken.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 14/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import Alamofire

protocol IStorage : Codable {
    var sasToken : String? { get set }
    var id: Int? { get set }
    var fileName: String? { get set }
    func getUploadTokenForUser(completion: @escaping ObjectCompletionHandler<Storage>)
    func getReadTokenForUser(completion: @escaping ObjectCompletionHandler<Storage>)
    func getUploadTokenForECG(completion: @escaping ObjectCompletionHandler<Storage>)
    func getReadTokenForECG(completion: @escaping ObjectCompletionHandler<Storage>)
    func getReadTokenForSignature(completion: @escaping ObjectCompletionHandler<Storage>)
}

class Storage : NSObject, IStorage {
    
    var sasToken: String?
    var id : Int?
    var fileName : String?
    
    private let alamoRequest: IAlamoRequest?
    
    init(_ _alamoRequest: IAlamoRequest){
        alamoRequest = _alamoRequest
    }

    required init(from decoder: Decoder) throws {
        self.alamoRequest = Initializers.shared.container.resolve(IAlamoRequest.self)
        
        let container       = try? decoder.container(keyedBy: CodingKeys.self)
        self.id             = try container?.decodeIfPresent(Int.self, forKey: .id)
        self.sasToken       = try container?.decodeIfPresent(String.self, forKey: .sasToken)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case fileName
        case sasToken
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.fileName, forKey: .fileName)
    }
    
    
    func getUploadTokenForUser(completion: @escaping ObjectCompletionHandler<Storage>) {
        self.alamoRequest?.makeRequest(url: StorageRouter.getUploadTokenForUser(self)).responseString(completionHandler: { (response) in
            var storage : Storage?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    storage = jsonString.convertJSONToClass(type: Storage.self)
                }
            }
            completion(storage, response.getError())
        })
    }
    
    func getReadTokenForUser(completion: @escaping ObjectCompletionHandler<Storage>) {
        self.alamoRequest?.makeRequest(url: StorageRouter.getReadTokenForUser(self)).responseString(completionHandler: { (response) in
            var storage : Storage?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    storage = jsonString.convertJSONToClass(type: Storage.self)
                }
            }
            completion(storage, response.getError())
        })
    }
    
    func getUploadTokenForECG(completion: @escaping ObjectCompletionHandler<Storage>) {
        self.alamoRequest?.makeRequest(url: StorageRouter.getUploadTokenForECG(self)).responseString(completionHandler: { (response) in
            var storage : Storage?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    storage = jsonString.convertJSONToClass(type: Storage.self)
                }
            }
            completion(storage, response.getError())
        })

    }
    
    func getReadTokenForECG(completion: @escaping ObjectCompletionHandler<Storage>) {
        self.alamoRequest?.makeRequest(url: StorageRouter.getReadTokenForECG(self)).responseString(completionHandler: { (response) in
            var storage : Storage?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    storage = jsonString.convertJSONToClass(type: Storage.self)
                }
            }
            completion(storage, response.getError())
        })
    }
    
    func getReadTokenForSignature(completion: @escaping ObjectCompletionHandler<Storage>) {
        self.alamoRequest?.makeRequest(url: StorageRouter.getReadTokenForSignature(self)).responseString(completionHandler: { (response) in
            var storage : Storage?
            if response.result.isSuccess {
                if let jsonString = response.result.value {
                    storage = jsonString.convertJSONToClass(type: Storage.self)
                }
            }
            completion(storage, response.getError())
        })
    }

}
