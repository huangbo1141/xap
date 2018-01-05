//
//  RxFunctions.swift
//  AutoCorner
//
//  Created by Alex on 21/1/2016.
//  Copyright © 2016 stockNumSystems. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Observable{
    /**
     Returns an observable sequence that contains a single element on a new global queue.
     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    
    public class func justOnGlobalQueue(_ closure:@autoclosure @escaping () throws -> Element, dispose:(() -> ())? = nil) -> RxSwift.Observable<Element>{
        return create({ observer -> Disposable in
            DispatchQueue.global().async{
                do {
                    observer.onNext(try closure())
                    observer.onCompleted()
                }catch{
                    observer.onError(error)
                }
            }
            if let dispose = dispose{
                return Disposables.create{
                    dispose()
                }
            }
            return Disposables.create()
        })
    }
    
    /**
     Returns an observable sequence that contains a single element on a new global queue.
     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    public class func justOnGlobalQueue(_ closure:@escaping () throws -> Element, dispose:(() -> ())? = nil) -> RxSwift.Observable<Element>{
        return create({ observer -> Disposable in
            DispatchQueue.global().async{
                do {
                    observer.onNext(try closure())
                    observer.onCompleted()
                }catch{
                    observer.onError(error)
                }
            }
            if let dispose = dispose{
                return Disposables.create{
                    dispose()
                }
            }
            return Disposables.create()
        })
    }
}

// Two way binding operator between control property and variable, that's all it takes {

infix operator <->: AdditionPrecedence

@discardableResult
func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
            }, onCompleted:  {
                bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToVariable)
}

// One way binding operator from control property to variable

infix operator -->: AdditionPrecedence

@discardableResult
func --> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToVariable = property.bind(to: variable)
    return Disposables.create([bindToVariable])
}

// One way binding operator from variable to control property

infix operator <--: AdditionPrecedence

@discardableResult
func <-- <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    return Disposables.create([bindToUIDisposable])
}


// workaround for Swift compiler bug, cheers compiler team :)
func castOptionalOrFatalError<T>(_ value: AnyObject?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func castOrFatalError<T>(_ value: AnyObject!, message: String) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError(message)
    }
    
    return result
}

func castOrFatalError<T>(_ value: AnyObject!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}

// Error messages {

let dataSourceNotSet = "DataSource not set"
let delegateNotSet = "Delegate not set"

// }

func rxFatalError(_ lastMessage: String) -> Never  {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}
