//
//  UIViewUtils.swift
//  SameHere
//
//  Created by Mayank Verma on 03/02/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable
class UIViewShadow: UIView {
    
    @IBInspectable var cornerRadius : CGFloat = 0.0 {
        didSet {
            UpdateUI()
        }
    }
    @IBInspectable var shadowOpacity : Float = 0.0 {
        didSet {
            UpdateUI()
        }
    }

    @IBInspectable var borderWidth : CGFloat = 0.0 {
        didSet {
            UpdateUI()
        }
    }
    
    @IBInspectable var shadowWidth : CGFloat = 0.0 {
        didSet {
            UpdateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        UpdateUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        UpdateUI()
    }
    
    func UpdateUI() {
        self.clipsToBounds = true
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = self.shadowOpacity
        self.layer.shadowRadius = self.shadowWidth
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = self.borderWidth
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        UpdateUI()
    }
}

@IBDesignable class ViewWithGraph: UIView {
    @IBOutlet weak var lblGraphName: UILabel!
    @IBOutlet weak var leadingConstrait: NSLayoutConstraint!
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    var noDataText: String? {
        didSet {
            self.setUpNochartDataFound()
        }
    }
    private var noDataLabel: UILabel?
    func inputWithData(data: [Double]) {
        self.noDataText = nil
        if let image = UIImage(named: "feedback_graph_bg")?.resizableImage(withCapInsets: .zero) {
            self.backgroundColor = UIColor(patternImage: image)
        }
        let multiplyingFactor = 3.0
        let bezierPath = UIBezierPath()
        let width = (self.layer.frame.width) / min(5000.0, CGFloat(data.count - 1))
        for z in 0...data.count - 1 {
            if z == 0{
                bezierPath.move(to: CGPoint(x: (CGFloat(z) * width), y: (self.frame.height * 0.5) - (data[z] * multiplyingFactor)))
            }else{
                bezierPath.addLine(to: CGPoint(x: (CGFloat(z) * width), y: (self.frame.height * 0.5) - (data[z] * multiplyingFactor)))
            }
        }
        let shapeLayer = CAShapeLayer()
        
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        shapeLayer.path = bezierPath.cgPath
        
        // apply other properties related to the path
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        // add the new layer to our custom view
        self.layer.addSublayer(shapeLayer)
        
    }
    func setUpNochartDataFound() {
        if let noDataText = noDataText {
            self.backgroundColor = UIColor.clear
            if let noDataLabel = noDataLabel {
                noDataLabel.isHidden = false
                noDataLabel.text = noDataText
            } else {
                let hCenterOffset = (UIScreen.main.bounds.width - self.frame.width) / 2
                let lblNoData = UILabel()
                self.addSubview(lblNoData)
                lblNoData.translatesAutoresizingMaskIntoConstraints = false
                lblNoData.text = noDataText
                lblNoData.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
                lblNoData.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: hCenterOffset).isActive = true
                
                self.noDataLabel = lblNoData
            }
        } else {
            self.noDataLabel?.isHidden = true
        }
    }
    
    func moveLabel(offset: CGFloat) {
        self.leadingConstrait.constant = offset + 10.0
    }
    
}
extension UIView {
    
    /** This is the function to get subViews of a view of a particular type
     */
//    func subViews<T : UIView>(type : T.Type) -> [T]{
//        var all = [T]()
//        for view in self.subviews {
//            if let aView = view as? T{
//                all.append(aView)
//            }
//        }
//        return all
//    }
    
    
    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T {
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

