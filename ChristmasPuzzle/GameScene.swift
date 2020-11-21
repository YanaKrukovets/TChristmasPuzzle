//
//  GameScene.swift
//  ChristmasPuzzle
//
//  Created by Yana  on 2020-11-17.
//  Copyright © 2020 Yana . All rights reserved.
//

import SpriteKit
import GameplayKit
import StoreKit

class GameScene: SKScene {
    
       private var panda: SKNode!
       private var truck: SKNode!
       private var leftLeg: SKNode!
       private var rightLeg: SKNode!
       private var leftHand: SKNode!
       private var rightHand: SKNode!
       private var pandaHead: SKNode!
       private var secondCar: Bool! = false
       private var activeShape: SKNode!
       private var trucks: [String] = []
       private var truckNumber: Int! = 0
       private var truckDetails: [SKNode?] = []
       private var isActiveShape: Bool! = false
       private var isShade: Bool! = false
       private var activeShapePosition: CGPoint!
       private var request : SKProductsRequest!
       private var year: String = ""
       private var yearLabel: SKLabelNode!
       private var lock: SKSpriteNode!
       private var playButton: SKNode!
       
       func pandaBody() {
           leftLeg = panda.childNode(withName: "LeftLeg")
           rightLeg = panda.childNode(withName: "RightLeg")
           leftHand = panda.childNode(withName: "SitRHand")
           rightHand = panda.childNode(withName: "RightHand")
           pandaHead = panda.childNode(withName: "PandaHead")
       }
       
       func rotatePanda() {
           rotateAction (node: rightLeg, angle1: 0.1, angle2: -0.7)
           rotateAction (node: leftLeg, angle1: -1, angle2: 0.5)
           rotateAction (node: leftHand, angle1: -0.5, angle2: 0.5)
           rotateAction (node: rightHand, angle1: 0.5, angle2: -0.5)
           rotateAction (node: pandaHead, angle1: -0.01, angle2: 0.1)
       }
       
       //walkingPanda
       func pandaAnimation () {
           pandaBody()
           rotatePanda()
           panda.run(SKAction.moveTo(x: -230, duration: 4), completion: {
               self.pandaStopAnimations()
               self.truck.run(SKAction.moveTo(x: 0, duration: 3), completion: {
                   self.childNode(withName: "Right")?.run(SKAction.unhide())
                   self.playButton.run(SKAction.unhide())
               })
           })
       }
       
       //stops panda's animation
       func pandaStopAnimations () {
           leftHand.removeAllActions()
           leftHand.run(SKAction.rotate(byAngle: -0.5, duration: 0.3))
           rightHand.removeAllActions()
           rightHand.run(SKAction.hide())
           leftLeg.removeAllActions()
           rightLeg.removeAllActions()
           leftLeg.run(SKAction.hide())
           rightLeg.run(SKAction.hide())
           panda.childNode(withName: "SitLLeg")?.run(SKAction.unhide())
           panda.childNode(withName: "SitRLeg")?.run(SKAction.unhide())
           panda.childNode(withName: "SitLHand")?.run(SKAction.unhide())
       }
       
       func removeBuy () {
           if (self.getPlist()) {
               self.childNode(withName: "Buy")?.run(SKAction.hide())
               self.playButton.run(SKAction.unhide())
               self.removeLock()
           }
       }
       
       override func didMove(to view: SKView) {
           trucks = ["Santa", "Present", "Heg", "SnowMan", "House", "Deer", "Bear", "Shop", "Gnome", "Pinguin", "House2", "ChristmasPresent", "Present3", "ChristmasTree", "Present5"]
           
           playButton = self.childNode(withName: "Play")
           removeBuy ()
           panda = self.childNode(withName: "Panda")
           truck = self.childNode(withName: trucks[truckNumber])
           self.changeArrowButton () // changebutton
           pandaAnimation ()
       }
       
       //copy current truck -> shadeTruck
       func copyTruck (node: SKNode) -> SKSpriteNode {
           var shape: SKSpriteNode!
           
           shape = node.copy() as? SKSpriteNode
           shape.position.x = node.position.x
           shape.position.y = node.position.y
           shape.color = UIColor.black
           shape.colorBlendFactor = 0.7
           shape.zPosition = 3
           
           return shape
       }
       
       func hideButtons () {
           self.childNode(withName: "Left")?.run(SKAction.hide())
           self.childNode(withName: "Right")?.run(SKAction.hide())
           playButton.run(SKAction.hide())
       }
       
