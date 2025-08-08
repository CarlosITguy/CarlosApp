

import SwiftUI
import CoreData


class PokemonListCordeDataViewModel: ObservableObject {
  @Published var pokemonList: [PokemonEntity] = []
  @Published var counter = 0
  
  init() {
    container = NSPersistentContainer(name: "PokemonContainer")
    container.loadPersistentStores { NSEntityDescription, error in
      if let error {
        print("Problem loading core data \(error)")
      }
    }
    loadPokemon()
  }
  
  func loadPokemon()  {
    let request = NSFetchRequest<PokemonEntity>(entityName: "PokemonEntity")
    do {
      let pokemones = try container.viewContext.fetch(request)
      self.pokemonList = pokemones
    } catch let error {
      print("Error to fetch \(error.localizedDescription)")
    }
  }
  
  @MainActor
  func createPokemonEntity()  {
    let newPokemon = PokemonEntity(context: container.viewContext)
    newPokemon.name = "pokemon \(String(counter))"
    counter = counter + 1
    saveData()
  }
  
  func deletePokemon(pokemon: PokemonEntity) {
    container.viewContext.delete(pokemon)
    saveData()
  }
  
  @MainActor
  func modifyPokemon(pokemon: PokemonEntity) {
    pokemon.name = "new name"
    saveData()
  }

  
  func saveData() {
    do{
      try container.viewContext.save()
      loadPokemon()
    } catch let error {
      print(" Error on save of pokemon \(error.localizedDescription)")
    }
  }
  
  
  
  let container: NSPersistentContainer
  
}

struct CordeDataTest: View {
  @StateObject var viewModel = PokemonListCordeDataViewModel()
  
  var body: some View {
    VStack {
      Button("add pkemon") {
        viewModel.createPokemonEntity()
      }
      
      ScrollView {
        ForEach(viewModel.pokemonList, id: \.self) { pokemon in
          HStack{
            Text(pokemon.name ?? "1")
            
            Button("+"){
              viewModel.modifyPokemon(pokemon: pokemon)
            }
            
            Button("="){
              print("\(pokemon.name)")
            }
            
            Spacer()
            
            Button("X"){
              viewModel.deletePokemon(pokemon: pokemon)
            }
            
          }
          
        }
      }
      
    }
    
  }
}

#Preview {
  CordeDataTest()
}
