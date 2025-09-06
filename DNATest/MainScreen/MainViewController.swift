//
//  MainViewController.swift
//  DNATest
//
//  Created by Айдар Шарипов on 6/9/25.
//

import SnapKit

class MainViewController: UIViewController {
    
    private let contentView = MainContentView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
}

