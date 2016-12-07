//
//  OptionsView.swift
//  assetplus
//
//  Created by Sayeed Munawar Hussain on 09/10/16.
//  Copyright © 2016 Sayeed Munawar Hussain. All rights reserved.
//

import UIKit

class OptionsView: UIView {

    fileprivate weak var presentingView: UIView!
    fileprivate var dismissBlock : ((Int) -> ())!

    fileprivate var _options: [String]!
    fileprivate var _selectedIndex: Int?
    fileprivate var _dismissable: Bool

    fileprivate var dimView: UIView

    fileprivate var tableView: UITableView
    fileprivate var tableViewHeight: NSLayoutConstraint!
    fileprivate var tableViewTopSpaceToSuperView: NSLayoutConstraint!

    fileprivate let animationDuration: Double = 0.3

    deinit {
        print("OptionsView deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    convenience init(options opts: [String], dismissWithoutSelection dismissable: Bool) {
        self.init(options: opts, selectedIndex: nil, dismissWithoutSelection: dismissable)
    }

    convenience init(options opts: [String], selectedIndexNum: NSNumber?, dismissWithoutSelection dismissable: Bool) {
        self.init(options: opts, selectedIndex: selectedIndexNum as Int?, dismissWithoutSelection: dismissable)
    }

    init(options opts: [String], selectedIndex: Int?, dismissWithoutSelection dismissable: Bool = false) {

        _options = opts
        _selectedIndex = selectedIndex
        _dismissable = dismissable
        
        dimView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0.55
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 3.0
        tableView.clipsToBounds = true
        tableView.register(UINib(nibName: String(describing: OptionsViewTVCell.self), bundle: nil), forCellReuseIdentifier: String(describing: OptionsViewTVCell.self))
        tableView.separatorStyle = .none
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(OptionsView.orientationChanged(_:)), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func showInView(_ view: UIView,  completion: @escaping (Int) -> ()) {
        
        presentingView = view
        dismissBlock = completion

        view.addSubview(self)
        self.addSubview(dimView)
        self.addSubview(tableView)
        
        _layoutInView()
        _presentInView()

        //???***
        //Need to do a delayed dispatch or the selection doesn't show.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if let _ = self._selectedIndex {
                self._selectInitial()
            }
        }
        //???***
    }
    
    func orientationChanged(_ notification: Notification) {
        _adjustTableViewHeight()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Invalid init. Can't initialize from storyboard or xib.")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if _dismissable {
            _dismiss()
        }
    }
    
    fileprivate func _presentInView() {
        
        //force layout
        presentingView.setNeedsLayout()
        presentingView.layoutIfNeeded()

        //animate in
        self.alpha = 0
        UIView.animate(withDuration: animationDuration) {
            self.alpha = 1
        }
    }
    
    fileprivate func _dismiss() {
       
        //animate out
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 0
        }) { completed in
            self.removeFromSuperview()//remove
        }
    }
    
    fileprivate func _layoutInView() {
        
        //////////////self contraints////////////////////////////////////////////////////////////////////////////////////////////////
        var cons0 = [NSLayoutConstraint]()
        
        let ver0 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": self])
        let hor0 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": self])
        
        cons0 += ver0
        cons0 += hor0
        
        NSLayoutConstraint.activate(cons0)
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        ////////////////dimView constraints (same as self constraints as they have same dimensions)////////////////////////////////
        var cons1 = [NSLayoutConstraint]()
        
        let ver1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": dimView])
        let hor1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": dimView])
        
        cons1 += ver1
        cons1 += hor1
        
        NSLayoutConstraint.activate(cons1)
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        ////////////////tableView constraints/////////////////////////////////////////////////////////////////////////////////////
        let offsetX = 30.0 //gap on the left and right

        let isLandscape = _orientationIsLandscape(orientation: UIDevice.current.orientation)
        let tvHeight = _tableViewHeight(landscapeOrientation: isLandscape)
        let offsetY = _tableViewYOffset(tableViewHeight: tvHeight)
        
        var cons2 = [NSLayoutConstraint]()

        tableViewHeight = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: tvHeight)
        
        tableViewTopSpaceToSuperView = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: tableView.superview!, attribute: .top, multiplier: 1, constant: offsetY)
        
        cons2 += [tableViewHeight, tableViewTopSpaceToSuperView]
        
        let hor2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(offsetX)-[view]-\(offsetX)-|", options: [], metrics: nil, views: ["view": tableView])
        
        cons2 += hor2
        
        NSLayoutConstraint.activate(cons2)
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }
    
    fileprivate func _selectInitial() {
        tableView.selectRow(at: IndexPath(row: _selectedIndex!, section: 0), animated: false, scrollPosition: .none)
    }
    
    fileprivate func _orientationIsLandscape(orientation: UIDeviceOrientation) -> Bool {
        
        switch orientation {
            
        case .landscapeLeft:
            return true
        
        case .landscapeRight:
            return true
        
        default:
            return false
        }
    }
    
    fileprivate func _tableViewHeight(landscapeOrientation: Bool) -> CGFloat {
     
        let optionsRowHeight: CGFloat = 44.0 //row height
        
        let offsetY: CGFloat = landscapeOrientation ? 30.0 : 100.0 //gap on the top and bottom
        let optionsHeight = optionsRowHeight * CGFloat(_options.count)//tableView contentSize height
        let maxAllowedOptionsHeight = presentingView.frame.size.height - offsetY * 2.0//displayable height based on viewport height - top and bottom margins
        let finalHeight = optionsHeight < maxAllowedOptionsHeight ? optionsHeight : maxAllowedOptionsHeight//final height
        
        return finalHeight
    }
    
    fileprivate func _tableViewYOffset(tableViewHeight: CGFloat) -> CGFloat {
        return (presentingView.frame.size.height - tableViewHeight) / 2.0
    }
    
    fileprivate func _adjustTableViewHeight() {
        
        let isLandscape = _orientationIsLandscape(orientation: UIDevice.current.orientation)
        let tvHeight = _tableViewHeight(landscapeOrientation: isLandscape)
        let offsetY = _tableViewYOffset(tableViewHeight: tvHeight)
        
        tableViewHeight.constant = tvHeight
        tableViewTopSpaceToSuperView.constant = offsetY
    }
}

extension OptionsView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: OptionsViewTVCell.self), for: indexPath) as! OptionsViewTVCell
        cell.setTextValue(_options[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismissBlock(indexPath.row)
        _dismiss()
    }
}

