//
//  EnterAndCheckNumberScreen.swift
//  GuessTheNumber
//
//  Created by Alexander on 14.09.24.
//

import SwiftUI

struct EnterAndCheckNumberScreen: View {
    @ObservedObject var viewModel: GameViewModel
    @State var inputValue: String = ""
    
    var isSignInButtonDisabled: Bool {
        [inputValue].contains(where: {$0.isEmpty || $0.count > 3 || ($0.intValue ?? 0) > 100})
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 2) {
                Image(uiImage: UIImage(named: "logo") ?? UIImage())
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top, 64)
                Text("Угадай число от 1 до 100\n\(viewModel.boundsText)")
                    .font(.subheadline)
                    .padding(.top, 24)
                    .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 32)
                    BaseTextField(title: "Число", showToolbar: true, text: $inputValue)
                    .keyboardType(.numberPad)
                Spacer()
                    .frame(height: 28)
                AcceptButton(title: "Проверить",
                             disabled: isSignInButtonDisabled) {
                    viewModel.compareWihTarget(input: inputValue)
                }
                Spacer()
                    .frame(height: 14)
                AcceptButton(title: "Заново", disabled: false, type: .negative) {
                    viewModel.reload()
                }
            }
            .padding(.horizontal, 16)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .overlay(content: {
            if viewModel.gameState == .loadingData {
                ZStack(content: {
                    Rectangle()
                        .foregroundColor(.white)
                        .ignoresSafeArea()
                    SpinnerView()
                })
            }
        })
        .alert(viewModel.alert?.message ?? "", isPresented: $viewModel.alertIsVisible, actions: {
            AcceptButton(title: viewModel.alert?.actionTitle ?? "", action: viewModel.alert?.action ?? {})
        })
        .navigationBarHidden(true)
            .onAppear(perform: {
                viewModel.reload()
            })
    }
}

struct EnterAndCheckNumberScreen_Previews: PreviewProvider {
    static var previews: some View {
        EnterAndCheckNumberScreen(viewModel: GameViewModel())
    }
}

extension String {
    var intValue: Int? {
        return Int(self)
    }
}
