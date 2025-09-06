//
//  MainContentView.swift
//  DNATest
//
//  Created by Айдар Шарипов on 6/9/25.
//


import SnapKit

class MainContentView: UIView {
    
    private lazy var giftsLabel: UILabel = {
        let label = UILabel()
        label.text = "GIFTS"
        label.font = UIFont(name: "YFFRARETRIAL-AlphaBlack", size: 64)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var deliverLabel: UILabel = {
        let label = UILabel()
        label.text = "Deliver to 🇺🇸 USD 􀆈"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var searchBar: UITextField = {
        let bar = UITextField()
        bar.backgroundColor = .white
        bar.layer.cornerRadius = 16
        bar.font = .systemFont(ofSize: 17)
        bar.tintColor = UIColor(hex: "#7585B7")

        let image = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor(hex: "#7585B7")
        imageView.contentMode = .scaleAspectFit

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        imageView.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        container.addSubview(imageView)

        bar.leftView = container
        bar.leftViewMode = .always

        bar.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [
                .foregroundColor: UIColor(hex: "#7585B7")
            ]
        )

        bar.clearButtonMode = .whileEditing
        bar.returnKeyType = .search

        return bar
    }()
    
    private lazy var bannerImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "banner")
        
        return image
    }()
    
    private lazy var collectionImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Collections")
        
        return image
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        
        return view
    }()
    
    private lazy var viewAllButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("View all categories", for: .normal)
        b.setTitleColor(UIColor(hex: "#2D3A66"), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.backgroundColor = .white
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(hex: "#D8DEEF").cgColor
        return b
    }()

    private func makeChip(_ title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title + " 􀆈", for: .normal)
        b.setTitleColor(UIColor(hex: "#2D3A66"), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.backgroundColor = UIColor(hex: "#EEF2FF")
        b.layer.cornerRadius = 18
        return b
    }

    private lazy var chipGiftboxes = makeChip("Giftboxes")
    private lazy var chipForHer    = makeChip("For Her")
    private lazy var chipPopular   = makeChip("Popular")

    private lazy var chipsStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [chipGiftboxes, chipForHer, chipPopular])
        s.axis = .horizontal
        s.alignment = .fill
        s.distribution = .fillProportionally
        s.spacing = 12
        return s
    }()

    private func makeProductCard(imageName: String) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 24
        container.clipsToBounds = true

        let img = UIImageView(image: UIImage(named: imageName))
        img.contentMode = .scaleAspectFill

        let fav = UIButton()
        fav.setImage(UIImage(named: "Fav"), for: .normal)

        container.addSubview(img)
        container.addSubview(fav)

        img.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        fav.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(24)
        }
        return container
    }

    private lazy var productLeft  = makeProductCard(imageName: "product_left")
    private lazy var productRight = makeProductCard(imageName: "product_right")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = UIColor(hex: "#EFF3FF")
        addSubview(giftsLabel)
        addSubview(deliverLabel)
        addSubview(searchBar)
        addSubview(bannerImage)
        addSubview(collectionImage)
        addSubview(containerView)
        containerView.addSubview(viewAllButton)
        containerView.addSubview(chipsStack)
        containerView.addSubview(productLeft)
        containerView.addSubview(productRight)
    }
    
    func setupConstraints() {
        giftsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(flexibleHeight(to: 108))
            make.leading.equalToSuperview().inset(flexibleWidth(to: 16))
        }
        
        deliverLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(flexibleHeight(to: 65))
            make.trailing.equalToSuperview().inset(flexibleWidth(to: 31))
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(deliverLabel.snp.bottom).offset(flexibleHeight(to: 35))
            make.trailing.equalToSuperview().inset(flexibleWidth(to: 25))
            make.height.equalTo(flexibleHeight(to: 42))
            make.width.equalTo(flexibleWidth(to: 110))
        }
        
        bannerImage.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(flexibleHeight(to: 10))
            make.leading.equalToSuperview().inset(flexibleWidth(to: 16))
            make.trailing.equalToSuperview()
            make.height.equalTo(flexibleHeight(to: 150))
        }
        
        collectionImage.snp.makeConstraints { make in
            make.top.equalTo(bannerImage.snp.bottom).offset(flexibleHeight(to: 10))
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(flexibleWidth(to: 16))
            make.height.equalTo(flexibleHeight(to: 123))
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(collectionImage.snp.bottom).offset(flexibleHeight(to: 10))
            make.leading.trailing.equalToSuperview().inset(flexibleWidth(to: 16))
            make.bottom.equalToSuperview()
        }
        
        viewAllButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(flexibleHeight(to: 18))
            make.leading.trailing.equalToSuperview().inset(flexibleWidth(to: 102.5))
            make.height.equalTo(flexibleHeight(to: 32))
        }
        
        chipsStack.snp.makeConstraints { make in
            make.top.equalTo(viewAllButton.snp.bottom).offset(flexibleHeight(to: 16))
            make.leading.equalToSuperview().inset(flexibleWidth(to: 12))
            make.trailing.equalToSuperview().inset(flexibleWidth(to: 12))
            chipGiftboxes.snp.makeConstraints { $0.height.equalTo(flexibleHeight(to: 32)) }
            chipForHer.snp.makeConstraints    { $0.height.equalTo(flexibleHeight(to: 32)) }
            chipPopular.snp.makeConstraints   { $0.height.equalTo(flexibleHeight(to: 32)) }
        }
        
        productLeft.snp.makeConstraints { make in
            make.top.equalTo(chipsStack.snp.bottom).offset(flexibleHeight(to: 16))
            make.leading.equalToSuperview().inset(flexibleWidth(to: 16))
            make.height.width.equalTo(flexibleWidth(to: 156))
        }
        
        productRight.snp.makeConstraints { make in
            make.top.equalTo(chipsStack.snp.bottom).offset(flexibleHeight(to: 16))
            make.trailing.equalToSuperview().inset(flexibleWidth(to: 16))
            make.height.width.equalTo(flexibleWidth(to: 156))
        }
    }
}
