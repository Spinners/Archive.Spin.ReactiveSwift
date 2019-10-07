//
//  SignalProducer+Spin.swift
//  Spin.ReactiveSwift
//
//  Created by Thibault Wittemberg on 2019-08-17.
//  Copyright © 2019 WarpFactor. All rights reserved.
//

import ReactiveSwift
import Spin

extension SignalProducer: Consumable {
    public typealias Value = Value
    public typealias Executer = Scheduler
    public typealias Lifecycle = Disposable
    
    public func consume(by: @escaping (Value) -> Void, on: Executer) -> AnyConsumable<Value, Executer, Lifecycle> {
        return self
            .observe(on: on)
            .on(value: by)
            .eraseToAnyConsumable()
    }
    
    public func spin() -> Lifecycle {
        return self.start()
    }
}

extension SignalProducer: Producer where Value: Command, Value.Stream: SignalProducerProtocol, Error == Never {
    public typealias Input = SignalProducer
    
    public func executeAndScan(initial value: Value.State, reducer: @escaping (Value.State, Value.Stream.Value) -> Value.State) -> AnyConsumable<Value.State, Executer, Lifecycle> {
        let currentState = MutableProperty<Value.State>(value)
        
        return self
            .withLatest(from: currentState.producer)
            .flatMap(.concat) { args -> SignalProducer<Value.Stream.Value, Never> in
                let (command, state) = args
                return command.execute(basedOn: state).producer.flatMapError { _ in return SignalProducer<Value.Stream.Value, Never>.empty }
        }
        .scan(value, reducer)
        .prefix(value: value)
        .on(value: { currentState.swap($0) })
        .eraseToAnyConsumable()
    }
    
//    public func spy(function: @escaping (Value) -> Void) -> AnyProducer<Input, Value, Executer, Lifecycle> {
//        return self
//            .on(value: function)
//            .eraseToAnyProducer()
//    }
    
    public func toReactiveStream() -> Input {
        return self
    }
}

public extension Disposable {
    func disposed(by disposable: CompositeDisposable) {
        disposable.add(self)
    }
}
