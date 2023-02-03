//
//  PDFGenerator.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 28/11/22.
//

import Foundation
import UIKit
class PDFGenerator {
    
    var pathName: String?
    
    func getPDfPath(user: Patient, recording: Recordings, signatureImage: UIImage?, reportedBy: Doctor?) -> String {
        if let pathName = self.pathName {
            return pathName
        } else {
            let pathname = NSTemporaryDirectory().appending("ECGReport_\(user.patientFirstName?.capitalizingFirstLetter() ?? "")_\(recording.pdfDate).pdf")
            
            UIGraphicsBeginPDFContextToFile(pathname, .zero, nil)
            
            if let recordingData = recording.recordingRawData?.parseData() {
                self.GeneratePDFPage(user: user, recordingData: recordingData, recording: recording, signatureImage: signatureImage, reportedBy: reportedBy)
            }
            UIGraphicsEndPDFContext()
            
            self.pathName = pathname
            return pathname
        }
    }
    private func GeneratePDFPage(user : Patient, recordingData: [[Double]], recording: IRecordings, signatureImage: UIImage?, reportedBy: Doctor?) {
        
        var pdfFrame = CGRect()
        var end = 0
        var start = 0
        
        let longGraphEnd = min(5000, recordingData[1].count-1)
        
        let secondsBetweenPeaks = 60 / ((recording.bpm ?? 0) == 0 ? 60 : recording.bpm!)
        let points = 5000 * secondsBetweenPeaks / 10
        start = recordingData[0][1250...1250+points].firstIndex(of: recordingData[0][1250...1250+points].max()!)! - (points/2)
        end = min(start+1300, recordingData[0].count - 1)
        
        let dataToDisplay = [Array(recordingData[0][start...end]), Array(recordingData[1][start...end]), Array(recordingData[2][start...end]),Array(recordingData[3][start...end]), Array(recordingData[4][start...end]), Array(recordingData[5][start...end]),Array(recordingData[6][start...end]), Array(recordingData[7][start...end]), Array(recordingData[8][start...end]),Array(recordingData[9][start...end]), Array(recordingData[10][start...end]), Array(recordingData[11][start...end])]
        
        let multiplyingFactor : Double = 3
        
        pdfFrame = CGRect.init(x: 0, y: 0, width: CommonConfiguration.PDF_Width, height: CommonConfiguration.PDF_Height)
        var pointX : CGFloat = 25.0
        var pointY : CGFloat = pointX / 2
        
        
        let labelTitleHeight : CGFloat = 15
        let labelNormalWidth : CGFloat = 100
        let labelWideWidth : CGFloat = 150
        UIGraphicsBeginPDFPageWithInfo(pdfFrame, [:])
        
        let image = UIImage.init(named: "logo_report")!
        let imageRect = CGRect.init(x: pointX, y: pointY, width: image.size.width, height: image.size.height)
        image.draw(in: imageRect)
        
        pointY = 43
        
        let pointYLabel = pointY
        let title1Names = ["Name","Gender | Age","Date & Time"]
        
        for title in title1Names {
            let attr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Bold(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.colorFrom(hexString: "000000")]
            let title1String = NSMutableAttributedString(string: title, attributes: attr)
            let rect = CGRect.init(x: pointX, y: pointY, width: labelNormalWidth, height: labelTitleHeight)
            title1String.draw(in: rect)
            pointY += labelTitleHeight
        }
        
        pointY = pointYLabel
        pointX = pointX + labelNormalWidth + 10
        
        var title2Name = ["\(user.patientFirstName ?? "") \(user.patientLastName ?? "")"]
        if let ageString = user.age {
            title2Name.append("\(String(describing: user.patientGender?.capitalizingFirstLetter() ?? "")) | \(ageString)")
        } else {
            title2Name.append("")
            
        }
        title2Name.append(recording.displayDatewithTime)
        
        for title in title2Name {
            let attr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Bold(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.colorFrom(hexString: "000000")]
            let titleString = NSMutableAttributedString(string: title , attributes: attr)
            let rect = CGRect.init(x: pointX, y: pointY, width: labelWideWidth, height: labelTitleHeight)
            titleString.draw(in: rect)
            pointY += labelTitleHeight
        }
        
        pointY = pointYLabel
        pointX = pointX + labelWideWidth + 160
        let title3Name = ["Heart Rate","QRS","ST"]
        
        for title in title3Name {
            let attr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Regular(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.colorFrom(hexString: "666666")]
            let titleString = NSMutableAttributedString(string: title, attributes: attr)
            let rect = CGRect.init(x: pointX, y: pointY, width: labelNormalWidth, height: labelTitleHeight)
            titleString.draw(in: rect)
            pointY += labelTitleHeight
        }
        
        pointY = pointYLabel
        pointX = pointX + labelNormalWidth - 10
        
        var title4Name = [String]()
        if let bpm = recording.bpm {
            title4Name.append("\(bpm) bpm")
        } else {
            title4Name.append("0 bpm")
        }
        
        if let qrs = recording.qrs {
            title4Name.append("\(qrs) ms")
        } else {
            title4Name.append("0 ms")
        }
        
        if let st = recording.st {
            title4Name.append("\(st) ms")
        } else {
            title4Name.append("0 ms")
        }
        
        for title in title4Name {
            let attr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Regular(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.colorFrom(hexString: "666666")]
            let titleString = NSMutableAttributedString(string: title, attributes: attr)
            let rect = CGRect.init(x: pointX , y: pointY, width: labelNormalWidth, height: labelTitleHeight)
            titleString.draw(in: rect)
            pointY += labelTitleHeight
        }
        
        pointY = pointYLabel
        pointX = pointX + labelNormalWidth
        let title5Name = ["QT","PR","QTc"]
        for title in title5Name {
            let attr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Regular(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.colorFrom(hexString: "666666")]
            let titleString = NSMutableAttributedString(string: title, attributes: attr)
            let rect = CGRect.init(x: pointX , y: pointY, width: labelNormalWidth, height: labelTitleHeight)
            titleString.draw(in: rect)
            pointY += labelTitleHeight
        }
        
        pointY = pointYLabel
        pointX = pointX + labelNormalWidth - 10
        
        var title6Name = [String]()
        if let qt = recording.qt {
            title6Name.append("\(qt) ms")
        } else {
            title6Name.append("0 ms")
        }
        
        if let pr = recording.pr {
            title6Name.append("\(pr) ms")
        } else {
            title6Name.append("0 ms")
        }
        
        if let qtc = recording.qtc {
            title6Name.append("\(qtc) ms")
        } else {
            title6Name.append("0 ms")
        }
        
        for title in title6Name {
            let attr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Regular(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.colorFrom(hexString: "666666")]
            let titleString = NSMutableAttributedString(string: title, attributes: attr)
            let rect = CGRect.init(x: pointX, y: pointY, width: labelNormalWidth, height: labelTitleHeight)
            titleString.draw(in: rect)
            pointY += labelTitleHeight
        }
        pointY = pointY + 5
        
        let pointYCharts = pointY
        pointX = 25
        let oneBlockGapWidth : CGFloat = 15
        let backGraphImage = UIImage.init(named: "image_graph_back")
        let backGraphRect = CGRect.init(x: pointX, y: pointYCharts, width: (CommonConfiguration.PDF_Width - (pointX * 2)), height: (CommonConfiguration.PDF_Width - (pointX * 2)) / 2)
        backGraphImage?.draw(in: backGraphRect)
        
        var chartWidth : CGFloat = (CommonConfiguration.PDF_Width - (pointX * 2))
        chartWidth = chartWidth / 4
        
        let longChartWidth = (CommonConfiguration.PDF_Width - (pointX * 2))
        
        let chartHeight: CGFloat = 101.5
        var chartNames = ["L1", "L2", "L3", "aVR", "aVL", "aVF", "V1", "V2", "V3", "V4", "V5", "V6", "L2"]
        
        for row in 0..<4 {
            if row != 3 {
                for column in 0..<4 {
                    let bezierPath = UIBezierPath()
                    let width = (chartWidth - oneBlockGapWidth) / CGFloat(end - start)
                    let currentIndex = column * 3 + row
                    let data = dataToDisplay[currentIndex]
                    let (signals,avgFilter,_) = ThresholdAlgo.shared.ThresholdingAlgo(y: data, lag: 10, threshold: 3, influence: 0.2)
                    for x in 0...signals.count - 1 {
                        if x == 0{
                            bezierPath.move(to: CGPoint(x: pointX + 1 + (CGFloat(x) * width), y: pointY + (chartHeight / 2) - (avgFilter[x] * multiplyingFactor)))
                        }else{
                            bezierPath.addLine(to: CGPoint(x: pointX + 1  + (CGFloat(x) * width), y: pointY + (chartHeight / 2) - (avgFilter[x] * multiplyingFactor)))
                        }
                    }
                    UIColor.black.setStroke()
                    bezierPath.stroke()
                    
                    
                    let attr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Regular(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.black]
                    let titleString = NSMutableAttributedString(string: chartNames[currentIndex], attributes: attr)
                    let rect = CGRect.init(x: pointX + 5, y: pointY + 2, width: 20, height: 20)
                    titleString.draw(in: rect)
                    
                    pointX += chartWidth
                }
                pointX = 25
                pointY += chartHeight
            }
        }
        
        let bezierPath = UIBezierPath()
        let width = ((longChartWidth) - oneBlockGapWidth) / CGFloat(longGraphEnd)
        let data = Array(recordingData[1][...longGraphEnd])
        let (signals,avgFilter,_) = ThresholdAlgo.shared.ThresholdingAlgo(y: data, lag: 10, threshold: 3, influence: 0.2) // _  = stdFilter
        for x in 0...signals.count - 1 {
            if x == 0{
                bezierPath.move(to: CGPoint(x: pointX + 1 + (CGFloat(x) * width), y: pointY + (chartHeight / 2) - (avgFilter[x] * multiplyingFactor)))
            }else{
                bezierPath.addLine(to: CGPoint(x: pointX + 1  + (CGFloat(x) * width), y: pointY + (chartHeight / 2) - (avgFilter[x] * multiplyingFactor)))
            }
        }
        UIColor.black.setStroke()
        bezierPath.stroke()
        
        let attr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Regular(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.black]
        let titleString = NSMutableAttributedString(string: "L2", attributes: attr)
        let rect = CGRect.init(x: pointX + 5, y: pointY + 2, width: 20, height: 20)
        titleString.draw(in: rect)
        
        
        pointY += chartHeight
        
        pointX = 25
        
        var commentAttrS: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Bold(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.black]
        var commentsNSStringS = NSMutableAttributedString()
        commentsNSStringS = NSMutableAttributedString(string: "ECG findings", attributes: commentAttrS)
        var commentsRect1 = CGRect.init(x: pointX, y: pointY, width: 100, height: 15)
        commentsNSStringS.draw(in: commentsRect1)
        
        
        
        commentAttrS = [NSAttributedString.Key.font : UIFont.Roboto_Bold(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.black]
        commentsNSStringS = NSMutableAttributedString()
        commentsNSStringS = NSMutableAttributedString(string: "Findings Interpretation", attributes: commentAttrS)
        commentsRect1 = CGRect.init(x: pointX + 160, y: pointY, width: 200, height: 15)
        commentsNSStringS.draw(in: commentsRect1)
        
        commentAttrS = [NSAttributedString.Key.font : UIFont.Roboto_Bold(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.black]
        commentsNSStringS = NSMutableAttributedString()
        commentsNSStringS = NSMutableAttributedString(string: "Recommendations", attributes: commentAttrS)
        commentsRect1 = CGRect.init(x: pointX + 380, y: pointY, width: 100, height: 15)
        commentsNSStringS.draw(in: commentsRect1)
        
        
        pointX = 25
        let commentAttr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Regular(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        //            var aiResponseNSString = NSMutableAttributedString()
        var ecgFindingsNSString = NSMutableAttributedString()
        var interpretationsNSString = NSMutableAttributedString()
        var recommendationsNSString = NSMutableAttributedString()
        
        //            if let aiResponse = recording.aiResponse{
        //                let str = self.getTrimmedAiResponseString(str: aiResponse)
        //                aiResponseNSString = NSMutableAttributedString(string: str, attributes: commentAttr)
        //                if str.count > 80{
        //                    let aiResponseRect = CGRect.init(x: pointX + 90, y: pointY - 30, width: 540, height: 50)
        //                    aiResponseNSString.draw(in: aiResponseRect)
        //                }else{
        //                    let aiResponseRect = CGRect.init(x: pointX + 90, y: pointY - 20, width: 540, height: 50)
        //                    aiResponseNSString.draw(in: aiResponseRect)
        //                }
        //            }else{
        //                let aiResponseRect = CGRect.init(x: pointX + 90, y: pointY - 20, width: 540, height: 50)
        //                aiResponseNSString.draw(in: aiResponseRect)
        //            }
        
        //ecgFindings
        if let ecgFindings = recording.ecgFindings{
            
            let str = self.getTrimmedString(str: ecgFindings)
            ecgFindingsNSString = NSMutableAttributedString(string: str, attributes: commentAttr)
        }else {
            ecgFindingsNSString = NSMutableAttributedString(string: "-", attributes: commentAttr)
        }
        
        let commentsRect = CGRect.init(x: pointX, y: pointY + 20, width: 440, height: 72)
        ecgFindingsNSString.draw(in: commentsRect)
        
        //Interpretations
        if let interpretations = recording.interpretations{
            let str = self.getTrimmedString(str: interpretations)
            interpretationsNSString = NSMutableAttributedString(string: str, attributes: commentAttr)
        }else {
            interpretationsNSString = NSMutableAttributedString(string: "-", attributes: commentAttr)
        }
        let commentsRect2 = CGRect.init(x: pointX + 160, y: pointY + 20, width: 440, height: 72)
        interpretationsNSString.draw(in: commentsRect2)
        
        //Recommendations
        if let recommendations = recording.recommendations{
            let str = self.getTrimmedString(str: recommendations)
            recommendationsNSString = NSMutableAttributedString(string: str, attributes: commentAttr)
        }else {
            recommendationsNSString = NSMutableAttributedString(string: "-", attributes: commentAttr)
        }
        let commentsRect3 = CGRect.init(x: pointX + 380, y: pointY + 20, width: 440, height: 72)
        recommendationsNSString.draw(in: commentsRect3)
        
        
        pointX = 570
        
        
        let speedStr = "25 mm/sec"
        
        let amplitudeStr = "10 mm/mV"
        
        let setupStr = "Standard"
        
        let graphSetupStr: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Medium(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.black]
        let setupString = NSMutableAttributedString(string: "\(speedStr) \(amplitudeStr) \(setupStr)", attributes: graphSetupStr)
        
        var frameRect = CGRect.init(x: pointX + 50, y: pointY - 22, width: 450, height: 20)
        setupString.draw(in: frameRect)
        
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Bold(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.black]
        var reportTitleString = NSMutableAttributedString(string: "Reported By: ", attributes: attributes)
        frameRect = CGRect.init(x: pointX, y: pointY, width: 100, height: 20)
        reportTitleString.draw(in: frameRect)
        
        
        pointX += 70
        if let signature = signatureImage {
            let frameRect = CGRect.init(x: pointX + 20, y: pointY, width: 100, height: 45)
            signature.draw(in: frameRect)
        }
        
        pointX = 570
        pointY = pointY + 30
        if let fullName = reportedBy?.fullName {
            let qualification = reportedBy?.qualification ?? ""
            let str = self.getTrimmedString(str: qualification)
            let reportedByName = "\(fullName),\n\(str)"
            let attributes12: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Regular(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.black]
            let reportedByString = NSMutableAttributedString(string: reportedByName, attributes: attributes12)
            let frameRectReport = CGRect.init(x: pointX, y: pointY, width: 250, height: 40)
            reportedByString.draw(in: frameRectReport)
        }
        
        
        pointX = 25
        pointY = pointY + 40
        
        let lineView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: CommonConfiguration.PDF_Width - 50, height: 1))
        lineView.backgroundColor = UIColor.black
        let lineImage = lineView.asImage()
        let lineFrame = CGRect.init(x: pointX, y: pointY, width: CommonConfiguration.PDF_Width - 50, height: 1)
        lineImage.draw(in: lineFrame)
        
        
        pointX = 612
        pointY = 20
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = .right
        
        let attributesFor12Lead: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.Roboto_Regular(fontSize: 11), NSAttributedString.Key.foregroundColor : UIColor.colorFrom(hexString: "666666"), NSAttributedString.Key.paragraphStyle : paragraphStyle]
        reportTitleString = NSMutableAttributedString(string: "12 Lead Simultaneous ECG Report.", attributes: attributesFor12Lead)
        frameRect = CGRect.init(x: pointX, y: pointY, width: 200, height: 20)
        reportTitleString.draw(in: frameRect)
        
    }
    func findBlankSpaceNearAround(temp: String, seperator: Int) -> Int {
        if seperator + 5 >= temp.count {
            return temp.count - 1
        }
        let upperRange = temp.index(temp.startIndex, offsetBy: seperator)..<temp.index(temp.startIndex, offsetBy: seperator+5)
        if let index = temp[upperRange].firstIndex(of: " ") {
            return index.utf16Offset(in: temp)
        }
        let lowerRange = temp.index(temp.startIndex, offsetBy: seperator - 29)..<temp.index(temp.startIndex, offsetBy: seperator)
        if let index = temp[lowerRange].lastIndex(of: " ") {
            return index.utf16Offset(in: temp)
        }
        return seperator
    }
    
    func getTrimmedString(str: String) -> String {
        var modifiedStr = ""
        if str.count > 75 {
            modifiedStr = String(str[..<str.endIndex])
        } else {
            modifiedStr = str
        }
        
        var insertIndex = findBlankSpaceNearAround(temp: str, seperator: 30)
        while (insertIndex != str.count - 1) {
            let range = str.index(str.startIndex, offsetBy: insertIndex)...str.index(str.startIndex, offsetBy: insertIndex)
            modifiedStr = modifiedStr.replacingCharacters(in: range, with: "\n")
            insertIndex = findBlankSpaceNearAround(temp: str, seperator: insertIndex + 25)
        }
        return modifiedStr
    }
}
