//
//  ViewController.swift
//  ChromaKeyDemo
//
//  Created by Chanpreet Singh on 07/05/21.
//

import UIKit
import CoreImage

class ViewController: UIViewController {
    
    @IBOutlet weak var foreGroundImgVw:UIImageView!
    @IBOutlet weak var backGroundImgVw:UIImageView!
    @IBOutlet weak var joinedImgVw:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        generateCombinedImage()
    }
    
    func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat) -> CIFilter?
    {
        // 1
        let size = 64
        var cubeRGB = [Float]()
        
        // 2
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size-1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size-1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size-1)
                    
                    // 3
                    let hue = getHue(red: red, green: green, blue: blue)
                    let alpha: CGFloat = (hue >= fromHue && hue <= toHue) ? 0: 1
                    
                    // 4
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                }
            }
        }
        
        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB, count: cubeRGB.count))
        
        // 5
        let colorCubeFilter = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
    
    func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat
    {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
    func removeGreenPart()->CIImage?{
        let chromaCIFilter = self.chromaKeyFilter(fromHue: 0.3, toHue: 0.4)
        if let cgImg = foreGroundImgVw.image?.cgImage {
            let ci = CIImage(cgImage: cgImg)
            
            chromaCIFilter?.setValue(ci, forKey: kCIInputImageKey)
            return chromaCIFilter?.outputImage
            //let sourceCIImageWithoutBackground = chromaCIFilter?.outputImage
        }
        return chromaCIFilter?.outputImage
        
    }
    
    func generateCombinedImage(){
        
        let compositor = CIFilter(name:"CISourceOverCompositing")
        let inputImg = removeGreenPart()
        if (inputImg != nil){
            compositor?.setValue(inputImg, forKey: kCIInputImageKey)
            if let cgImg = backGroundImgVw.image?.cgImage {
                let ci = CIImage(cgImage: cgImg)
                compositor?.setValue(ci, forKey: kCIInputBackgroundImageKey)
                if let compositedCIImage = compositor?.outputImage{
                    joinedImgVw.image = UIImage(ciImage: compositedCIImage)
                }
            }
            
        }
    }
}

