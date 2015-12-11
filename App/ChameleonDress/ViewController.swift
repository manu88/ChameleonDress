//
//  ViewController.swift
//  ChameleonDress
//
//  Created by Manuel Deneu on 25/10/2015.
//  Copyright © 2015 Manuel Deneu. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController , CBCentralManagerDelegate , CBPeripheralDelegate
{
    static let deviceName = "HMSoft"
    
    
    @IBOutlet weak var sampleColor: UIButton!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!

    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    
    
    // BLE
    var centralManager : CBCentralManager!
    var blePeriph : CBPeripheral!
    var writeCharac : CBCharacteristic!
    

    override func viewDidLoad()
    {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        super.viewDidLoad()
        showActivity()

        
    }
    
    func showActivity()
    {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivity()
    {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager)
    {
        if central.state == CBCentralManagerState.PoweredOn
        {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            print("Searching for BLE Devices")
            
        }
        else
        {
            // Can have different conditions for all states if needed - print generic message for now
            print("Bluetooth switched off or not initialized")
        }
    }
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
    {
        

        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if( nameOfDeviceFound == ViewController.deviceName)
        {
            print("Device \(ViewController.deviceName) found")
            
            self.centralManager.stopScan()
            // Set as the peripheral to use and establish connection
            self.blePeriph = peripheral
            self.blePeriph.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
            
        }
        else
        {
            print("Name is \(nameOfDeviceFound)")
        }
        
    }
    
    
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    {
        print("Did connect to \(peripheral.name)")
        
        hideActivity()

        self.blePeriph.discoverServices(nil)
        
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        print("Periph lost!")
        
        showActivity()
        
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
        
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        print("Did _NOT connect error \(error)")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
    {
        
        for s in peripheral.services!
        {

            
            print("Service \(s)")
            peripheral.discoverCharacteristics(nil, forService: s)
            
            
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)
    {
        print("didDiscoverCharacteristicsForService \(service)")
        
        for charateristic in service.characteristics!
        {
            let thisCharacteristic = charateristic as CBCharacteristic
            
            writeCharac  = thisCharacteristic
        }
        
    }
    


    /* **** **** **** **** **** **** **** **** **** **** */
    
    @IBAction func redSliderChanged(sender: UISlider)
    {
        let red = CGFloat(sender.value)
        sender.thumbTintColor = UIColor(red: red,green: 0.0,blue: 0.0,alpha: 1.0)
        
        displayColors()

    }
    @IBAction func greenSliderChanged(sender: UISlider)
    {
        let green = CGFloat(sender.value)
        sender.thumbTintColor = UIColor(red: 0.0,green: green ,blue: 0.0,alpha: 1.0)
        
        displayColors()
    }
    @IBAction func blueSliderChanged(sender: UISlider)
    {
        let blue = CGFloat(sender.value)
        sender.thumbTintColor = UIColor(red: 0.0,green: 0.0 ,blue: blue,alpha: 1.0)
        
        displayColors()
    }
    
    @IBAction func setButtonTouched( sender : UIButton)
    {
        //create a color from the sliders.
        let red = CGFloat(redSlider.value)
        let blue = CGFloat(blueSlider.value)
        let green = CGFloat(greenSlider.value)
        
        let color = UIColor(red: red,green: green,blue: blue,alpha: 1.0)

        
        sendColor( color )
        

    }
    
    @IBAction func presetButtonTouched( sender : UIButton)
    {

        
        let color = sender.backgroundColor
        
        print("Preset color = \(color)");
        
        sendColor( color! )
        
        sampleColor.backgroundColor = color
        
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        
        color!.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        redSlider.value = Float(red)
        greenSlider.value = Float(green)
        blueSlider.value = Float( blue)
        
        redSlider.thumbTintColor = UIColor(red: red,green: 0.0 ,blue: 0.0,alpha: 1.0)
        greenSlider.thumbTintColor = UIColor(red: 0.0,green: green ,blue: 0.0,alpha: 1.0)
        blueSlider.thumbTintColor = UIColor(red: 0.0,green: 0.0 ,blue: blue,alpha: 1.0)
        
    }
    func sendBright( brightness : Float )
    {
        let dat : [UInt8] = [ 15 , UInt8(255 * brightness  ) ]
        
        let data = NSData(bytes: dat, length: sizeof(UInt8) * dat.count )
        
        
        blePeriph.writeValue(data, forCharacteristic: writeCharac , type: .WithoutResponse)
        
    }
    func sendColor( color : UIColor )
    {
        if( blePeriph == nil )
        {
            return
        }
        print("Send color Value \(color)")
        
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let dat : [UInt8] = [ 10 , UInt8(255 * red  ) ,
                              11 , UInt8(255*green),
                              12 , UInt8(255*blue) ,
                              13 , 1 // GO!
        ]
        
        let data = NSData(bytes: dat, length: sizeof(UInt8) * dat.count )
        
        
        blePeriph.writeValue(data, forCharacteristic: writeCharac , type: .WithoutResponse)
    }
    
    func displayColors()
    {
        //create a color from the sliders.
        let red = CGFloat(redSlider.value)
        let blue = CGFloat(blueSlider.value)
        let green = CGFloat(greenSlider.value)
        let color = UIColor(red: red,green: green,blue: blue,alpha: 1.0)


        
        sampleColor.backgroundColor = color
        
//        sampleColor.text = String(format: "%i,%i,%i",Int(red * 255),Int(green * 255),Int(blue * 255))

    }
    

}

