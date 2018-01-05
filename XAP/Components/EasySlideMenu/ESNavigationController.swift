
/*
* EasySlide
* ESNavigationController
*
* Author: Nathan Blamirs
* Copyright © 2016 Nathan Blamires. All rights reserved.
*/

import UIKit

class ESNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    // side view controllers
    fileprivate var leftMenuViewController = UIViewController()
    fileprivate var rightMenuViewController = UIViewController()
    fileprivate var mainContentOverlay: UIView = UIView()
    
    // autolayout
    fileprivate var leftTrailingConstraint: NSLayoutConstraint?
    fileprivate var rightLeadingConstraint: NSLayoutConstraint?

    // left menu
    fileprivate var leftMenuSet: Bool = false
    fileprivate var leftEnabled: Bool = true
    fileprivate var leftWidth: CGFloat = 300
    fileprivate var leftRevealType: RevealType = .slideUnder
    fileprivate var leftAnimationSpeed: CGFloat = 0.3
    fileprivate var leftShadowEnabled: Bool = true
    fileprivate var leftPanningEnabled: Bool = true
    
    // right menu
    fileprivate var rightMenuSet: Bool = false
    fileprivate var rightEnabled: Bool = true
    fileprivate var rightWidth: CGFloat = 300
    fileprivate var rightRevealType: RevealType = .slideUnder
    fileprivate var rightAnimationSpeed: CGFloat = 0.3
    fileprivate var rightShadowEnabled: Bool = true
    fileprivate var rightPanningEnabled: Bool = true

    // swipe access
    fileprivate var panLimitedAccess: Bool = false
    fileprivate var panAccessView: MenuType = .leftMenu
    fileprivate var leftPanAccessRange: CGFloat = 50
    fileprivate var rightPanAccessRange: CGFloat = 50
    
    // state tracking
    fileprivate var inactiveView: MenuType = .bothMenus
    fileprivate var panChangePoint: CGFloat = 0
    
    // MARK: Open/Close Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlay()
        let panSelector = #selector(ESNavigationController.panEventFired as (ESNavigationController) -> (UIPanGestureRecognizer) -> ())
        let panGestrure = UIPanGestureRecognizer(target: self, action: panSelector)
        panGestrure.delegate = self
        self.view.addGestureRecognizer(panGestrure)
    }

    fileprivate func setupOverlay(){
        
        // add the view
        self.view.addSubview(self.mainContentOverlay)
        
        // set attributes
        mainContentOverlay.isHidden = true
        mainContentOverlay.backgroundColor = UIColor.clear
        
        // add gestures
        let panSelector = #selector(ESNavigationController.panEventFired as (ESNavigationController) -> (UIPanGestureRecognizer) -> ())
        let panGestrure = UIPanGestureRecognizer(target: self, action: panSelector)
        mainContentOverlay.addGestureRecognizer(panGestrure)
        let tapSelector = #selector(ESNavigationController.automatedCloseOpenMenu as (ESNavigationController) -> () -> ())
        mainContentOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: tapSelector))
        
        // add constraints
        mainContentOverlay.translatesAutoresizingMaskIntoConstraints = false
        for attribute: NSLayoutAttribute in [.leading, .trailing, .top, .bottom]{
            self.view.addConstraint(NSLayoutConstraint(item: mainContentOverlay, attribute: attribute, relatedBy: .equal, toItem: self.view, attribute: attribute, multiplier: 1, constant: 0))
        }
    }

    // MARK: Setup Methods
    
    func setupMenuViewController(_ menu: MenuType, viewController: UIViewController){
        if self.isMenuOpen(menu) { self.closeOpenMenu(animated: false, completion: nil) }
        self.getMenuView(menu).removeFromSuperview()
        if (menu == .leftMenu) { self.leftMenuViewController = viewController; self.leftMenuSet = true }
        if (menu == .rightMenu) { self.rightMenuViewController = viewController; self.rightMenuSet = true  }
    }
    
    func setBodyViewController(_ viewController: UIViewController, closeOpenMenu:Bool, ignoreClassMatch:Bool){
        
        // get view controller types
        let rootType = Mirror(reflecting: self.viewControllers[0])
        let newType = Mirror(reflecting: viewController)

        // change vs if not the same class as the current one
        if(!ignoreClassMatch || rootType.subjectType != newType.subjectType){
            setViewControllers([viewController], animated: false)
        }
        if closeOpenMenu { self.closeOpenMenu(animated:true, completion: nil)}
    }
    
    // MARK: Open/Close Methods
    
    func openMenu(_ menu: MenuType, animated:Bool, completion:((Void)->(Void))?){
        if menu == .bothMenus { return }
        if self.isMenuEnabled(menu) && self.isMenuSet(menu) {
            self.menuSetup(menu)
            self.changeMenu(menu, animated: animated, percentage: 1.0, completion: completion);
        }
    }
    
    func closeOpenMenu(animated:Bool, completion:((Void)->(Void))?){
        let openMenu: MenuType = self.isMenuOpen(.leftMenu) ? .leftMenu : .rightMenu
        self.changeMenu(openMenu, animated: true, percentage: 0.0, completion: completion)
    }
    
    internal func automatedCloseOpenMenu(){
        self.closeOpenMenu(animated: true, completion: nil)
    }

    func isMenuOpen(_ menu: MenuType) -> Bool{
        return (self.inactiveView != .bothMenus && self.inactiveView != menu) ? true : false
    }
    
    // MARK: Private Open/Close Helper Methods
    
    fileprivate func changeMenu(_ menu: MenuType, animated: Bool, percentage: CGFloat, completion:((Void)->(Void))?){
        let speed = animated ? self.getMenuAnimationSpeed(menu) : 0
        self.animateLayoutChanges(menu, percentage: percentage, speed: speed, completion: completion)
    }
    
    fileprivate func animateLayoutChanges(_ menu: MenuType, percentage: CGFloat, speed: CGFloat, completion:((Void)->(Void))?){
        
        self.view.window?.layoutIfNeeded()
        self.menuLayoutChanges(menu, percentage: percentage)
        self.mainContentOverlay.isHidden = false
        
        // do animation
        UIView.animate(withDuration: Double(speed), delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            self.view.window?.layoutIfNeeded()
            self.menuManualViewChanges(menu, percentage: percentage)
            }) { (finished) -> Void in
                self.mainContentOverlay.isHidden = (percentage == 0) ? true : false
                self.inactiveView = (percentage == 1.0) ? self.getOppositeMenu(menu) : .bothMenus
                if percentage == 0.0 { self.menuCleanUp(menu) }
                completion?()
        }
    }
    
    fileprivate func addMenuToWindow(_ menu: MenuType){
        
        self.view.window?.insertSubview(self.getMenuView(menu), at: 0)
        if (self.getMenuRevealType(menu) == .slideOver){
            self.view.window?.bringSubview(toFront: self.getMenuView(menu))
        }
        
        self.getMenuView(menu).translatesAutoresizingMaskIntoConstraints = false
        if (menu == .leftMenu) {
            self.leftTrailingConstraint = NSLayoutConstraint(item: self.leftMenuViewController.view, attribute: .trailing, relatedBy: .equal, toItem: self.view.window!, attribute: .leading, multiplier: 1, constant: 0)
        } else {
            self.rightLeadingConstraint = NSLayoutConstraint(item: self.rightMenuViewController.view, attribute: .leading, relatedBy: .equal, toItem: self.view.window!, attribute: .trailing, multiplier: 1, constant:  0)
        }
        let widthConstraint = NSLayoutConstraint(item: self.getMenuView(menu), attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.getMenuWidth(menu));
        let topConstraint = NSLayoutConstraint(item: self.getMenuView(menu), attribute: .top, relatedBy: .equal, toItem: self.view.window!, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.getMenuView(menu), attribute: .bottom, relatedBy: .equal, toItem: self.view.window!, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.window?.addConstraints([self.getHorizontalConstraintForMenu(menu),widthConstraint,topConstraint,bottomConstraint]);
    }
    
    // MARK: Configurations
    
    func setMenuRevealType(_ menu: MenuType, revealType:RevealType){
        switch menu {
            case .leftMenu: self.leftRevealType = revealType
            case .rightMenu: self.rightRevealType = revealType
            case .bothMenus: self.leftRevealType = revealType; self.rightRevealType = revealType
        }
    }
    
    func setMenuWidth(_ menu: MenuType, width:CGFloat){
        switch menu {
            case .leftMenu: self.leftWidth = width
            case .rightMenu: self.rightWidth = width
            case .bothMenus: self.leftWidth = width; self.rightWidth = width
        }
    }
    
    func setMenuAnimationSpeed(_ menu: MenuType, speed:CGFloat){
        switch menu {
            case .leftMenu: self.leftAnimationSpeed = speed
            case .rightMenu: self.rightAnimationSpeed = speed
            case .bothMenus: self.leftAnimationSpeed = speed; self.rightAnimationSpeed = speed
        }
    }
    
    func enableMenu(_ menu: MenuType, enabled:Bool){
        switch menu {
            case .leftMenu: self.leftEnabled = enabled
            case .rightMenu: self.rightEnabled = enabled
            case .bothMenus: self.leftEnabled = enabled; self.rightEnabled = enabled
        }
    }
    
    func enableMenuShadow(_ menu: MenuType, enabled:Bool){
        switch menu {
            case .leftMenu: self.leftShadowEnabled = enabled
            case .rightMenu: self.rightShadowEnabled = enabled
            case .bothMenus: self.leftShadowEnabled = enabled; self.rightShadowEnabled = enabled
        }
    }
    
    func enableMenuPanning(_ menu: MenuType, enabled:Bool){
        switch menu {
            case .leftMenu: self.leftPanningEnabled = enabled
            case .rightMenu: self.rightPanningEnabled = enabled
            case .bothMenus: self.leftPanningEnabled = enabled; self.rightPanningEnabled = enabled
        }
    }
    
    func limitPanningAccess(_ shouldLimit:Bool, leftRange: CGFloat, rightRange:CGFloat){
        self.panLimitedAccess = shouldLimit
        self.leftPanAccessRange = leftRange
        self.rightPanAccessRange = rightRange
    }
}

