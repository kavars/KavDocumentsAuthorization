//
//  AuthorizationSettingsViewController.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 24.03.2022.
//

import KavUtils
import UIKit

final class AuthorizationSettingsViewController: UIViewController {
    
    // MARK: Private Properties
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(AuthorizationSettingsCell.self)
        tableView.rowHeight = 44
        return tableView
    }()
    
    private lazy var dataSource = makeDataSource()
    private let output: AuthorizationSettingsViewOutput
    
    // MARK: Life Cycle
    
    init(output: AuthorizationSettingsViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        notImplemented()
    }
    
    deinit {
        output.viewWantsToClose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        output.viewDidLoadEvent()
    }
    
    // MARK: Private Methods
    
    private func setupView() {
        title = "Authorization"
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Int, AuthorizationSettingsItem> {
        let tableViewDataSource = UITableViewDiffableDataSource<Int, AuthorizationSettingsItem>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            
            let cell = tableView.dequeueReusableCell(AuthorizationSettingsCell.self, at: indexPath)
            
            switch itemIdentifier {
            case .authorization(let model):
                cell.configure(with: model)
            case .changeCode(let model):
                cell.configure(with: model)
            case .biometry(let model):
                cell.configure(with: model)
            }
            
            return cell
        }
        
        return tableViewDataSource
    }
}

// MARK: - UITableViewDelegate

extension AuthorizationSettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let snapshot = dataSource.snapshot()
        
        let items = snapshot.itemIdentifiers(inSection: indexPath.section)
        
        switch items[indexPath.row] {
        case .changeCode:
            output.changeCodeDidTap()
        default:
            break
        }
    }
}

// MARK: - AuthorizationSettingsViewInput

extension AuthorizationSettingsViewController: AuthorizationSettingsViewInput {
    
    func setupMainSection(with item: AuthorizationSettingsItem) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AuthorizationSettingsItem>()
        
        snapshot.appendSections([0])
        snapshot.appendItems([item], toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        output.buildSettings()
    }
    
    func addSettingsSection(with items: [AuthorizationSettingsItem]) {
        var snapshot = dataSource.snapshot()

        guard snapshot.numberOfSections == 1 else { return }
        
        snapshot.appendSections([1])
        snapshot.appendItems(items, toSection: 1)

        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func removeSettingsSection() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteSections([1])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
