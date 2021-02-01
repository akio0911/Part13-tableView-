//
//  ViewController.swift
//  Part13-tableView-
//
//  Created by 山本ののか on 2021/01/08.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(TableViewCell.loadNib(), forCellReuseIdentifier: TableViewCell.reuseIdentifier)
            tableView.isHidden = true
        }
    }

    private(set) var editIndexPath: IndexPath?

    private let useCase = FruitsUseCase()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 50
        tableView.isHidden = false
    }

    @IBAction func cancel(segue: UIStoryboardSegue) { }

    @IBAction func save(segue: UIStoryboardSegue) {
        guard let inputVC = segue.source as? InputViewController,
              let newFruit = inputVC.output else {
            return
        }
        useCase.append(fruit: newFruit)
        tableView.reloadData()
    }

    @IBAction func edit(segue: UIStoryboardSegue) {
        guard let inputVC = segue.source as? InputViewController,
              let fruit = inputVC.output,
              let editIndexPath = editIndexPath else {
            return
        }
        useCase.replace(index: editIndexPath.row, fruit: fruit)
        tableView.reloadRows(at: [editIndexPath], with: .automatic)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = (segue.destination as? UINavigationController)?.topViewController as? InputViewController {
            switch segue.identifier ?? "" {
            case "input":
                nextVC.mode = .input
            case "edit":
                guard let editIndexPath = editIndexPath else { return }
                nextVC.mode = .edit(useCase.fruits[editIndexPath.row])
            default:
                break
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.fruits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        cell.accessoryType = UITableViewCell.AccessoryType.detailButton
//        cell.configure(fruit: fruits[indexPath.row])
        cell.configure(fruit: useCase.fruits[indexPath.row])
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        useCase.toggleCheck(index: indexPath.row)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editIndexPath = indexPath
        performSegue(withIdentifier: "edit", sender: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        useCase.remove(index: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

class FruitsUseCase {
    private(set) var fruits: [Fruit]

    private static let initialFruits: [Fruit] = [
        Fruit(name:"りんご", isChecked: false),
        Fruit(name:"みかん", isChecked: true),
        Fruit(name:"バナナ", isChecked: false),
        Fruit(name:"パイナップル", isChecked: true)
    ]

    private let repository = FruitsRepository()

    init() {
        fruits = repository.load() ?? Self.initialFruits
    }

    func append(fruit: Fruit) {
        fruits.append(fruit)
        repository.save(fruits: fruits)
    }

    func replace(index: Int, fruit: Fruit) {
        fruits[index] = fruit
        repository.save(fruits: fruits)
    }

    func toggleCheck(index: Int) {
        fruits[index].isChecked.toggle()
        repository.save(fruits: fruits)
    }

    func remove(index: Int) {
        fruits.remove(at: index)
        repository.save(fruits: fruits)
    }
}

class FruitsRepository {
    private let key = "fruitsData"

    func save(fruits: [Fruit]) {
        let items = fruits.map { try! JSONEncoder().encode($0) }
        UserDefaults.standard.set(items as [Any], forKey: key)
    }

    func load() -> [Fruit]? {
        guard let items = UserDefaults.standard.object(forKey: key) as? [Data] else { return nil }
        return items.map { try! JSONDecoder().decode(Fruit.self, from: $0) }
    }
}


// 解答例

// 複数行をリロードするので配列を渡す
//tableView.reloadRows(at: [indexPath], with: .automatic)