// MARK: Helper Methods

extension ESNavigationController {
    fileprivate func getMenuView(_ menu: MenuType) -> UIView{
        return (menu == .leftMenu) ? self.leftMenuViewController.view : self.rightMenuViewController.view
    }
    fileprivate func getMenuRevealType(_ menu: MenuType) -> RevealType{
        return (menu == .leftMenu) ? self.leftRevealType : self.rightRevealType
    }
    fileprivate func getMenuWidth(_ menu: MenuType) -> CGFloat{
        return (menu == .leftMenu) ? self.leftWidth : self.rightWidth
    }
    fileprivate func getMenuAnimationSpeed(_ menu: MenuType) -> CGFloat{
        return (menu == .leftMenu) ? self.leftAnimationSpeed : self.rightAnimationSpeed
    }
    fileprivate func isMenuEnabled(_ menu: MenuType) ->  Bool{
        return menu == .leftMenu ? self.leftEnabled : self.rightEnabled
    }
    fileprivate func isMenuSet(_ menu: MenuType) ->  Bool{
        return menu == .leftMenu ? self.leftMenuSet : self.rightMenuSet
    }
    fileprivate func isMenuPanningEnabled(_ menu: MenuType) ->  Bool{
        return menu == .leftMenu ? self.leftPanningEnabled : self.rightPanningEnabled
    }
    fileprivate func getOppositeMenu(_ menu: MenuType) -> MenuType{
        return (menu == .leftMenu) ? .rightMenu : .leftMenu
    }
    fileprivate func getHorizontalConstraintForMenu(_ menu: MenuType) -> NSLayoutConstraint{
        return (menu == .leftMenu) ? self.leftTrailingConstraint! : self.rightLeadingConstraint!
    }
}

