//
//  AnimateTextView.swift
//  WWDCText
//
//  Created by Nonprawich I. on 14/11/2024.
//

import SwiftUI

@Observable
class FontSettings {
    var fontSizes: [CGFloat]
    var fontWeights: [Font.Weight]
    var fontWidths: [Font.Width]
    
    init(text: String, targetFontSize: CGFloat, targetFontWeight: Font.Weight, targetFontWidth: Font.Width) {
        self.fontSizes = Array(repeating: targetFontSize, count: 100)
        self.fontWeights = Array(repeating: targetFontWeight, count: 100)
        self.fontWidths = Array(repeating: targetFontWidth, count: 100)
    }
}

@Observable
class AnimatedTextModel {
    var text = "Hello World"
    var toggle = false
}

struct AnimatedTextView: View {
    @State private var model = AnimatedTextModel()
    @State private var fontSettings: FontSettings
    
    let targetFontSize: CGFloat = 40
    let minimumFontSize: CGFloat = 30
    let targetFontWeight: Font.Weight = .semibold
    let minimumFontWeight: Font.Weight = .ultraLight
    let targetFontWidth: Font.Width = .expanded
    let minimumFontWidth: Font.Width = .compressed
    
    init() {
        _fontSettings = State(initialValue: FontSettings(
            text: "Hello World",
            targetFontSize: 40,
            targetFontWeight: .semibold,
            targetFontWidth: .expanded
        ))
    }
    
    var body: some View {
        ZStack {
            
            Color.blue
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                TextField("Enter text", text: $model.text)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Text(finalText)
                    .geometryGroup()
                    .frame(width: 350, height: 200)
                
                Button("Animate") {
                    guard !model.text.isEmpty else { return }
                    model.toggle.toggle()
                    toggleWholeAnimation()
                }
                .buttonStyle(.borderedProminent)
                .disabled(model.text.isEmpty)
                
            }
            .padding()
            
            
        }
        
    }
    
    var finalText: AttributedString {
        guard !model.text.isEmpty else { return AttributedString("Enter some text") }
        var finalResult: AttributedString = .init(stringLiteral: "")
        
        for (item, index) in characterIndices(text: model.text) {
            var result = AttributedString(item)
            result.font = .system(size: fontSettings.fontSizes[index])
                .width(fontSettings.fontWidths[index])
                .weight(fontSettings.fontWeights[index])
            finalResult += result
        }
        
        return finalResult
    }
    
    func characterIndices(text: String) -> [(character: String, index: Int)] {
        return Array(text.enumerated()).map { (String($0.element), $0.offset) }
    }
    
    func toggleWholeAnimation() {
        Task {
            toggleAnimation()
            try? await Task.sleep(nanoseconds: 300_000_000)
            toggleAnimation()
        }
    }
    
    func toggleAnimation() {
        Task {
            for index in fontSettings.fontWidths.indices.prefix(model.text.count) {
                try? await Task.sleep(nanoseconds: 100_000_000 / UInt64(max(1, model.text.count)))
                
                withAnimation(.bouncy) {
                    fontSettings.fontSizes[index] = fontSettings.fontSizes[index] == minimumFontSize ? targetFontSize : minimumFontSize
                    fontSettings.fontWidths[index] = fontSettings.fontWidths[index] == minimumFontWidth ? targetFontWidth : minimumFontWidth
                    fontSettings.fontWeights[index] = fontSettings.fontWeights[index] == minimumFontWeight ? targetFontWeight : minimumFontWeight
                }
            }
        }
    }
}

#Preview {
    AnimatedTextView()
}
