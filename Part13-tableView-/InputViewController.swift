//
//  InputViewController.swift
//  Part13-tableView-
//
//  Created by 山本ののか on 2021/01/12.
//

import UIKit

final class InputViewController: UIViewController {

    enum Mode {
        case input
        case edit(Fruit)
    }

    @IBOutlet private weak var textField: UITextField!

    var mode: Mode?
    private(set) var output: Fruit?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mode = mode else {
            fatalError("mode is nil.")
        }

        textField.text = {
            switch mode {
            case .input:
                return ""
            case let .edit(fruit):
                return fruit.name
            }
        }()
    }

    @IBAction private func saveAction(_ sender: Any) {
        guard let mode = mode else { return }

        let isChecked: Bool = {
            switch mode {
            case .input:
                return false
            case let .edit(fruit):
                return fruit.isChecked
            }
        }()

        output = Fruit(name: textField.text ?? "", isChecked: isChecked)

        performSegue(
            withIdentifier: {
                switch mode {
                case .edit:
                    return "edit"
                case .input:
                    return "save"
                }
            }(),
            sender: sender
        )
    }
}