// MARK: Shadow Methods

extension ESNavigationController {
    
    fileprivate func updateShadow(){
        
        var mainViewSide: ViewSide = .noSides
        if (self.rightRevealType == .slideUnder && self.leftRevealType == .slideUnder && self.leftShadowEnabled && self.rightShadowEnabled) { mainViewSide = .bothSides }
        if (self.rightRevealType == .slideUnder && self.leftRevealType != .slideUnder && self.rightShadowEnabled) { mainViewSide = .rightSide }
        if (self.rightRevealType != .slideUnder && self.leftRevealType == .slideUnder && self.leftShadowEnabled) { mainViewSide = .leftSide }
        
        let leftViewSide: ViewSide = (self.leftRevealType == .slideOver && self.leftShadowEnabled) ? .rightSide : .noSides
        let rightViewSide: ViewSide = (self.rightRevealType == .slideOver && self.rightShadowEnabled) ? .leftSide : .noSides
        
        // update the shaddows
        self.drawShadowForView(self.view, side: mainViewSide)
        self.drawShadowForView(self.leftMenuViewController.view, side: leftViewSide)
        self.drawShadowForView(self.rightMenuViewController.view, side: rightViewSide)
    }
    
    fileprivate func drawShadowForView(_ theView: UIView, side: ViewSide){
        
        // get correct values
        let radius: CGFloat = (side == .bothSides) ? 8.0 : 4.0
        var xOffset: CGFloat = (side == .bothSides) ? 0.0 : 4.0
        if (side == .leftSide) { xOffset = -4.0; }
        let opacity: Float = (side == .noSides) ? 0.0 : 0.5
        
        // create shaddow
        theView.layer.shadowColor = UIColor.black.cgColor
        theView.layer.shadowRadius = radius
        theView.layer.shadowOpacity = opacity
        theView.layer.shadowOffset = CGSize(width: xOffset, height: 0)
    }
}

