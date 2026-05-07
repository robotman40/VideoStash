//
//  SystemUtils.swift
//  VideoStash
//
//  Created by Chris Rios on 5/4/26.
//

import AppKit

func openInFinder(path: URL) {
    NSWorkspace.shared.open(path)
}
