//
//  AcceptButton.swift
//  GuessTheNumber
//
//  Created by Alexander on 14.09.24.
//

import SwiftUI

// Accept Button Types Configurator
enum ButtonType {
    case accept, negative
    
    var backgroundColor: Color {
        switch self {
        case .accept:
            return ThemableColor.sky2
        case .negative:
            return Color.clear
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .accept:
            return Color.white
        case .negative:
            return ThemableColor.sky2
        }
    }
    
    var disabledBackgroundColor: Color {
        switch self {
        case .accept:
            return ThemableColor.sky2.opacity(0.6)
        case .negative:
            return ThemableColor.sky2.opacity(0.6)
        }
    }
    
    var disabledForegroundColor: Color {
        switch self {
        case .accept:
            return Color.white
        case .negative:
            return ThemableColor.sky2.opacity(0.6)
        }
    }
}

struct AcceptButtonStyle: ButtonStyle {
    var type: ButtonType = .accept
    let isDisabled: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled || configuration.isPressed ? type.disabledForegroundColor : type.foregroundColor
        return configuration.label
            .frame(height: 44)
            .foregroundColor(currentForegroundColor)
            .background(isDisabled || configuration.isPressed ? type.disabledBackgroundColor : type.backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(currentForegroundColor, lineWidth: 1)
            )
            .padding([.top, .bottom], 0)
            .font(.system(size: 15, weight: .medium))
    }
}

struct AcceptButton: View {
    
    private static let buttonHorizontalMargins: CGFloat = 4
    
    var type: ButtonType = .accept
    
    private let title: String
    private let action: () -> Void
    private let disabled: Bool
    
    init(title: String,
         disabled: Bool = false,
         type: ButtonType = .accept,
         action: @escaping () -> Void) {
        self.type = type
        self.title = title
        self.action = action
        self.disabled = disabled
    }
    
    var body: some View {
        Button(action:self.action) {
            Text(self.title)
                .frame(maxWidth:.infinity)
        }
        .buttonStyle(AcceptButtonStyle(type: type, isDisabled: disabled))
        .disabled(self.disabled)
        .frame(height: 44)
        .frame(maxWidth: .infinity)
    }
}

struct AcceptButton_Previews: PreviewProvider {
    static var previews: some View {
        AcceptButton(title: "Next") {
            print("")
        }
        .padding(0)
    }
}
