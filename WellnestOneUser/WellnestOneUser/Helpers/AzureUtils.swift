//
//  AzureUtils.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 14/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import SDWebImage
class AzureUtil {
    static let shared = AzureUtil()

    func uploadProfilePhoto(profileId: String, sasToken: String, image: UIImage, completion: @escaping ErrorCompletionHandler) {
        
        if let img = image.sd_resizedImage(with: CGSize(width: 400, height: 400), scaleMode: .aspectFill), let data = img.jpegData(compressionQuality: 1) {
            
            var request = URLRequest(url: URL(string: "\(AppConfiguration.azureBaseUrl)/wellnest-one-profile-images/\(profileId)\(sasToken)")!,timeoutInterval: Double.infinity)

            request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")

            request.httpMethod = "PUT"
            request.httpBody = data
            
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                SDImageCache.shared.store(img, forKey: "\(AppConfiguration.azureBaseUrl)/wellnest-one-profile-images/\(profileId)", completion: nil)
                completion(error)
            }

            task.resume()
        }
    }
    
        func uploadSignature(profileId: Int, sasToken: String, image: UIImage, completion: @escaping ErrorCompletionHandler) {
            let resized = image.size.height * 400 / image.size.width
            if let img = image.sd_resizedImage(with: CGSize(width: 400, height: resized), scaleMode: .aspectFill), let data = img.jpegData(compressionQuality: 1) {
                
                var request = URLRequest(url: URL(string: "\(AppConfiguration.azureBaseUrl)/signatures/\(profileId)\(sasToken)")!,timeoutInterval: Double.infinity)
                
                request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
                request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                
                request.httpMethod = "PUT"
                request.httpBody = data
                
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    SDImageCache.shared.store(img, forKey: request.url?.path, completion: nil)
                    completion(error)
                }
                
                task.resume()
            }
        }

    public func saveToECGRRecordingContainer(uuid: String, sasToken: String, recordingData : Data, contentType: String = "text/plain", errorCallback: @escaping ErrorCompletionHandler) {
        var request = URLRequest(url: URL(string: "\(AppConfiguration.azureBaseUrl)/ecg-recordings/\(uuid)\(sasToken)")!,timeoutInterval: Double.infinity)

        request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")

        request.httpMethod = "PUT"
        request.httpBody = recordingData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            errorCallback(error)
          
        }

        task.resume()
    }
    
    func getRecordingData(sasToken : String, uuid: String, dataCallback: @escaping ObjectCompletionHandler<Data>) {
        
        let semaphore = DispatchSemaphore (value: 0)
        
        var request = URLRequest(url: URL(string: "\(AppConfiguration.azureBaseUrl)/ecg-recordings/\(uuid)\(sasToken)")!,timeoutInterval: Double.infinity)

        request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "GET"
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            semaphore.signal()
            dataCallback(data, error)
        }

        task.resume()
        semaphore.wait()
//
//        do {
//            let credentials = AZSStorageCredentials.init(sasToken: sasToken, accountName: AppConfiguration.azureStorageName)
//            let account = try AZSCloudStorageAccount.init(credentials: credentials, useHttps: true)
//            let blobClient = account.getBlobClient()
//            let blobContainer : AZSCloudBlobContainer = blobClient.containerReference(fromName: "ecg-recordings")
//            let blockBlob = blobContainer.blockBlobReference(fromName: uuid)
//            blockBlob.downloadToData { (error, data) in
//                dataCallback(data, error)
//            }
//        } catch {
//            print("Unable to find Azure account. ")
//        }
        
    }

    func getProfileImageURL(id: String, sasToken: String) -> String {
        let urlString = "\(AppConfiguration.azureBaseUrl)/wellnest-one-profile-images/" + "\(id)" + sasToken
        return urlString
    }

    func getSignatureImageURL(id: Int, sasToken: String) -> String {
        let urlString = "\(AppConfiguration.azureBaseUrl)/signatures/" + "\(id)" + sasToken
        return urlString
    }
    
    func isRecordingExists(sasToken: String, uuid: String, dataCallback: @escaping ObjectCompletionHandler<Int>) {
        
        var request = URLRequest(url: URL(string: "\(AppConfiguration.azureBaseUrl)/ecg-recordings/\(uuid)\(sasToken)")!,timeoutInterval: Double.infinity)
        request.httpMethod = "HEAD"
        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            let httpResponse = response as? HTTPURLResponse
            dataCallback(httpResponse?.statusCode, nil)
        }

        task.resume()
    }
}
