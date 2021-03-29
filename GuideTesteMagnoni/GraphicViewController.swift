//
//  GraphicViewController.swift
//  GuideTesteMagnoni
//
//  Created by Magnoni Dalitese de Souza on 26/03/21.
//

import UIKit
import Charts

class GraphicViewController: UIViewController, ChartViewDelegate, IAxisValueFormatter {
    
    @IBOutlet weak var chartView: BarChartView!
    
    var arrayVariationPercent: Array<Double>! = []
    var arrayDays: Array<String>! = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(arrayDays as Any)
        //print(arrayVariationPercent as Any)
        
        //self.setup(barLineChartView: chartView)
        
        chartView.delegate = self
        
        configChartPosNeg()
    }

    
    func configChartPosNeg(){
        //chartView.setExtraOffsets(left: 70, top: -30, right: 70, bottom: 10)
        chartView.setExtraOffsets(left: 16, top: 0, right: 16, bottom: 16)
    
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        
        chartView.rightAxis.enabled = false

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 13)
        xAxis.drawAxisLineEnabled = false
        xAxis.labelTextColor = .lightGray
        xAxis.labelCount = arrayDays.count
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 1
        xAxis.valueFormatter = self
        
//        let leftAxis = chartView.leftAxis
//        leftAxis.drawLabelsEnabled = false
//        leftAxis.spaceTop = 0.25
//        leftAxis.spaceBottom = 0.25
//        leftAxis.drawAxisLineEnabled = false
//        leftAxis.drawZeroLineEnabled = true
//        leftAxis.zeroLineColor = .gray
//        leftAxis.zeroLineWidth = 0.7
        
        self.updateChartData()
    }
    
    func updateChartData() {
//        if self.shouldHideData {
            chartView.data = nil
//            return
//        }
        
        self.setChartData()
    }
    
    func setChartData() {
        
        var arrayBarChartDataEntry: [BarChartDataEntry] = []
        for x in 0...arrayVariationPercent.count-1{
            arrayBarChartDataEntry.append(BarChartDataEntry(x: Double(x), y: arrayVariationPercent[x]))
        }
        
        let yVals = arrayBarChartDataEntry
        
//        let yVals = [BarChartDataEntry(x: 0, y: -224.1),
//                     BarChartDataEntry(x: 1, y: 238.5),
//                     BarChartDataEntry(x: 2, y: 1280.1),
//                     BarChartDataEntry(x: 3, y: -442.3),
//                     BarChartDataEntry(x: 4, y: -2280.1)
//        ]
        
        let red = UIColor(red: 211/255, green: 74/255, blue: 88/255, alpha: 1)
        let green = UIColor(red: 110/255, green: 190/255, blue: 102/255, alpha: 1)
        let colors = yVals.map { (entry) -> NSUIColor in
            return entry.y < 0 ? red : green
        }
        
        let set = BarChartDataSet(entries: yVals, label: "Values")
        set.colors = colors
        set.valueColors = colors
        
        let data = BarChartData(dataSet: set)
        data.setValueFont(.systemFont(ofSize: 13))
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        data.barWidth = 0.8
        
        chartView.data = data
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return arrayDays[min(max(Int(value), 0), arrayDays.count - 1)]
    }
}
