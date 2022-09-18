//
//  RootViewController.swift
//  ARCollection
//
//  Created by Gyorgy Borz on 2022. 09. 18..
//

import SnapKit
import UIKit

class RootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let dataSource = ARDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }

    private func setupUI() {
        title = "Collection"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        view.backgroundColor = .label
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.features.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let feature = dataSource.features[indexPath.row]
        cell.textLabel?.text = feature.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feature = dataSource.features[indexPath.row]
        navigationController?.pushViewController(feature.controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
