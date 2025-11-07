////  KeyboardDismissExtension.swift
////  WorkoutTracker
////
////  Created by Devorex Minn on 11/6/25.
////
//
//import SwiftUI
//
//extension View {
//
//    /// Hides the keyboard when tapping anywhere outside of text fields
//    func hideKeyboardOnTap() -> some View {
//        self.gesture(
//            TapGesture().onEnded { _ in
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                                to: nil, from: nil, for: nil)
//            }
//        )
//    }
//
//    /// Hides the keyboard when the user drags or scrolls
//    func hideKeyboardOnScroll() -> some View {
//        self.gesture(
//            DragGesture().onChanged { _ in
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                                to: nil, from: nil, for: nil)
//            }
//        )
//    }
//
//    /// Programmatically hide the keyboard
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                        to: nil, from: nil, for: nil)
//    }
//}
