//
//  ViewController.swift
//  Minesweeper
//
//  Created by Cameron Goddard on 4/3/22.
//

import Cocoa
import Defaults
import GameplayKit
import SpriteKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    var difficulty = Defaults[.Game.difficulty]
    var minesLayout: [(Int, Int)]?
    var rows, cols, mines: Int!

    var difficulties = [
        "Beginner": [8, 8, 10],
        "Intermediate": [16, 16, 40],
        "Hard": [16, 30, 99],
        "Custom": [8, 8, 10],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self, selector: #selector(self.setSubtitle(notification:)), name: .setSubtitle, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.setScale(notification:)), name: .setScale, object: nil)

        if let view = self.skView {
            let scale = Defaults[.General.scale]

            if difficulty == "Custom" || difficulty == "Loaded Custom" {
                rows = Defaults[.Game.customDifficulty][0]
                cols = Defaults[.Game.customDifficulty][1]
                mines = Defaults[.Game.customDifficulty][2]
            } else {
                rows = difficulties[difficulty]![0]
                cols = difficulties[difficulty]![1]
                mines = difficulties[difficulty]![2]
            }

            // Consider changing fullSizeContentView in the future
            view.setFrameSize(
                NSSize(width: scale * CGFloat(24 + cols * 16), height: scale * CGFloat(67 + rows * 16)))

            ThemeManager.shared.setCurrent(with: Defaults[.Themes.theme])
            let scene = GameScene(
                size: self.skView.frame.size, scale: scale, rows: rows, cols: cols, mines: mines,
                minesLayout: minesLayout)
            view.presentScene(scene)

            // view.showsFPS = true
            // view.showsNodeCount = true
        }
    }

    override func viewDidAppear() {
        if Defaults[.General.toolbarDifficulty] {
            view.window!.subtitle = difficulty
        }
    }

    @objc func setSubtitle(notification: Notification) {
        if Defaults[.General.toolbarDifficulty] {
            view.window!.subtitle = difficulty
        } else {
            view.window!.subtitle = ""
        }
    }

    @objc func setScale(notification: Notification) {
        let scale = Defaults[.General.scale]

        let newSize = NSSize(
            width: scale * CGFloat(24 + cols * 16),
            height: scale * CGFloat(67 + rows * 16)
        )
        view.setFrameSize(newSize)
        skView.setFrameSize(newSize)

        if let scene = getScene() {
            scene.size = newSize
            scene.updateScale(size: newSize, scale: scale)
        }
    }

    func getScene() -> GameScene? {
        return skView.scene as? GameScene
    }

    func getBoard() -> Board? {
        return (skView.scene as? GameScene)?.board
    }
}
