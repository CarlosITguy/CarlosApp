//
//  Pokedex.swift
//  CarlosV
//
//  Created by Carlos Valderrama on 2/14/25.
//
import SwiftUI
import Foundation

struct PokedexAppView: View {
  init(viewModel: PokedexViewModel) {
    self.viewModel = viewModel
  }
  
  @ObservedObject var viewModel: PokedexViewModel
  
  var body: some View {
    VStack{
      Text("This is a pokedex app")
      ScrollView {
        LazyVGrid(columns: [.init(), .init()]) {
          ForEach(viewModel.pokemonList.indices, id: \.self) { index in
            PokemonTileView(viewModel: PokemonTileViewModel(pokemonDetails: viewModel.pokemonList[index]))
              .background(.blue)
              .onAppear{
                guard index > viewModel.pokemonList.count - 3 else { return }
                Task {
                  await viewModel.fetchPokemons()
                }
              }
              .scrollTargetLayout()
              .scrollTransition { content, phase in
                content
                  .opacity(phase.isIdentity ? 1.0 : 0.3)
                  .scaleEffect(phase.isIdentity ? 1.0 : 0.3)
                  .rotationEffect(phase.value > -1 ? .zero : rotation(for: index))
                  .offset(phase.value < 1 ? .zero : .init(width: 0, height: 100))
              }
          }
        }
        .padding(.horizontal)
      }
      
      .task {
        await viewModel.fetchPokemons()
      }
    }
  }
  
  let rotationVelocity = 280.0
  
  private func rotation(for index: Int) -> Angle {
    index % 2 == 0 ? .degrees(-rotationVelocity) :  .degrees(rotationVelocity)
  }
}
#Preview {
  PokedexAppView(viewModel: PokedexViewModel())
}

