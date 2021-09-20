//
//  ContentView.swift
//  Builderli
//
//  Created by Suat Karakusoglu (Dogus Teknoloji) on 20.09.2021.
//

import SwiftUI

struct ContentView: View {
    static var currentSecurityLevel: SecurityLevel = .semiSecure
    
    @State var cards: [String]
    @State var error: String = ""
    
    var body: some View {
        VStack {
            Button(action: {
                self.getSecretCards()
            }, label: {
                Text("GO GO GO")
                    .padding()
            })
            
            if !error.isEmpty {
                Text(error)
            }
            
            if !self.cards.isEmpty {
                ForEach(self.cards, id: \.self) { card in
                    Text("\(card) kredi karti")
                }
            }
        }
    }
    
    @FullSecureRequired
    func getSecretCards() {
        SecurityRequiredBlock {
            print("Getting secret cards.")
            CardService.shared.getCreditCards { cards in
                self.cards = cards
            }
        } authFailedBlock: {
            self.error = "Couldn't authorize for full secure."
            print("Couldn't request secret cards.")
        }
    }
}

final class SecurityRequiredBlock {
    typealias AuthBlock = () -> Void
    var authSuccessBlock: AuthBlock
    var authFailedBlock: AuthBlock
    
    init(authSuccessBlock: @escaping AuthBlock, authFailedBlock: @escaping AuthBlock) {
        self.authSuccessBlock = authSuccessBlock
        self.authFailedBlock = authFailedBlock
    }
}

enum SecurityLevel {
    case fullSecure
    case semiSecure
    case noneSecure
}

@resultBuilder
struct FullSecureRequired {
    static func buildBlock(_ components: SecurityRequiredBlock...) {
        guard let blockToRunSecurely = components.first else { return }
        
        guard ContentView.currentSecurityLevel == .fullSecure else {
            print("Not full secure, opening auth page.")
            LoginManager.shared.fullSecureLogin {
                blockToRunSecurely.authSuccessBlock()
            } onFail: {
                blockToRunSecurely.authFailedBlock()
            }
            return
        }
        
        print("Already full secure go ahead.")
        blockToRunSecurely.authSuccessBlock()
    }
}

@resultBuilder
struct SemiSecureRequired {
    static func buildBlock(_ components: SecurityRequiredBlock...) {
        guard let blockToRunSecurely = components.first else { return }
        
        guard ContentView.currentSecurityLevel == .semiSecure else {
            print("Nope semi secure, opening auth page.")
            LoginManager.shared.semiSecureLogin {
                blockToRunSecurely.authSuccessBlock()
            } onFail: {
                blockToRunSecurely.authFailedBlock()
            }
            return
        }
        
        print("Already semi secure go ahead.")
        blockToRunSecurely.authSuccessBlock()
    }
}

class LoginManager {
    static let shared = LoginManager()
    
    func fullSecureLogin(onSucceed: @escaping () -> Void, onFail: @escaping () -> Void) {
        let shouldSucceed = false
        if shouldSucceed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onSucceed()
            }
        }else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFail()
            }
        }
    }
    
    func semiSecureLogin(onSucceed: @escaping () -> Void, onFail: @escaping () -> Void) {
        let shouldSucceed = true
        if shouldSucceed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onSucceed()
            }
        }else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFail()
            }
        }
    }
}

class CardService {
    static let shared = CardService()
    
    func getCreditCards(onCardsFetched: @escaping ([String]) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let creditCards = ["1221 3113 3113 3133", "3233 3223 3234 4333"]
            onCardsFetched(creditCards)
        }
    }
}
