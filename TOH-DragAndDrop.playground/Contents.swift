import UIKit
import PlaygroundSupport

class TowerModel {
    private var data: [[Int]] = [[3, 2, 1], [], []]
    private let winState: [[Int]] = [[], [], [3, 2, 1]]
    private var previous: Int = 0
    private var floater: Int?
    private var moves: Int = 0
    private var hasWon: Bool = false
    private var illegalMove: Bool = false
    
    public func getWinState() -> Bool {return hasWon}
    public func getIllegalMove() -> Bool {return illegalMove}
    public func getFloater() -> Int {
        guard let floater = floater else {return 0}
        return floater
    }
    public func getMoves() -> Int {moves}
    public func get(tower target : Int) -> [Int] {return data[target]}
    public func pickUp(_ which: Int) {
        previous = which
        floater = data[which].popLast()
    }
    public func dropDown (_ which: Int) {
        guard let pickedDisc = floater else {return}
        if let topDisc = data[which].last {
            guard pickedDisc < topDisc else {
                illegalMove = true
                data[previous].append(pickedDisc)
                floater = nil
                return
            }
        }
        illegalMove = false
        floater = nil
        moves += 1
        data[which].append(pickedDisc)
    }

    public func checkWin() {
        guard data == winState else {return}
        hasWon = true
    }
}
    
class TowerView : UIView {
    var movesMenu = UILabel()
    var warningLabel = UILabel()
    var winLabel = UILabel()
    
    private var location: CGPoint = .zero
    static var whichTower = 0
    let model = TowerModel()
    
    public func getLocation() -> CGPoint {return location}
    public func setLocation(_ mouse :CGPoint) {location = mouse}
    
    override func draw(_ rect: CGRect) {
        movesMenu.text = "Moves: \(model.getMoves())"
        if model.getWinState() == true {
            winLabel.text = "You WON in \(model.getMoves()) moves!"
            warningLabel.text = ""
            movesMenu.text = ""
        }
        if model.getIllegalMove() == true {
            warningLabel.text = "Try Again!"
        } else {
            warningLabel.text = ""
        }
        
        guard let cg = UIGraphicsGetCurrentContext() else { return }
        var xOffset = 0
        cg.setFillColor(UIColor.black.cgColor)
        cg.fill(self.bounds)
        
        let dHeight = 40
        let dWidth = 80
        let dVariance = 40
        let centerX = 105
        let bottomY = 245 - dWidth
        
        func drawDisc(_ size: Int, _ location: Int) {
            let w = dWidth + size * dVariance
            let h = dHeight
            let x = centerX - w/2
            let y = bottomY - h * location * 7/10 - location

            for i in 0 ... 20 {
                let rect = CGRect(x: x + xOffset, y: y-i, width: w, height: h)
                let path = UIBezierPath(ovalIn: rect)
                UIColor.black.setStroke()
                path.stroke()
                UIColor.white.setFill()
                path.fill()
            }
        }
        
        // draw towers
        for tower in 0 ..< 3 {
            xOffset = tower * 235
            //draws disc
            let t = model.get(tower: tower)
            for disc in 0 ..< t.count {
                drawDisc(t[disc], disc)
            }
        }
        // draw floater
        let f = model.getFloater()
        if f > 0 {
            let w = dWidth + f * dVariance
            let x = Int(location.x) - w/2
            let y = Int(location.y) - dHeight/2
                
            for i in 0...20 {
                let floatingRect = CGRect(x: x, y: y-i, width: w, height: dHeight)
                let floatingPath = UIBezierPath(ovalIn: floatingRect)
                UIColor.black.setStroke()
                floatingPath.stroke()
                UIColor.white.setFill()
                floatingPath.fill()
            }
        }
    
    }
   
}

class MyViewController : UIViewController {
    let myView : TowerView = TowerView()
    var model : TowerModel { myView.model }
    
    override func loadView() {
        let pad = 10
        
        let view = UIView()
        view.backgroundColor = .white
        
        myView.frame = CGRect(x: pad, y: pad, width: 700-2*pad, height: 300-2*pad)
        view.addSubview(myView)
        myView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: panSelector))
        self.view = view

        myView.warningLabel.frame = CGRect(x: 265, y: 230, width: 500, height: 60)
        myView.warningLabel.font = UIFont.boldSystemFont(ofSize: 40)
        myView.warningLabel.text = ""
        myView.warningLabel.textColor = .red
        view.addSubview(myView.warningLabel)

        myView.winLabel.frame = CGRect(x: 190, y: 25, width: 500, height: 60)
        myView.winLabel.font = UIFont.boldSystemFont(ofSize: 30)
        myView.winLabel.text = ""
        myView.winLabel.textColor = .systemYellow
        view.addSubview(myView.winLabel)

        myView.movesMenu.frame = CGRect(x: 15, y: 15, width: 300, height: 30)
        myView.movesMenu.font = UIFont.systemFont(ofSize: 20)
        myView.movesMenu.text = ""
        myView.movesMenu.textColor = .white
        view.addSubview(myView.movesMenu)
    }
    
    func updateMouse(location mouse: CGPoint) {
        myView.setLocation(mouse)
    }
    
    let panSelector = #selector(panHandle)
    @objc func panHandle(_ sender : UIPanGestureRecognizer) {
        let mouseLocation : CGPoint = sender.location(in: myView)
        updateMouse(location: mouseLocation)
        let tower = Int(mouseLocation.x / (myView.bounds.width/3))
        TowerView.whichTower = tower
        switch sender.state {
        case .began : //pickUp
            TowerView.whichTower = tower
            model.pickUp(tower)
        case .changed : break
        case .ended: fallthrough //drop
        default: //dropDown
            TowerView.whichTower = tower
            model.dropDown(tower)
        }
        model.checkWin()
        myView.setNeedsDisplay()
    }

}
let mvc = MyViewController()
mvc.preferredContentSize = CGSize(width: 700, height: 300)
PlaygroundPage.current.liveView = mvc
