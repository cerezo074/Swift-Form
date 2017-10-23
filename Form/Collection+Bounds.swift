//
//  Collection+Bounds.swift
//  Monkey Events
//
//  Created by eli on 8/21/17.
//  Copyright © 2017 Monkey Labs. All rights reserved.
//

import Foundation

/*
 Credits to Hamish
 http://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
 */

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
