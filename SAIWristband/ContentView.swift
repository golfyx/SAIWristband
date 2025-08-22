//
//  ContentView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isLoggedIn {
                TabBarView()
            } else {
                WelcomeView()
            }
        }
    }
}

#Preview {
    ContentView()
}