// MARK: Panning

extension ESNavigationController {

    internal func panEventFired(_ gesureRecognizer: UIPanGestureRecognizer){

        // BEGAN
        if gesureRecognizer.state == .began {
            self.panStarted()
        }
        
        // get pan value
        let movement = gesureRecognizer.translation(in: gesureRecognizer.view).x
        var panValue = self.panChangePoint + movement
        let viewBeingMoved: MenuType = (panValue > 0) ? .leftMenu : .rightMenu

        // move pan change point if pan has already fully expanded menu
        if panValue > self.leftWidth || panValue < -self.rightWidth{
            self.panChangePoint = (panValue > self.leftWidth) ? self.leftWidth - movement : -self.rightWidth - movement
            panValue = self.panChangePoint + movement
        }

        // setup and clean views
        if self.getMenuView(viewBeingMoved).superview == nil { self.menuSetup(viewBeingMoved) }
        self.menuCleanUp(self.getOppositeMenu(viewBeingMoved))
        
        // if old menu moved the main view, and the new view doesn't, make sure the main view is reset to its original position
        if !self.menuMovesMainView(viewBeingMoved) && self.menuMovesMainView(self.getOppositeMenu(viewBeingMoved)) {
            self.moveMainView(self.getOppositeMenu(viewBeingMoved), percentage: 0)
        }
        
        // CHANGED
        if gesureRecognizer.state == .changed {
            self.panChanged(viewBeingMoved, panValue: panValue)
        }

        // ENDED
        if gesureRecognizer.state == .ended {
            let velocity = gesureRecognizer.velocity(in: gesureRecognizer.view)
            self.panEnded(viewBeingMoved, panValue: panValue, velocity: velocity)
        }
    }
    
    // MARK: Pan State Methods
    
    fileprivate func panStarted(){
        self.mainContentOverlay.isHidden = false
        if self.isMenuOpen(.leftMenu) { self.panChangePoint = self.leftWidth}
        else if self.isMenuOpen(.rightMenu) { self.panChangePoint = -self.rightWidth}
        else { self.panChangePoint = 0 }
    }
    
    fileprivate func panChanged(_ viewBeingMoved: MenuType, panValue: CGFloat){
        
        // calculate percentage
        var percentage = self.isMenuEnabled(viewBeingMoved) && self.isMenuSet(viewBeingMoved) && self.isMenuPanningEnabled(viewBeingMoved) ? abs(panValue / self.getMenuWidth(viewBeingMoved)) : 0.0
        percentage = (self.panLimitedAccess && self.panAccessView != viewBeingMoved) ? 0 : percentage // disable pan to new view if in limited pan mode

        // make movements
        self.menuLayoutChanges(viewBeingMoved, percentage: percentage)
        self.menuManualViewChanges(viewBeingMoved, percentage: percentage)
    }
    
    fileprivate func panEnded(_ viewBeingMoved: MenuType, panValue: CGFloat, velocity: CGPoint){

        // get percentage based on point pan finished
        var percentage: CGFloat = (abs(panValue / self.getMenuWidth(viewBeingMoved)) >= 0.5) ? 1.0 : 0.0

        // change percentage to be velocity based, if velocity was high enough
        if abs(velocity.x) > 1000 {
            let shouldShow: Bool = (panValue > 0) ? (velocity.x > 50) : (velocity.x < -50)
            percentage = (shouldShow) ? 1.0 : 0.0
        }
        percentage = self.isMenuEnabled(viewBeingMoved) && self.isMenuSet(viewBeingMoved) && self.isMenuPanningEnabled(viewBeingMoved) ? percentage : 0.0
        percentage = (self.panLimitedAccess && self.panAccessView != viewBeingMoved) ? 0 : percentage // disable pan to new view if in limited pan mode
        
        // animate layout change
        self.animateLayoutChanges(viewBeingMoved, percentage: percentage, speed: 0.25, completion: nil)
    }
    
