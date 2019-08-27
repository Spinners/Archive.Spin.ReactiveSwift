//
//  SignalProducer+Spin.swift
//  Spin.ReactiveSwift
//
//  Created by Thibault Wittemberg on 2019-08-17.
//  Copyright © 2019 WarpFactor. All rights reserved.
//

import ReactiveSwift
import Spin

extension SignalProducer: Producer & Consumable {
    public typealias Input = SignalProducer
    public typealias Value = Value
    public typealias Executer = Scheduler
    public typealias Lifecycle = Disposable

    public static func from(function: () -> Input) -> AnyProducer<Input, Value, Executer, Lifecycle> {
        return function().eraseToAnyProducer()
    }

    public func compose<Output: Producer>(function: (Input) -> Output) -> AnyProducer<Output.Input, Output.Value, Output.Executer, Output.Lifecycle> {
        return function(self).eraseToAnyProducer()
    }

    public func scan<Result>(initial value: Result, reducer: @escaping (Result, Value) -> Result) -> AnyConsumable<Result, Executer, Lifecycle> {
        return self.scan(value, reducer).eraseToAnyConsumable()
    }
    
    public func consume(by: @escaping (Value) -> Void, on: Executer) -> AnyConsumable<Value, Executer, Lifecycle> {
        return self.observe(on: on).on(value: by).eraseToAnyConsumable()
    }

    public func spy(function: @escaping (Value) -> Void) -> AnyProducer<Input, Value, Executer, Lifecycle> {
        return self.on(value: function).eraseToAnyProducer()
    }

    public func spin() -> Lifecycle {
        return self.start()
    }
    
    public func toReactiveStream() -> Input {
        return self
    }
}

public extension Disposable {
    func disposed(by disposable: CompositeDisposable) {
        disposable.add(self)
    }
}

public typealias Spin<Value, Error: Error> = AnyProducer<SignalProducer<Value, Error>, Value, SignalProducer<Value, Error>.Executer, SignalProducer<Value, Error>.Lifecycle>
