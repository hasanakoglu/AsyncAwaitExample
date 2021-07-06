//
//  ViewController.swift
//  AwaitAsyncExample
//
//  Created by Hasan Akoglu on 06/07/2021.
//

import UIKit

struct User: Codable {
    let name: String
}

enum UserError: Error {
    case noUsers
}

class ViewController: UIViewController, UITableViewDataSource {
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")
    private var users = [User]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        async {
            let result = await fetchUsers()
            /**
            You can chain async calls in order :)
             let users1 = await fetchUsers()
             let users2 = await fetchUsers()
             let users3 = await fetchUsers()
             let users4 = await fetchUsers()
             */
            switch result {
                
            case .success(let users):
                self.users = users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func fetchUsers() async -> Result<[User], Error> {
        guard let url = url else { return .failure(UserError.noUsers) }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let users = try JSONDecoder().decode([User].self, from: data)
            return .success(users)
        } catch {
            return .failure(error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
}