    // MARK: UIPanGestureRecognizerDelegate
    
    // disable pan if needed
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        // don't pan if delegate said not too, or if not the root view controller
        if let delegate: EasySlideDelegate = self.visibleViewController! as? EasySlideDelegate{
            if delegate.easySlidePanAccessAvailable() == false { return false }
        } else {
            if !(self.viewControllers[0] == self.visibleViewController) { return false }
        }

        // only enable swipe when began on edge
        if(self.panLimitedAccess){
            
            // extract touch data
            let x = touch.location(in: self.view).x
            let viewWidth = self.view.frame.size.width
            
            // check if in zone
            let inRightZone = (x <= viewWidth && x >= viewWidth - self.rightPanAccessRange)
            let inLeftRone = (x <= self.leftPanAccessRange && x >= 0)
            self.panAccessView = (inRightZone) ? .rightMenu : self.panAccessView
            self.panAccessView = (inLeftRone) ? .leftMenu : self.panAccessView
            return (inRightZone || inLeftRone) ? true : false
        }
        return !touch.view!.isKind(of: UISlider.self)
    }
}

// MARK: Movement Methods

extension ESNavigationController {
    
    // setup
    fileprivate func menuSetup(_ menu: MenuType){
        
        // general setup
        self.updateShadow()
        self.addMenuToWindow(menu)
        self.getMenuView(menu).alpha = 1.0
        
        // custom setup
        switch (self.getMenuRevealType(menu)) {
        case .slideAlong: self.moveMenu(menu, percentage: 0.0)
        case .slideUnder: self.moveMenu(menu, percentage: 1.0)
        case .slideOver: self.moveMenu(menu, percentage: 0.0)
        }
    }
    
    // autolayout constraint changes
    fileprivate func menuLayoutChanges(_ menu: MenuType, percentage: CGFloat){
        switch (self.getMenuRevealType(menu)) {
        case .slideAlong: self.moveMenu(menu, percentage: percentage)
        case .slideUnder: break
        case .slideOver: self.moveMenu(menu, percentage: percentage)
        }
    }
    
    // manual changes
    fileprivate func menuManualViewChanges(_ menu: MenuType, percentage: CGFloat){
        switch (self.getMenuRevealType(menu)) {
        case .slideAlong: self.moveMainView(menu, percentage: percentage)
        case .slideUnder: self.moveMainView(menu, percentage: percentage)
        case .slideOver: break
        }
    }
    
    // cleanup
    fileprivate func menuCleanUp(_ menu: MenuType){
        self.getMenuView(menu).removeFromSuperview()
    }
    
    // movement checks changes
    fileprivate func menuMovesMainView(_ menu: MenuType) -> Bool{
        switch (self.getMenuRevealType(menu)) {
        case .slideAlong: return true
        case .slideUnder: return true
        case .slideOver: return false
        }
    }
}

extension ESNavigationController {
    
    // moves the menu passed to given percentage
    fileprivate func moveMenu(_ menu: MenuType, percentage: CGFloat){
        let menuMultiplier: CGFloat = (menu == .leftMenu) ? percentage : (-percentage)
        self.getHorizontalConstraintForMenu(menu).constant =  menuMultiplier * self.getMenuWidth(menu)
    }
    
    // offsets main menu by % of menu passed
    fileprivate func moveMainView(_ menu: MenuType, percentage: CGFloat){
        let movement = self.getMenuWidth(menu)
        self.view.frame.origin.x = (menu == .leftMenu) ? movement * percentage : -movement * percentage
        self.getMenuView(menu).alpha = (0.4 * percentage) + 0.6
    }
}

// MARK: Custom Data Types

enum MenuType: Int {
    case leftMenu = 0
    case rightMenu = 1
    case bothMenus = 2
}
enum RevealType: Int {
    case slideAlong = 0
    case slideOver = 1
    case slideUnder = 2
}
private enum ViewSide: Int {
    case leftSide = 0
    case rightSide = 1
    case bothSides = 2
    case noSides = 3
}

// MARK: EasySlideDelegate Protocol

protocol EasySlideDelegate{
    func easySlidePanAccessAvailable() -> Bool
}
protocol MenuDelegate{
    var easySlideNavigationController: ESNavigationController? { get set }
}
