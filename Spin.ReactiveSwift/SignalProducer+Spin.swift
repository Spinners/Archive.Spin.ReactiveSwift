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
    public typealias Context = Scheduler
    public typealias Runtime = Disposable

    public static func from(function: () -> Input) -> AnyProducer<Input, Value, Context, Runtime> {
        return function().eraseToAnyProducer()
    }

    public func compose<Output: Producer>(function: (Input) -> Output) -> AnyProducer<Output.Input, Output.Value, Output.Context, Output.Runtime> {
        return function(self).eraseToAnyProducer()
    }

    public func scan<Result>(initial value: Result, reducer: @escaping (Result, Value) -> Result) -> AnyConsumable<Result, Context, Runtime> {
        return self.scan(value, reducer).eraseToAnyConsumable()
    }
    
    public func toStream() -> Input {
        return self
    }

    public func consume(by: @escaping (Value) -> Void, on: Context) -> AnyConsumable<Value, Context, Runtime> {
        return self.observe(on: on).on(value: by).eraseToAnyConsumable()
    }

    public func spy(function: @escaping (Value) -> Void) -> AnyProducer<Input, Value, Context, Runtime> {
        return self.on(value: function).eraseToAnyProducer()
    }

    public func spin() -> Runtime {
        return self.start()
    }
}
