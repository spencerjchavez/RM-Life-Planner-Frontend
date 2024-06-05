//
//  LoginView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 3/12/24.
//

import SwiftUI

struct LoginView: View {
    
    @State var navPath = NavigationPath()
    let userManager: UsersManager
    @EnvironmentObject var appManager: RMLifePlannerManager
    @State var displayLoginError: Bool = false
    @State var username: String = ""
    @State var password: String = ""
    @State var taskAwaiting: Task<Void, Never>? = nil
    
    init() {
        self.userManager = UsersManager()
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    VStack (spacing: 10) {
                        TextField(" Username", text: $username)
                            .lineLimit(1)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding(.all, 3)
                            .background(Colors.backgroundWhite)
                        
                        SecureField(" Password", text: $password)
                            .lineLimit(1)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .textContentType(.password)
                            .padding(.all, 3)
                            .background(Colors.backgroundWhite)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Colors.backgroundOffWhite))
                    .padding([.horizontal], 20)
                    Button {
                        taskAwaiting = Task {
                            guard let authAndPreferences = await userManager.login(LoginRequest(username: username, password: password)) else {
                                // login error
                                displayLoginError = true
                                return
                            }
                            appManager.authentication = authAndPreferences.authentication
                            appManager.userPreferences = authAndPreferences.userPreferences
                            taskAwaiting = nil
                        }
                    } label: {
                        Text("Login")
                            .disabled(username.isEmpty || password.isEmpty)
                            .padding(10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Colors.accentColorLight)
                            }
                            .padding()
                    }
                    if let taskAwaiting = taskAwaiting {
                        // loading icon
                        ProgressView()
                            .scaleEffect(3)
                            .foregroundStyle(Colors.accentColorLight)
                    }
                    else if displayLoginError {
                        Text("Invalid username or password")
                            .foregroundStyle(Color.red)
                            .font(.body)
                            .padding(.leading)
                    }
                    Text("New? Create A New Account")
                        .underline()
                        .foregroundStyle(Colors.lightBlue)
                        .onTapGesture {
                            navPath.append("register")
                        }
                    Spacer()
                }
                Spacer()
            }.navigationDestination(for: String.self, destination: { navString in
                if navString == "register" {
                    RegisterView(navPath: $navPath)
                }
            })
        }
    }
}


