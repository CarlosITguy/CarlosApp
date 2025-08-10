//
//  tabBarView.swift
//  CarlosV
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct TabBarView: View {
    
    var body: some View {
        TabView() {
            Tab("First Tab", systemImage: "square") {
                ContentView(coolName: "First tab")
            }
            
            Tab("Pokédex", systemImage: "gamecontroller.fill") {
                EnhancedPokedexAppView(viewModel: EnhancedPokedexViewModel())
            }
          
//          Tab("Testing", systemImage: "questionmark.circle") {
//            
//              /*view*/()
//          }
        }
        
    }
    
}

#Preview {
    TabBarView()
}
