//
//  File.swift
//  
//
//  Created by s-berkowitz on 2023/08/23.
//

import Foundation

func secondsToNanoseconds(_ seconds: Double) -> UInt64 {
    return UInt64(seconds * 1_000_000_000)
}
