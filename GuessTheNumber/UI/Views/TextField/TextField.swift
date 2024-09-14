//
//  TextField.swift
//  GuessTheNumber
//
//  Created by Alexander on 14.09.24.
//

import SwiftUI

struct BaseTextField: View {
    let title: String
    var showToolbar: Bool = true
    var prompt: String? = nil
    @Binding var text: String
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !title.isEmpty {
                TextFieldName(name: title)
            }
            TextField("",
                      text: $text, prompt: Text(prompt ?? "").foregroundColor(ThemableColor.textPrimary).font(.system(size: 15)))
            .padding(10)
            .toolbar {
                if showToolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button {
                            isTextFieldFocused = false
                        } label: {
                            HStack {
                                Image(Assets.keyboard)
                                    .renderingMode(.template)
                                    .foregroundColor(ThemableColor.sky2)
                            }
                        }
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isTextFieldFocused ? .black : ThemableColor.textSecondary, lineWidth: 1)
            }
            .frame(height: 44)
            .focused($isTextFieldFocused)
            .autocapitalization(.none)
        }
    }
}

struct TextField_Previews: PreviewProvider {
    static var previews: some View {
        BaseTextField(title: "заголовок", text: .constant("значение"))
    }
}
