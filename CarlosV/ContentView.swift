//
//  ContentView2.swift
//  CarlosV
//
//  Created by Carlos Valderrama on 2/10/25.
//

import SwiftUI

struct ContentView: View {
    let coolName: String
    @State var backgroundColor: Color = .clear
    var body: some View {
        VStack {
            Image(systemName: "square")
                .resizable()
                .frame(width: 250, height: 250)
                .padding(16)
            
            Text(coolName)
            
                ScrollView(.horizontal){
                    HStack {

                        Button {
                            backgroundColor = .clear
                        } label: {
                            Text("Main Ablitites")
                                .foregroundStyle(.red)
                        }
                        
                        Button {
                            backgroundColor = .yellow
                        } label: {
                            Text("Main Ablitites")
                                .foregroundStyle(.orange)
                        }
                    
                        Button {
                            backgroundColor = .gray
                        } label: {
                            Text("Hobbies")
                                .foregroundStyle(.blue)
                        }
                        
                        Button {
                            backgroundColor = .cyan
                        } label: {
                            Text("contact Info ")
                                .foregroundStyle(.green)
                        }
                }
                }.padding()
            
            Spacer()
            
            Text("The Carlos APP")
                .padding()
            
            Text("The carlos description view")
            
            Spacer()
        }
        .background(backgroundColor)
    }
}


#Preview {
  ContentView(coolName: "Some cool name")
}
