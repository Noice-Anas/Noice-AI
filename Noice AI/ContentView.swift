//
//  ContentView.swift
//  Noice AI
//
//  Created by Noice_anas on 08/03/2023.
//
import OpenAISwift
import SwiftUI

struct ContentView: View {
    
    @StateObject var vm: Content_ViewModel = .init()
    
    
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading ,spacing: 10) {
                    ForEach(vm.responses, id: \.self) { response in
                        Text(response)
                        Color.white.frame(height: 1)
                    }
                }
                .onAppear {
                    vm.setup()
                }
                
            }
            VStack {
                Spacer()
                
                HStack(alignment: .center, spacing: 20) {
                    TextField("Type Here...", text: $vm.messageText)
                    
                    Button {
                        send()
                    } label: {
                        Text("Send")
                    }
                    
                }
                
                Spacer().frame(height: 20)
            }
        }
        .padding()
    }
    
    func send() {
        guard !vm.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            vm.hideKeyboard()
            return
        }
        vm.responses.append("Noice: \(vm.messageText)")
        vm.send(text: vm.messageText) { response in
            self.vm.responses.append("CHATGPT: \(response)")
            vm.hideKeyboard()
            self.vm.messageText = ""
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



//-------



final class Content_ViewModel: ObservableObject {
    
    private var client: OpenAISwift?
    @Published var messageText: String = ""
    @Published var responses: [String] = []
    
    init() {}
    
    func setup() {
        //This is Faisal Alghanam's Token from his account
        client = OpenAISwift(authToken: "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")
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500 ,completionHandler: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    let output = model.choices.first?.text ?? "Nothing came back"
                    completion(output)
                case .failure(let errorModel):
                    print("There was a failure 😥 \(errorModel.localizedDescription)")
                    self.responses.append("CHATGPT: \(errorModel.localizedDescription)")
                    self.messageText = ""
                    print("sending has failed 😥")
                    break
        
                    
                }
            }
        })
    }
    
    /// Hides the keyboard when called
    public func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
