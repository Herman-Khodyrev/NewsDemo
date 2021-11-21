//
//  DateForNews.swift
//  NewsDemo
//
//  Created by Герман on 18.10.21.
//

import Foundation


struct DateForNews {
    
    var date = Date()
    
    
    init(){
        date = Date()
    }
    
    func currentDate() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let datetime = formatter.string(from: date)
        return datetime
    }
    
    func newPageDate(day: Int) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -day, to: date)!
        let datetime = formatter.string(from: modifiedDate)
        return datetime
    }
    
}
