//
//  AuthorizationSettingsViewController.swift
//  KavDocumentsAuthorization
//
//  Created by Kirill Varshamov on 24.03.2022.
//

import UIKit

protocol AuthorizationSettingsModuleOutput: AnyObject {
    func authorizationSettingsModuleWantsToClose()
    func authorizationSettingsModuleWantsToSetupAuthorization(sender: UISwitch)
    func authorizationSettingsModuleWantsToOpenChangeCode()
    func authorizationSettingsModuleWantsToOpenBiometry(sender: UISwitch)
    func setupModuleInput(_ input: AuthorizationSettingsModuleInput)
}

protocol AuthorizationSettingsModuleInput: AnyObject {
    func reloadData()
}

final class AuthorizationSettingsViewController: UIViewController {
    
    private let authorizationService: AuthorizationServiceProtocol
    private weak var moduleOutput: AuthorizationSettingsModuleOutput?
    
    init(resolver: ResolverProtocol, moduleOutput: AuthorizationSettingsModuleOutput) {
        self.authorizationService = resolver.authorizationService
        self.moduleOutput = moduleOutput
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private lazy var dataSource = makeDataSource()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(AuthorizationSettingsCell.self, forCellReuseIdentifier: "settingsCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        setUpAuthorizationSection()
        
        moduleOutput?.setupModuleInput(self)
    }
    
    func setUpAuthorizationSection() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AuthorizationSettingsItem>()
        
        let authorizationDataModel = AuthorizationSettingsDataModel(uuid: UUID(), isEnable: authorizationService.isAuthorizationEnabled, title: "Authorization") { [weak self] sender in
            guard let self = self else { return }
            
            if sender.isOn {
                // set up auth
                // setup switch after user action
                self.moduleOutput?.authorizationSettingsModuleWantsToSetupAuthorization(sender: sender)
            } else {
                self.authorizationService.setAuthorizationEnable(false)
                self.authorizationService.setBiometry(false)
                
                self.setUpSnapshot()
            }
        }
        
        snapshot.appendSections([0])
        snapshot.appendItems([.authorization(authorizationDataModel)], toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        setUpSnapshot()
    }
    
    func setUpSnapshot() {
        var snapshot = dataSource.snapshot()
        
        guard snapshot.numberOfSections == 1 else { return }
        
        if authorizationService.isAuthorizationEnabled {
            snapshot.appendSections([1])
            
            let changeCodeDataModel = AuthorizationSettingsDataModel(uuid: UUID(), isEnable: true, title: "Change code", action: nil)
            snapshot.appendItems([.changeCode(changeCodeDataModel)], toSection: 1)
            
            if authorizationService.isBiometryAvailible {
                let biometryDataModel = AuthorizationSettingsDataModel(uuid: UUID(), isEnable: authorizationService.isBiometryEnabled, title: "Biometry") { [weak self] sender in
                    guard let self = self else { return }
                    
                    if !self.authorizationService.isBiometryEnabled {
                        self.moduleOutput?.authorizationSettingsModuleWantsToOpenBiometry(sender: sender)
                    } else {
                        self.authorizationService.setBiometry(false)
                    }
                }
                
                snapshot.appendItems([.biometry(biometryDataModel)], toSection: 1)
            }
        } else {
            snapshot.deleteSections([1])
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    deinit {
        moduleOutput?.authorizationSettingsModuleWantsToClose()
    }
    
    struct AuthorizationSettingsDataModel: Hashable {
        let uuid: UUID
        let isEnable: Bool
        let title: String
        let action: ((UISwitch) -> Void)?
        
        static func ==(lhs: AuthorizationSettingsDataModel, rhs: AuthorizationSettingsDataModel) -> Bool {
            lhs.uuid == rhs.uuid && lhs.isEnable == rhs.isEnable && lhs.title == rhs.title
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
            hasher.combine(isEnable)
            hasher.combine(title)
        }
    }
    
    enum AuthorizationSettingsItem: Hashable {
        case authorization(AuthorizationSettingsDataModel)
        case changeCode(AuthorizationSettingsDataModel)
        case biometry(AuthorizationSettingsDataModel)
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Int, AuthorizationSettingsItem> {
        let tableViewDataSource = UITableViewDiffableDataSource<Int, AuthorizationSettingsItem>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! AuthorizationSettingsCell
            
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

extension AuthorizationSettingsViewController: AuthorizationSettingsModuleInput {
    func reloadData() {
        self.setUpSnapshot()
    }
}

extension AuthorizationSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let snapshot = dataSource.snapshot()
        
        let items = snapshot.itemIdentifiers(inSection: indexPath.section)
        
        switch items[indexPath.row] {
        case .changeCode:
            moduleOutput?.authorizationSettingsModuleWantsToOpenChangeCode()
        default:
            break
        }
    }
}
