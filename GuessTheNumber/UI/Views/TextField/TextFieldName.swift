//
//  TextFieldName.swift
//  GuessTheNumber
//
//  Created by Alexander on 14.09.24.
//

import SwiftUI

struct TextFieldName: View {
    let name: String
    var body: some View {
        Text(name)
            .font(.system(size: 15))
            .foregroundColor(ThemableColor.textSecondary)
            .frame(height: 16, alignment: .leading)
    }
}

struct TextFieldName_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldName(name: "Name")
    }
}
