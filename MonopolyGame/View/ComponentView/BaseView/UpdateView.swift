//
//  UpdateView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 23.04.2025.
//

import UIKit
import SwiftUI
import WebKit

struct UpdateView: UIViewRepresentable {
    let html:String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)

    }
}
