//
//  RegisterView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 3/12/24.
//

import SwiftUI

struct RegisterView: View {
    
    let userManager: UsersManager
    @Binding var navPath: NavigationPath
    @EnvironmentObject var appManager: RMLifePlannerManager
    @State var displayLoginError: Bool = false
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var taskAwaiting: Task<Void, Never>? = nil
    
    init(navPath: Binding<NavigationPath>) {
        self._navPath = navPath
        self.userManager = UsersManager()
    }
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                VStack (spacing: 10) {
                    HStack {
                        TextField("First Name", text: $lastName)
                            .lineLimit(1)
                            .autocorrectionDisabled()
                            .padding(3)
                            .background(Colors.backgroundWhite)
                        TextField("Last Name", text: $firstName)
                            .lineLimit(1)
                            .autocorrectionDisabled()
                            .padding(3)
                            .background(Colors.backgroundWhite)
                    }
                    TextField("Email", text: $email)
                        .lineLimit(1)
                        .autocorrectionDisabled()
                        .padding(3)
                        .background(Colors.backgroundWhite)
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
                HStack {
                    Button {
                        taskAwaiting = Task {
                            guard let authAndPreferences = await userManager.register(RegisterRequest(username: username, password: password, email: email)) else {
                                // login error
                                displayLoginError = true
                                return
                            }
                            appManager.authentication = authAndPreferences.authentication
                            appManager.userPreferences = authAndPreferences.userPreferences
                            taskAwaiting = nil
                        }
                    } label: {
                        Text("Create Account")
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
                }
                Spacer()
            }
            Spacer()
        }
    }
}

