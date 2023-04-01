//
//  Array+Extension.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 01/04/23.
//

import Foundation

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
