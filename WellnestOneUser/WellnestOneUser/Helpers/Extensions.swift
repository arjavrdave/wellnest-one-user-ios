//
//  Extension.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 24/04/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import WellnestBLE
extension String {
    func convertJSONToClass<T: Decodable>(type: T.Type) -> T? {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(type, from: self.data(using: .utf8)!)
    }
    
    func convertJSONToDictionary() -> [String: Any]? {
        if let jsonData = self.data(using: .utf8) {
            if let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) {
                return json as? [String : Any]
            }
        }
        return nil
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func formateOnlyNumbers() -> String {
        let numbersOnly = self.trim().components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        return numbersOnly
    }

}

extension URL {
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}

extension String {
    func separate(every: Int, with separator: String) -> String {
            return String(stride(from: 0, to: Array(self).count, by: every).map {
                Array(Array(self)[$0..<min($0 + every, Array(self).count)])
            }.joined(separator: separator))
        }
}

extension Encodable {
    func convertToJSONEncoder() -> Data? {
        let encoder: JSONEncoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(self)
    }
    
    func convertEnocodeToJSON() -> String? {
        if let jsonData = self.convertToJSONEncoder() {
            let jsonString = String(decoding: jsonData, as: UTF8.self)
            return jsonString
        }
        return nil
    }
}


public extension Int {
    /// returns number of digits in Int number
    var digitCount: Int {
        get {
            return numberOfDigits(in: self)
        }
    }
    /// returns number of useful digits in Int number
    var usefulDigitCount: Int {
        get {
            var count = 0
            for digitOrder in 0..<self.digitCount {
                /// get each order digit from self
                let digit = self % (Int(truncating: pow(10, digitOrder + 1) as NSDecimalNumber))
                / Int(truncating: pow(10, digitOrder) as NSDecimalNumber)
                if isUseful(digit) { count += 1 }
            }
            return count
        }
    }
    // private recursive method for counting digits
    private func numberOfDigits(in number: Int) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
    // returns true if digit is useful in respect to self
    private func isUseful(_ digit: Int) -> Bool {
        return (digit != 0) && (self % digit == 0)
    }
}

extension Data {
    func convertDataToDictionary() -> [String: Any]? {
        if let dict = try? JSONSerialization.jsonObject(with: self, options: []) {
            return dict as? [String : Any]
        }
        return nil
    }
    func convertDataToJSON() -> String? {
        let jsonString = String(decoding: self, as: UTF8.self)
        return jsonString
    }
    func convertDataToClass<T: Decodable>(type: T.Type) -> T? {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(type, from: self)
    }
    func parseData() -> [[Double]] {
        let arr = [UInt8](self)
        var finalArr = [[Double]]()
        var innerArr = [Double]()
        for a in arr {
            innerArr.append(Double(a))
            if(innerArr.count == 16) {
                finalArr.append(innerArr)
                innerArr = [Double]()
            }
        }
        let chartsData = DataParser().setUpDataForRecording(finalArr);
        var sublist = [[Double]]()
        for j in 0..<12{
            sublist.append([Double]())
            for i in 0..<chartsData.count{
                sublist[j].append(chartsData[i][j])
            }
        }
        return sublist;
    }
}

extension Date {
    
    var timeIntervalInMiliSeconds: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    static var dateFormatter: DateFormatter {
        get {
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            return df
        }
    }
    
    static var iso8601DateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return formatter
    }


    var printableValue: String {
        return Date.dateFormatter.string(from: self)
    }

}

extension Dictionary {
    func convertToJSON() -> String? {
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            return jsonData.convertDataToJSON()
        }
        return nil
    }
    func convertDictionaryToClass<T: Decodable>(type: T.Type) -> T? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            return jsonData.convertDataToClass(type: T.self)
        }
        return nil
    }
}

extension UIColor {
    class func colorFrom(hexString: String) -> UIColor {
        var hex = hexString.trim().uppercased()
        
        if hex.contains("#") {
            hex = hex.replacingOccurrences(of: "#", with: "")
        } else if hex.contains("0X") {
            hex = hex.replacingOccurrences(of: "0X", with: "")
        }
        
        if hex.isEmpty || hex.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: hex).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIImage {
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}


extension UIImage {
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

extension DataResponse {
    
    func getError() -> Error? {
        if self.result.isSuccess {
            return nil
        }
        
        if let unknownData = self.data {
            if let unknowString = String(data: unknownData, encoding: .utf8) {
                if self.response?.statusCode == 400 {
                    if let update = unknowString.convertJSONToClass(type: UpdateRequired.self) {
                        if update.isOldVersion == true {
                            let error = NSError(domain: NSCocoaErrorDomain, code: self.response?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "FORCE_UPDATE", "updateRequired": update]) as Error
                            return error
                        }
                    }
                }
                if let bearer = unknowString.convertJSONToClass(type: BearerToken.self) {
                    if let errorText = bearer.text {
                        
                        let error = NSError(domain: NSCocoaErrorDomain, code: self.response?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: errorText]) as Error
                        return error
                    }
                }
            }
        }
        if self.response?.statusCode == 401 {
            let error = NSError(domain: NSCocoaErrorDomain, code: self.response?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "There was an unauthenticated request made. Please logout and login again."]) as Error
            return error
        } else if self.response?.statusCode == 500 {
            let error = NSError(domain: NSCocoaErrorDomain, code: self.response?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "Internal server error. Please try again later."]) as Error
            return error
        }
        return self.result.error
    }
}

extension UIView {
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}

extension UIImage {
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard
            let context = UIGraphicsGetCurrentContext()
        else {
            return nil
        }
        imageView.layer.render( in: context)
        guard
            let result = UIGraphicsGetImageFromCurrentImageContext()
        else {
            return nil
        }
        UIGraphicsEndImageContext()
        return result
    }
}



extension UIImage {
    
    public class func gifImageWithData(_ data: Data, duration: Double) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source, duration: duration)
    }
    
    public class func gifImageWithURL(_ gifUrl:String,duration : Double) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData, duration: duration)
    }
    
    public class func gifImageWithName(_ name: String, duration: Double) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData, duration: duration)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        
        let gifProperties: CFDictionary = unsafeBitCast(
                        CFDictionaryGetValue(cfProperties,
                        Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
                        to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
                        CFDictionaryGetValue(gifProperties,
                        Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                        to: AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
            Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b
            } else if a != nil {
                return a
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a % b
            
            if rest == 0 {
                return b
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource, duration: Double) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * duration * 100.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        return animation
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

extension UITableView {
    func reloadTableViewAtSamePosition() {
        let contentOffset = self.contentOffset
        self.reloadData()
        self.layoutIfNeeded()
        self.setContentOffset(contentOffset, animated: false)
    }
}
extension Array where Element == Double {
    func median() -> Double {
        let sortedArray = sorted()
        if count % 2 != 0 {
            return Double(sortedArray[count / 2])
        } else {
            return Double(sortedArray[count / 2] + sortedArray[count / 2 - 1]) / 2.0
        }
    }
}
extension UILabel {

    func addImageWith(name: String, behindText: Bool) {

        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        let attachmentString = NSAttributedString(attachment: attachment)

        guard let txt = self.text else {
            return
        }

        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }

    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}
