//
//  ContentView.swift
//  SwiftUI-Signup
//
//  Created by Francesco Paolo Dellaquila on 05/08/21.
//

import SwiftUI
import Combine

struct SignupView: View {
    
    @StateObject private var signupViewModel = SignupViewModel()
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("username".uppercased()), content: {
                        
                        TextField("Username", text: $signupViewModel.username)
                            .autocapitalization(.none)
                        
                    })
                    
                    Section(header: Text("password".uppercased()), footer: Text(signupViewModel.inlineErrorPassword).foregroundColor(.red), content: {
                        
                        SecureField("Password", text: $signupViewModel.password)
                            .autocapitalization(.none)
                            .accessibility(hidden: true)
                        
                        SecureField("Password again", text: $signupViewModel.passwordAgain)
                            .autocapitalization(.none)
                            .accessibility(hidden: true)
                        
                    })
                }
                
                Button(action: {
                    
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 60)
                        .overlay(
                            Text("Continue")
                                .foregroundColor(.white)
                        )
                })
                .padding()
                .disabled(!signupViewModel.isValid)
                
            }.navigationBarTitle("Sign Up")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
