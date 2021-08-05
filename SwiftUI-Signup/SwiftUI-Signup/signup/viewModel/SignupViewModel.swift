//
//  SignupViewMode.swift
//  SwiftUI-Signup
//
//  Created by Francesco Paolo Dellaquila on 05/08/21.
//

import Foundation
import Combine

class SignupViewModel: ObservableObject{
    
    @Published var username = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    
    @Published var inlineErrorPassword = ""
    
    @Published var isValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private static let predicate = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
    
    private var isUsernameValidPublisher: AnyPublisher<Bool, Never> {
        $username
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map{ $0.count >= 3}
            .eraseToAnyPublisher()
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map{ $0.isEmpty}
            .eraseToAnyPublisher()
    }
    
    private var arePasswordEqualPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map{$0 == $1}
            .eraseToAnyPublisher()
    }
    
    private var isPasswordStrongPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map{ Self.predicate.evaluate(with: $0)}
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<PasswordStatus, Never> {
        Publishers.CombineLatest3(isPasswordEmptyPublisher, isPasswordStrongPublisher,
                                  arePasswordEqualPublisher)
            .map{
                
                if $0 {return PasswordStatus.empty}
                if !$1 {return PasswordStatus.notStrongEnough}
                if !$2 {return PasswordStatus.repeatedPasswordWrong}
                
                return PasswordStatus.valid
            }
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isPasswordValidPublisher, isUsernameValidPublisher)
            .map{
                
                $0 == .valid && $1
            }
            .eraseToAnyPublisher()
    }
    
    init(){
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
        
        isPasswordValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { passwordStatus in
                
                switch passwordStatus {
                case .empty:
                    return "Password cannot be empty!"
                case .notStrongEnough:
                    return "Password is too weak!"
                case .repeatedPasswordWrong:
                    return "Password do not match"
                case .valid:
                    return ""
                }
                
            }
            .assign(to: \.inlineErrorPassword, on: self)
            .store(in: &cancellables)
    }
    
}
