//
//  EnhancedPokedexAppView.swift
//  CarlosV - Modern Pokédex Implementation
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct EnhancedPokedexAppView: View {
    @ObservedObject var viewModel: EnhancedPokedexViewModel
    @Namespace private var heroAnimation
    @State private var selectedPokemon: PokemonDetails?
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollToTop: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Modern header with gradient
                headerView
                
                // Main content
                mainContent
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedPokemon) { pokemon in
                PokemonDetailView(
                    pokemon: pokemon,
                    heroNamespace: heroAnimation
                )
            }
        }
    }
  
  @ViewBuilder
    private var headerView: some View {
        let headerScale = max(0.8, 1 + (scrollOffset / 300))
        let headerOpacity = max(0.6, 1 + (scrollOffset / 400))
        let titleFontSize: CGFloat = scrollOffset < -50 ? 24 : 34
        
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pokédex")
                        .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .animation(.smooth(duration: 0.3), value: titleFontSize)
                    
                    if scrollOffset > -100 {
                        Text("\(viewModel.pokemonList.count) Pokémon")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                
                Spacer()
                
                // Dynamic Pokeball icon
                Image(systemName: "circle.circle.fill")
                    .font(.system(size: scrollOffset < -50 ? 20 : 28))
                    .foregroundStyle(.red.gradient)
                    .symbolEffect(.bounce, value: viewModel.pokemonList.count)
                    .scaleEffect(scrollOffset < -100 ? 0.8 : 1.0)
                    .animation(.smooth(duration: 0.3), value: scrollOffset < -100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .padding(.bottom, scrollOffset < -50 ? 8 : 16)
        .scaleEffect(headerScale)
        .opacity(headerOpacity)
        .animation(.smooth(duration: 0.2), value: scrollOffset)
        .background(
            LinearGradient(
                colors: [
                    .clear, 
                    Color(.systemBackground).opacity(scrollOffset < -50 ? 0.95 : 0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .background(.ultraThinMaterial.opacity(scrollOffset < -50 ? 0.9 : 0.6), in: Rectangle())
    }
    
    private var mainContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                // Top anchor for scroll-to-top
                Color.clear
                    .frame(height: 0)
                    .id("top")
                
                // Scroll position tracking
                Color.clear
                    .frame(height: 0)
                    .trackScrollOffset(coordinateSpace: "scroll")
                
                LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.pokemonList.indices, id: \.self) { index in
                    ModernPokemonTile(
                        pokemon: viewModel.pokemonList[index],
                        heroNamespace: heroAnimation,
                        index: index
                    )
                    .scrollTransition(.animated.threshold(.visible(0.8))) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.6)
                            .scaleEffect(phase.isIdentity ? 1 : 0.9)
                            .blur(radius: phase.isIdentity ? 0 : 1)
                            .rotation3DEffect(
                                .degrees(phase.value * 15),
                                axis: (x: 1, y: 0, z: 0)
                            )
                    }
                    .onTapGesture {
                        HapticFeedback.impact()
                        selectedPokemon = viewModel.pokemonList[index]
                    }
                    .onAppear {
                        // Load more when approaching end
                        if index > viewModel.pokemonList.count - 3 {
                            Task {
                                await viewModel.fetchPokemons()
                            }
                        }
                    }
                }
                
                // Loading indicator for pagination
                if viewModel.loadingState == .loading && !viewModel.pokemonList.isEmpty {
                    ForEach(0..<4, id: \.self) { _ in
                        SkeletonPokemonTile()
                    }
                }
            }
                .padding(.horizontal, 16)
                .padding(.bottom, 100) // Safe area padding
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                
                // Show scroll to top button when scrolled down
                withAnimation(.easeInOut(duration: 0.3)) {
                    showScrollToTop = scrollOffset < -200
                }
            }
            .refreshable {
                HapticFeedback.impact(.light)
                await viewModel.refreshPokemons()
            }
            
            // Floating scroll to top button
            .overlay(alignment: .bottomTrailing) {
                if showScrollToTop {
                    ScrollToTopButton {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                        HapticFeedback.impact(.light)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
        }
        .overlay {
            // Loading state overlay
            if viewModel.loadingState == .loading && viewModel.pokemonList.isEmpty {
                loadingOverlay
            }
            
            // Error state overlay
            if case .error(let message) = viewModel.loadingState {
                errorOverlay(message: message)
            }
        }
        .task {
            if viewModel.pokemonList.isEmpty {
                await viewModel.fetchPokemons()
            }
        }
    }
    
    private var loadingOverlay: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
            
            Text("Loading Pokémon...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
    
    private func errorOverlay(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
                .symbolEffect(.bounce)
            
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Try Again") {
                HapticFeedback.impact()
                Task {
                    await viewModel.refreshPokemons()
                }
            }
            .buttonStyle(ModernButtonStyle())
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    EnhancedPokedexAppView(viewModel: EnhancedPokedexViewModel())
}
