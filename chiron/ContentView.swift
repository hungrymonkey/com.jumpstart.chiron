//
//  ContentView.swift
//  chiron
//
//  Created by Ted Chang on 11/9/25.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var qwenModel: Qwen3?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            loadQwenModel()
        }
    }
    
    
    private func loadQwenModel() {
        do {
            let config = MLModelConfiguration()
            let model = try Qwen3(configuration: config)
            self.qwenModel = model
            print("Qwen3 model loaded successfully")
            
        } catch {
            print("Failed to load Qwen3 model: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
