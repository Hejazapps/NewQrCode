import UIKit

class PercentageView: UIView {
    private let coloredView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1) // Light Gray
        coloredView.backgroundColor =  UIColor(red: 16/255, green: 130/255, blue: 254/255, alpha: 1)
        self.addSubview(coloredView)
    }

    func setPercentage(_ percentage: CGFloat) {
        let clampedPercentage = max(0, min(percentage, 100)) / 100
        let newWidth = self.bounds.width * clampedPercentage
        coloredView.frame = CGRect(x: 0, y: 0, width: newWidth, height: self.bounds.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Reset to default on layout changes
    }
}
