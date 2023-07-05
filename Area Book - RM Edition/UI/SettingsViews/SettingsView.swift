//
//  SettingsView.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/1/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    
                } label: {
                    Text("")
                }
                NavigationLink {
                    List {
                        Button(action: {
                            
                        }, label: {Text("English")})
                        Button(action: {
                            
                        }, label: {Text("Spanish")})
                    }
                } label: {
                    Text("Language")
                }
            }
            .navigationTitle("Settings")
            .listStyle(.grouped)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
