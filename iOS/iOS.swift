//
//  iOS.swift
//  EmojiArt
//
//  Created by 涂庭鋆 on 2022/9/20.
//

import SwiftUI


extension UIImage {
    var imageData: Data? { jpegData(compressionQuality: 1.0) }
}

struct Pasteboard {
    static var imageData: Data? {
        UIPasteboard.general.image?.imageData
    }
    
    static var imageUrl: URL? {
        UIPasteboard.general.url?.imageURL
    }
}

extension View {
    func paletteControlButtonStyle() -> some View{
        self
    }
    
    func popoverPadding() -> some View {
        self
    }
    
    @ViewBuilder
    func wrappedInNavigationViewToMakeDismissable(_ dismiss: (() -> Void)?) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            NavigationView{
                self
                    .navigationBarTitleDisplayMode(.inline)
                    .dismissable(dismiss)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            self
        }
    }
    
    @ViewBuilder
    func dismissable(_ dismiss: (() -> Void)?) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            self.toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Close") { dismiss() }
                }
            }
        } else {
            self
        }
    }
}
