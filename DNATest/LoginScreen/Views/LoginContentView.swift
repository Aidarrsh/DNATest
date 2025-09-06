//
//  LoginContentView.swift
//  DNATest
//
//  Created by Айдар Шарипов on 6/9/25.
//

import SnapKit

class LoginContentView: UIView {
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "WELCOME"
        label.font = UIFont(name: "YFFRARETRIAL-AlphaBlack", size: 64)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var skipLabel: UILabel = {
        let label = UILabel()
        label.text = "Skip"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(hex: "#757E9A")
        label.font = .systemFont(ofSize: 14)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 21
        paragraphStyle.maximumLineHeight = 21

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: label.font!,
            .foregroundColor: label.textColor!
        ]

        let attributedText = NSAttributedString(
            string: "Enter your phone number. We will send you an SMS with a confirmation code to this number.",
            attributes: attributes
        )

        label.attributedText = attributedText

        return label
    }()
    
    private lazy var backgroundVector: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "backgroundVector")
        
        return image
    }()
    
    private lazy var flowerImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "flower")
        
        return image
    }()

    lazy var appleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue with Apple", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setImage(UIImage(named: "apple_logo"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        
        return button
    }()

    lazy var googleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue with Google", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setImage(UIImage(named: "google_logo"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .center
        
        let fullText = "By continuing, you agree to Assetsy’s Terms of Use and Privacy Policy"
        let attributed = NSMutableAttributedString(string: fullText)

        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: label.font!,
            .foregroundColor: UIColor.black
        ]
        attributed.addAttributes(baseAttributes, range: NSRange(location: 0, length: attributed.length))

        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        if let termsRange = fullText.range(of: "Terms of Use") {
            let nsRange = NSRange(termsRange, in: fullText)
            attributed.addAttributes(linkAttributes, range: nsRange)
        }

        if let privacyRange = fullText.range(of: "Privacy Policy") {
            let nsRange = NSRange(privacyRange, in: fullText)
            attributed.addAttributes(linkAttributes, range: nsRange)
        }

        label.attributedText = attributed

        return label
    }()
    
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
        addSubview(welcomeLabel)
        addSubview(skipLabel)
        addSubview(descriptionLabel)
        addSubview(backgroundVector)
        addSubview(flowerImage)
        addSubview(appleButton)
        addSubview(googleButton)
        addSubview(termsLabel)
    }
    
    func setupConstraints() {
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(flexibleHeight(to: 108))
            make.leading.equalToSuperview().inset(flexibleWidth(to: 16))
        }
        
        skipLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(flexibleHeight(to: 65))
            make.trailing.equalToSuperview().inset(flexibleWidth(to: 16))
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(flexibleHeight(to: 20))
            make.leading.trailing.equalToSuperview().inset(flexibleWidth(to: 16))
        }
        
        backgroundVector.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(flexibleHeight(to: 225))
            make.bottom.equalToSuperview().inset(flexibleHeight(to: 82))
            make.leading.trailing.equalToSuperview()
        }
        
        flowerImage.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(flexibleHeight(to: 280))
            make.centerX.equalToSuperview()
            make.height.equalTo(flexibleHeight(to: 285))
            make.width.equalTo(flexibleWidth(to: 171))
        }
        
        appleButton.snp.makeConstraints { make in
            make.top.equalTo(flowerImage.snp.bottom).offset(flexibleHeight(to: 9))
            make.leading.trailing.equalToSuperview().inset(flexibleWidth(to: 16))
            make.height.equalTo(flexibleHeight(to: 56))
        }

        googleButton.snp.makeConstraints { make in
            make.top.equalTo(appleButton.snp.bottom).offset(flexibleHeight(to: 8))
            make.leading.trailing.equalTo(appleButton)
            make.height.equalTo(appleButton)
        }

        termsLabel.snp.makeConstraints { make in
            make.top.equalTo(googleButton.snp.bottom).offset(flexibleHeight(to: 16))
            make.leading.trailing.equalToSuperview().inset(flexibleWidth(to: 82.5))
        }
    }
}
