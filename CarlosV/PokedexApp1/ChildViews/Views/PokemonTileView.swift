//  Created by Carlos Valderrama

import SwiftUI

struct PokemonTileView: View {
  // Cache width calculation to avoid repeated UIScreen calls
  private static let tileWidth = (UIScreen.main.bounds.width / 2) - 24
  private static let imageSize: CGFloat = 150
  
  let viewModel: PokemonTileViewModel
  
  var body: some View {
    VStack(spacing: 8) {
      pokemonImage
        .frame(width: Self.imageSize, height: Self.imageSize)
        .background(.bar, in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 12)
        .padding(.top, 12)
      
      Text(viewModel.name)
        .font(.subheadline)
        .fontWeight(.medium)
        .lineLimit(1)
        .truncationMode(.tail)
        .padding(.horizontal, 8)
        .padding(.bottom, 12)
    }
    .frame(width: Self.tileWidth)
    .background(.background, in: RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(.black, lineWidth: 2)
    )
  }
  
  @ViewBuilder
  private var pokemonImage: some View {
    if let imageURL = viewModel.image, let url = URL(string: imageURL) {
      AsyncImage(url: url) { phase in
        switch phase {
        case .empty:
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        case .failure:
          fallbackImage
        @unknown default:
          fallbackImage
        }
      }
      .clipped()
    } else {
      fallbackImage
    }
  }
  
  private var fallbackImage: some View {
    Image(systemName: "photo")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .foregroundColor(.secondary)
  }
}