       //truck details goes to the grass
       func toPandaHand () {
           var positionZ: CGFloat
           var shape: SKSpriteNode!
       
           for (nodeIndex, currentNode) in self.truck.children.enumerated() {
               shape = copyTruck (node: currentNode ?? truck)
               positionZ = currentNode.zPosition as! CGFloat
               shape.zPosition = positionZ - 1
               shape.name = String(currentNode.name ?? "") + "Shade"
               shape.anchorPoint = CGPoint(x: 0.5, y: 0.5)
               truck.addChild(shape)
               currentNode.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(nodeIndex) * 0.2), SKAction.move(to: CGPoint(x: 170-(10*nodeIndex), y: -90), duration: 0.3)]), completion: {
                   currentNode.zPosition = CGFloat(nodeIndex + 5)
                   if (nodeIndex == self.truckDetails.count - 1) {
                       self.isShade = true
                   }
              })
           }
           hideButtons()
       }
       
       //rotates nodes
       func rotateAction (node: SKNode, angle1: CGFloat, angle2: CGFloat) {
           let move = SKAction.sequence([
               SKAction.rotate(toAngle: angle1, duration: 0.5),
               SKAction.rotate(toAngle: angle2, duration: 0.5)
           ])
           node.run(SKAction.repeatForever(move))
       }
       
       //changes active shape position
       func touch(atPoint pos : CGPoint) {
           if (isActiveShape) {
               activeShape.position = pos
           }
       }
         
       func setActiveShape (node: SKNode, location: CGPoint) {
           if (truckDetails.count > 0) {
               for item in truckDetails {
                   if (node.name == item?.name) {
                       activeShape = node
                       activeShape.zPosition = 40
                       activeShapePosition = activeShape.position
                       isActiveShape = true
                   }
               }
           } else {
               activeShape = SKNode()
               isActiveShape = false
           }
       }
       
       func purchaces() {
           let think = self.childNode(withName: "Think")
           self.isUserInteractionEnabled = false
           self.alpha = 0.5
           GameViewController.appStoreConnector.restorePurchases()
           think?.run(SKAction.sequence([SKAction.unhide(), SKAction.rotate(byAngle: 10, duration: 5)]), completion: {
               self.isUserInteractionEnabled = true
               self.alpha = 1
               think?.run(SKAction.hide())
               self.removeBuy ()
           })
       }
       
       func done () {
           let date = NSDate()
           let newFormatter = DateFormatter()
           newFormatter.dateFormat = "YYYY"
           let currentYear: Int! = Int(newFormatter.string(from: date as Date))

           let year: Int! = Int(yearLabel.text ?? "")
                  
           if ((currentYear != nil && year != nil) ) {
               if ((currentYear - year) > 15 && (currentYear - year) < 105) {
                   GameViewController.appStoreConnector.purchaseAdRemoval()
                   GameViewController.appStoreConnector.restorePurchases()
                   removePopup()
                   removeBuy()
               } else {
                   yearLabel.text = ""
               }
           }
       }
       
       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           guard let touch = touches.first else {
               return
           }
           
           let touchLocation = touch.location(in: self)
           let touchedNode = self.atPoint(touchLocation)
           
           switch touchedNode.name {
               case "Right":
                   if (truckNumber < trucks.count - 1) {
                       moveCardOut (x: -Int(self.frame.width), side: -1)
                   }
               case "Left":
                   if (truckNumber > 0) {
                       moveCardOut (x: Int(self.frame.width), side: 1)
                   }
               case "Play":
                   if (!isShade) {
                       self.truckDetails = self.truck.children
                       toPandaHand()
                   }
               case "Lock":
                   buyApplication()
               case "Buy":
                   buyApplication()
               case "purchases":
                   purchaces()
               case "0":
                   setYearLabel(name: touchedNode.name ?? "")
               case "1":
                   setYearLabel(name: touchedNode.name ?? "")
               case "2":
                   setYearLabel(name: touchedNode.name ?? "")
               case "3":
                   setYearLabel(name: touchedNode.name ?? "")
               case "4":
                   setYearLabel(name: touchedNode.name ?? "")
               case "5":
                   setYearLabel(name: touchedNode.name ?? "")
               case "6":
                   setYearLabel(name: touchedNode.name ?? "")
               case "7":
                   setYearLabel(name: touchedNode.name ?? "")
               case "8":
                   setYearLabel(name: touchedNode.name ?? "")
               case "9":
                   setYearLabel(name: touchedNode.name ?? "")
               case "Exit":
                   removePopup()
               case "Remove":
                   yearLabel.text = ""
               case "Done":
                   done()

               default:
                   if (isShade) {
                       setActiveShape (node: touchedNode, location: touchLocation)
                   }
           }
       }
       
       func buyApplication() {
           let validationPopup = self.childNode(withName: "Popup")
           validationPopup?.run(SKAction.unhide())
           yearLabel = (validationPopup?.childNode(withName: "Year") as! SKLabelNode)
       }
       
       func setYearLabel (name: String) {
           if (yearLabel.text?.count ?? 0 < 4) {
               yearLabel.text! += name
           }
       }
       
       func removePopup () {
           yearLabel.text = ""
           self.childNode(withName: "Popup")?.run(SKAction.hide())
       }
            
       override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
           guard let touch = touches.first else {
               return
           }
           var touchLocation: CGPoint = touch.location(in: self)
           if (activeShape != nil) {
               for touch in touches {
                   touchLocation = touch.previousLocation(in: self)
                   activeShape.position.x = touchLocation.x
                   activeShape.position.y = touchLocation.y
                   activeShape.position = activeShape.scene?.convert(activeShape.position, to: activeShape.parent ?? activeShape) ?? CGPoint(x: 0, y: 0)
               }
          }
       }
       
       // add stars to the screen
       func winner () {
            if let winnerParticles = SKEmitterNode(fileNamed: "done.sks") {
               winnerParticles.position = CGPoint(x: size.width/2, y: size.height)
               self.addChild(winnerParticles)
           }
           isShade = false
           self.childNode(withName: "Left")?.run(SKAction.unhide())
           self.childNode(withName: "Right")?.run(SKAction.unhide())
           playButton.run(SKAction.unhide())
        }

        // plays winner sound and show star's rain
        func winnerAnimation () {
           if (truckDetails.count <= 0) {
                winner()
                audio.playSound(fileName: "Sound/winner", type: "mp3", volume: 1, loop: 0)
            }
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           if (isActiveShape && activeShape.name != nil) {
               let shadeShape = truck.childNode(withName: String(activeShape.name ?? "") + "Shade") as! SKSpriteNode
                   
               if ((shadeShape.position.y - activeShape.position.y < 30) &&
                       (activeShape.position.y - shadeShape.position.y < 30) &&
                       (shadeShape.position.x - activeShape.position.x < 30) &&
                       (activeShape.position.x - shadeShape.position.x < 30)) {
                     
                   activeShape.position = shadeShape.position
                   activeShape.zPosition = shadeShape.zPosition + 1
                   truckDetails = truckDetails.filter(){$0 != activeShape}
                   shadeShape.removeFromParent()
                   activeShape = SKNode()
                   audio.playSound(fileName: "Sound/success", type: "mp3", volume: 1, loop: 0)
                   winnerAnimation ()
               } else if (truckDetails.count >= 0 && isActiveShape) {
                   audio.playSound(fileName: "Sound/fail", type: "mp3", volume: 1, loop: 0)
                   activeShape.position = activeShapePosition
                 }
            }
        }
      
       func changeArrowButton () { //hide/unhide arrow button
           let leftMoveButton: SKNode = self.childNode(withName: "Left") ?? SKNode ()
           let rightMoveButton: SKNode = self.childNode(withName: "Right") ?? SKNode ()
           switch truckNumber {
               case 1:
                   leftMoveButton.run(SKAction.unhide())
               case (trucks.count - 1):
                   rightMoveButton.run(SKAction.hide())
               case (trucks.count - 2):
                   rightMoveButton.run(SKAction.unhide())
               case 0:
                   leftMoveButton.run(SKAction.hide())
               default:
                   leftMoveButton.run(SKAction.unhide())
               }
           }

       func moveCardOut (x: Int, side: Int) {
           let moveAction = SKAction.moveTo(x: CGFloat(x), duration: 2.0)
           playButton.run(SKAction.hide())
           if (!secondCar) {
               secondCar = true
               truck.run(moveAction, completion: { [self] in
                   self.truckNumber += (-1 * side)
                   self.changeArrowButton () // changebutton
                   self.removeLock()
                   self.truck = self.childNode(withName: self.trucks[self.truckNumber])
                   self.moveCardToCenter()   // move car to center
                   self.secondCar = false
               })
           }
       }
       
       func removeLock () {
           if (truck != nil && truck.childNode(withName: "Lock") != nil) {
               lock.removeFromParent()
               truck.alpha = 1
           }
       }
       
       func getPlist() -> Bool {
           let plistManage = PlistManager()
           let dataVersion = plistManage.readPlist(namePlist: "data", key: "isPurchased")
           return dataVersion as? Bool ?? false
       }
       
       func moveCardToCenter () {
           let moveAction = SKAction.moveTo(x: 0, duration: 2.0)
           self.truck.run(moveAction, completion: {
               if (self.truckNumber > 2 && !self.getPlist()) {
                   let lockTexture = SKTexture(imageNamed: "lock")
                   self.lock = SKSpriteNode(texture: lockTexture)
                   self.lock.name = "Lock"
                   self.lock.zPosition = 15
                   self.lock.position = self.truck.position
                   self.truck.addChild(self.lock)
                   self.lock.run(SKAction.unhide())
                   self.truck.alpha = 0.8
                   self.playButton.run(SKAction.hide())
               } else {
                   self.playButton.run(SKAction.unhide())
               }
               self.removeBuy()
           })
       }

}
