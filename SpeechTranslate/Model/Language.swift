//
//  Language.swift
//  SpeechTranslate
//
//  Created by NATON on 2017/6/1.
//  Copyright © 2017年 NATON. All rights reserved.
//

import UIKit

class Language: NSObject {
    let languageTitleArr = ["简体中文(中国大陆)","繁体中文(中国台湾)","英文(美国)","韩文(韩国)","日文(日语)","法语(法国)","德语(德国)","阿拉伯语","俄语(俄罗斯)"]
    
    let laguageTileAndCode = [
        "简体中文(中国大陆)":"zh-cn",
        "繁体中文(中国台湾)":"zh-tw",
         "英文(美国)":"en-us",
         "韩文(韩国)":"ko-kr",
         "日文(日语)":"ja-jp",
         "法语(法国)":"fr-fr",
         "德语(德国)":"de-de",
         "阿拉伯语":"ar",
         "俄语(俄罗斯)":"ru-RU"
    ]
    
    let baiduTranslateTitleAndCode = [
        "简体中文(中国大陆)":"zh",
        "繁体中文(中国台湾)":"cht",
        "英文(美国)":"en",
        "韩文(韩国)":"kor",
        "日文(日语)":"jp",
        "法语(法国)":"fra",
        "德语(德国)":"de",
        "阿拉伯语":"ara",
        "俄语(俄罗斯)":"ru"
    ]
    
    func languageCodeByTitle(titleStr: String) -> String {
        return laguageTileAndCode[titleStr]!
    }
    
    func baiduLanguageCodeByTitle(titleStr: String) -> String {
        return baiduTranslateTitleAndCode[titleStr]!
    }
}
