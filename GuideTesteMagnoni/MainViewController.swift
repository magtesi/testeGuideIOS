//
//  ViewController.swift
//  GuideTesteMagnoni
//
//  Created by Magnoni Dalitese de Souza on 26/03/21.
//

import UIKit

class MainViewController: UIViewController {
    
    //MARK: ENUM
    
    enum EnumVariacao {
        case equal
        case larger
        case smaller
    }
    
    // MARK: CREATE OBJECTS
    
    func createLabel(text: String, size: CGFloat = 12, centerAlign: Bool = false, variation: EnumVariacao = .equal ) -> UILabel {
        
            let l = UILabel()
            l.text = text
            l.textColor = .systemGray6
            l.font = UIFont.systemFont(ofSize: size)
            l.textAlignment = centerAlign ? .center : .left
            switch variation {
                case .larger:
                    l.textColor = .green
                    break
                    
                case .smaller:
                    l.textColor = .red
                    break
                    
                default:
                    break
            }
            l.translatesAutoresizingMaskIntoConstraints = false
            
           return l
        
    }
    
    //MARK: OUTLETS
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activeLabel: UILabel!
    
    
    //MARK: CONFIGURATIONS
    
    private static let config: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 15.0
        return config
    }()
    
    private static let session = URLSession(configuration: config)
    
    
    // MARK: VARIABLES
    
    let active = "TSLA34"
    //let ativo = "PETR4"
        
    var arrayDays: Array<String>? = []
    var arrayVariationPercent: Array<Double>? = []
    
    //MARK: CYRCLE OF LIFE VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Buscar((Any).self)
    }
    

    @IBAction func segmentChanged(_ sender: Any) {
        
        if indicator.isAnimating { return }
        
        if segmentControl.selectedSegmentIndex == 1 {
        
            if ( arrayDays != nil && arrayDays?.count ?? 0 > 0 ) &&
                ( arrayVariationPercent != nil && arrayVariationPercent?.count ?? 0 > 0 ) {
            
                let graphicVC = storyboard?.instantiateViewController(identifier: "graphicViewController") as! GraphicViewController
                
                graphicVC.arrayDays = self.arrayDays
                graphicVC.arrayVariationPercent = self.arrayVariationPercent
                
                self.present(graphicVC, animated: true, completion: {
                    DispatchQueue.main.async {
                        self.segmentControl.selectedSegmentIndex = 0
                    }
                })
            }
            else{
                
                let alert = UIAlertController(title: "Atenção", message: "Ocorreu uma falha ao gerar os dados para exibição do gráfico! Por favor, tente novamente.", preferredStyle: .alert)
                var ok: UIAlertAction!

                ok = UIAlertAction(title: "OK", style: .default, handler: { (style) in
                    self.dismiss(animated: true, completion: {
                        DispatchQueue.main.async {
                            self.segmentControl.selectedSegmentIndex = 0
                        }
                    })
                })
                
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    @IBAction func Buscar(_ sender: Any) {
        
        if indicator.isAnimating { return }
        
        activeLabel.isHidden = true
        activeLabel.text = "---"
        indicator.startAnimating()
        
        cleamMainStack()
                    
        isInternetAvailable(webSiteToPing: nil){ (isInternetAvailable) in
                
            guard isInternetAvailable else { // NAO TENHO INTERNET
                            
                self.fail(tit: "Sem internet!", msg: "Este recurso precisa que a conexão com a internet esteja ativa.\n\nVerifique seu wi-fi e suas redes móveis e tente novamente.")

                return
            }
            
            /*
             *  https://observablehq.com/@stroked/yahoofinance
            */
            
            let seg = Date().timeIntervalSince1970
            let p1 = Int64( Date().addingTimeInterval( -50 * 86400 ).timeIntervalSince1970 ) //((24 * 60) * 60)
            let p2 = Int64(seg)
                        
            
            let urlStr = "https://query2.finance.yahoo.com/v8/finance/chart/\(self.active).SA?period1=\(p1)&period2=\(p2)&interval=1d"
            guard let _url = URL(string: urlStr) else {
                
                self.fail(tit: "Url inválida!", msg: urlStr)
                return
            }
            //print(url)
            
            MainViewController.session.dataTask(with: _url){ (data, res, error) in
                
                if res != nil {
                    
                    if error == nil {
                        
                        if (res as! HTTPURLResponse).statusCode == 200 {
                            
                            if let _data = data {
                                
                                do{
                                    
                                    let jsonDictionary = try (JSONSerialization.jsonObject(with: _data, options: .mutableContainers) as! NSDictionary)
                                    //print(jsonDictionary)
                                    
                                    guard let chartDictionary = jsonDictionary["chart"] as? NSDictionary else { return }
                                    //print(chartDictionary)
                                        
                                    guard let resultArrayDictionary = chartDictionary["result"] as? Array<Any> else { return }
                                    //print(resultArrayDictionary[0])
                                            
                                    guard let indicatorsDictionary = (resultArrayDictionary[0] as? NSDictionary)!["indicators"] as? NSDictionary else { return }
                                    //print( (indicatorsDictionary["quote"] as? Array<Any>) as Any )
                                                
                                    guard let quoteArrayDictionary = (indicatorsDictionary["quote"] as? Array<Any>) else { return }
                                    //print(quoteArray)
                                                    
                                    guard var openArray = (quoteArrayDictionary[0] as? NSDictionary)!["open"] as? Array<Any> else { return }
                                    //print(openArray)
                                    openArray.reverse()
                                    
                                    
                                    guard var timestampArray = (resultArrayDictionary[0] as? NSDictionary)! ["timestamp"] as? Array<Any> else { return }
                                    //print(timestampArray)
                                    timestampArray.reverse()
                                
                                    var openArray30: Array<Any> = []
                                    var timeStampArray30: Array<Any> = []
                                    
                                    for x in 0...29 {
                                        openArray30.append(openArray[x])
                                        timeStampArray30.append(timestampArray[x])
                                    }
                                    
                                    
                                    var valueBefore = 0.00
                                    var firstValue = 0.00
                                    
                                    DispatchQueue.main.async {
                                        
                                        self.stackView.translatesAutoresizingMaskIntoConstraints = false
                                        
                                        self.arrayDays?.removeAll()
                                        self.arrayVariationPercent?.removeAll()
                                    
                                        var x = 29
                                        repeat {
                                    
                                            let stackDay = UIStackView()
                                            stackDay.axis = .horizontal
                                            stackDay.alignment = .center
                                            stackDay.distribution = .fillEqually
                                            stackDay.spacing = 2
                                            stackDay.translatesAutoresizingMaskIntoConstraints = false
                                            
                                            let dayLabel = self.createLabel(text: String( abs(x - 30) ), centerAlign: true)
                                            stackDay.addArrangedSubview(dayLabel)
                                            
                                            let d = self.adjustmentDate( timeStampArray30[x] )
                                            self.arrayDays?.append( self.reduceDate( date: d ) )
                                            let dataLabel = self.createLabel(text: d)
                                            stackDay.addArrangedSubview(dataLabel)

                                            
                                            let valueLabel = self.createLabel(text: self.formatCurrency(valor: openArray30[x] as? NSNumber))
                                            stackDay.addArrangedSubview(valueLabel)

                                            
                                            let r = self.calculateDiff(priceOne: valueBefore, priceTwo: (openArray30[x] as? Double))
                                            let variationDayBeforeLabel = self.createLabel(text: r.0, variation: r.1 )
                                            stackDay.addArrangedSubview(variationDayBeforeLabel)
                                            valueBefore = (openArray30[x] as? Double) ?? 0.00

                                            
                                            let variationFirstDayLabel: UILabel?
                                            if x == 29 {
                                                firstValue = openArray30[x] as? Double ?? 0.00
                                                variationFirstDayLabel = self.createLabel(text: "---")
                                            }
                                            else{
                                                let r = self.calculateDiff(priceOne: firstValue, priceTwo: (openArray30[x] as? Double))
                                                variationFirstDayLabel = self.createLabel(text: r.0, variation: r.1)
                                            }
                                            if let v = variationFirstDayLabel {
                                                stackDay.addArrangedSubview( v )
                                            }
                                            
                                            
                                            self.stackView.addArrangedSubview(stackDay)
                                            
                                            x -= 1
                                            
                                        } while( x >= 0 )
                                    }


                                    
                                    DispatchQueue.main.async {
                                        self.indicator.stopAnimating()
                                        self.activeLabel.text = self.active
                                        self.activeLabel.isHidden = false                                        
                                    }
                                }
                                catch let err {
                                    print(err)
                                    
                                    self.fail(tit: "Falha no processo! - #1")
                                }
                            } // if let d = data
                            else{
                                print(error.debugDescription)
                                self.fail(tit: "Falha no processo! - #2")
                            }
                        } // status != 200
                        else{
                            print(" StatusCode: \((res as! HTTPURLResponse).statusCode)")
                            self.fail(tit: "Falha no processo! - #3")
                        }
                    } // error == nil
                    else{
                        print(error as Any)
                        self.fail(tit: "Falha no processo! - #4")
                    }
                } // res != nil 
                else{
                    print(error as Any)
                    self.fail(tit: "Falha no processo! - #5")
                }

            }.resume()
        }
    }
    
    
    private func fail(tit: String, msg: String = "Não foi possível realizar esta operação no momento.\n\nTente novamente em alguns instantes."){

       DispatchQueue.main.async {
           
            self.indicator.stopAnimating()
            self.activeLabel.isHidden = true
            self.activeLabel.text = "---"
        
            
            let alert = UIAlertController(title: tit, message: msg, preferredStyle: .alert)
            var ok: UIAlertAction!

            ok = UIAlertAction(title: "OK", style: .default, handler: { (style) in
                self.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
       }
    }
    
    
    fileprivate func adjustmentDate(_ x: Any ) -> String {
        let date = Date(timeIntervalSince1970: x as! Double)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
    
    
    fileprivate func formatCurrency(valor: NSNumber?) -> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "PT_BR")
        var res = ""
        if let formattedTipAmount = formatter.string(from: valor ?? 0.00) {
            res = "\(formattedTipAmount)"
        }
        return res
    }
    
    
    fileprivate func cleamMainStack(){
        var y = 0;
        for m in stackView.subviews {
            if(y > 0){ m.removeFromSuperview() }
            y += 1
        }
    }
    
    
    fileprivate func calculateDiff(priceOne: Double?, priceTwo: Double?) -> (String, EnumVariacao) {
        
        if let p1 = priceOne, let p2 = priceTwo {
            let difDouble = (p2) - (p1)
            let difPercent = ( p1 * difDouble ) / 100
            self.arrayVariationPercent?.append( difPercent )
            
            
            var res: Any!
            if difPercent == 0{
                res = EnumVariacao.equal
            }
            else if difPercent > 0 {
                res = EnumVariacao.larger
            }
            else{
                res = EnumVariacao.smaller
            }
            
            
            let nf = NumberFormatter()
            nf.maximumFractionDigits = 2
            
            return ("\(nf.string(from: NSNumber(value: difPercent)) ?? "---")%", res as! EnumVariacao)
        }
        else{
            return ("---", .equal)
        }
    }
    
    
    fileprivate func reduceDate( date: String ) -> String {
        
        let d = date.split(separator: "/")
        return "\(d[0])/\(d[1])"
    }
}
