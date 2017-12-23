# -*- coding: utf-8 -*-
import random
import re
import json
import datetime
import requests
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
import time
import base64
import os
import hashlib
import pickle
import sys



reload(sys)
sys.setdefaultencoding('utf-8')

#铜板街测试环境
#APP_KEY = '0fda9a0bea732af62461ab0d33133d6e'
#APP_SECRET = 'eb34f9c99dd037f69c471d57d0bf07e0'

#网金社测试环境
#APP_KEY = '0f33dffb95fe3a29e3440579f049642a'
#APP_SECRET = '1c6c86af7c7b58ba14fbf03ac57faac6'

#网金社线上环境
APP_KEY = '3708e021ab7dd4f61729e1a51f307d71'
APP_SECRET = 'af253d1051c9127aa2997c1151bc0f0d'

#签名方法：
#请求参数中要加入 appKey 和秒级 timestamp
#请求参数按照 key1=value1&key2=value2 拼接为字符串 signString
#计算 signString base64 值 signStringBase64
#将 appKey:signStringBase64 进行 sha1 算法签名的到 sign
@keyword('sign')
def sign(params, appSecret=APP_SECRET):
    signString = ''
    params["appKey"] = APP_KEY
    params["timestamp"] = int(time.time())
    #params["timestamp"] = 15018402203
    paramsList = []
    for item in params:
        paramsList.append(item)
    paramsSort = sorted(paramsList)
    print '*INFO*' + str(paramsSort)
    print '*INFO*' + str(params["timestamp"])
    for item in paramsSort:
        if params.get(item, -1) == -1:
            pass
        else:
            #print '*INFO*' + params["planName"]
            if signString == '':
                signString += str(item) + "=" + str(params[item])
            else:
                signString += "&" + str(item) + "=" + str(params[item])
    signString = signString.replace("\'","\"")
    print signString
    signStringBase64 = base64.b64encode(signString)
    signStringWithSecret = str(appSecret) + ":" + signStringBase64
    print '*INFO*' + signStringWithSecret
    sign = hashlib.sha1(signStringWithSecret).hexdigest()
    return sign, params




#if __name__ == "__main__":
#    params_plan={
#        "planId": "fa198567833",
#        "planName": "铜宝盈B1期",
#        "amount": 123752345.43,
#        "startTime": "2015-06-17 11:51:12",
#        "period": 123,
#        "monthPeriod": 12,
#        "merchantPeriod": 123,
#        "merchantMonthPeriod": 12,
##        "startBenefitDate": "2015-06-17",
 #       "endBenefitDate": "2016-06-17",
 #       "extendLoan": 1,
 #       "repaymentType": 1
 #   }

    #getsign, getparams = sign(params_plan)
    #appKey = yourAppkey & id = xfzVDqw & p = abcdefg & u = tom & timestamp = 1498545533
#    getsign,getparams = sign(params_plan)
#    print "sign-----", getsign ,getparams["planName"]

#    aad = int(time.time()*10)
#    print str(aad)

@keyword('get phoneNum')
#随机生成手机号码
def	PhoneNum():
    list =	['139','188','185','136','155','135','158','151','152','153','134','137']
    str = "0123456789"
    phone = random.choice(list) + "".join(random.choice(str) for i in range(8))
    return phone
@keyword('plate_number')
#随机生成车牌号
def plate_number():
    list1 = ['浙', '沪', '苏', '赣', '鲁', '京', '徽', '湘', '云', '粤', '陕', '蒙']
    list2 = ['A', 'B', 'C', 'D']
    str1 = "0123456789"
    str2 = "QWERTYUPASDFGHJKLZXCVBNM"
    str3 = "".join(random.choice(str1) for i in range(3)) + "".join(random.choice(str2) for i in range(2))
    plate_number = random.choice(list1) + random.choice(list2) + str3
    return plate_number


@keyword('get name')
#获取随机8位字符串用作名字参数
def	Uid():
    str = "qwertyuiopasdfghjklzxcvbnm"
    uid = "".join(random.choice(str) for i in range(8))
    return uid

@keyword('vin')
#获取随机vin码
def	Vin():
    str = "qwertyuiopasdfghjklzxcvbnm"
    vin = "".join(random.choice(str) for i in range(17))
    return vin

@keyword('jsonp')
#jsonp解析
def loads_jsonp(_jsonp):
    try:
        return json.loads(re.match(".*?({.*}).*",_jsonp,re.S).group(1))
    except:
	raise ValueError('Invalid Input')


@keyword('clock1')
#生成当前时间的13位时间戳
def Clock1():
#    now_time = int(time.mktime(datetime.datetime.now().timetuple()) * 1000)
    now = time.time()
    midnight = now - (now % 86400) + time.timezone
    now_time = int(midnight * 1000)
    return now_time

@keyword('purTaxApplyNo')
def purTaxApplyNo():
    now = datetime.datetime.now()
    num1 = now.strftime("%Y%m%d")
    num2 = random.randint(10000, 99999)
    num = "SQ" + str(num1) + str(num2)
    return num

@keyword('purTaxPayApplyNo')
def purTaxPayApplyNo():
    now = datetime.datetime.now()
    num1 = now.strftime("%Y%m%d")
    num2 = random.randint(10000, 99999)
    num = "DK" + str(num1) + str(num2)
    return num


@keyword('Startdate')
#生成当前时间，格式为y-m-d xx:xx:xx
def Startdate():
    now = datetime.datetime.now()
    return now.strftime('%Y-%m-%d %H:%M:%S')

@keyword('Enddate')
#生成1年后的当前时间，格式为y-m-d xx:xx:xx
def Enddate():
    now = datetime.datetime.now()
    delta = datetime.timedelta(days=365)
    n_years = now + delta
    return n_years.strftime('%Y-%m-%d %H:%M:%S')

@keyword('clock2')
#生成明天这个时候的13位时间戳
def Clock2():
    to_time = datetime.datetime.now() + datetime.timedelta(days=+1)
    to_time2 = int(time.mktime(to_time.timetuple()) * 1000)
    return to_time2

@keyword('Tup')
#元组转json串
def Tup(a):
    tup1 = json.loads(a)
    print tup1
    T = tup1["data"]
    return T


@keyword('get_souche-inc_token')
#获取运营后台token
def get_dfc_sign(url, logindata):
    headers = {'content-type': 'application/x-www-form-urlencoded'}
    r = requests.post(url=url, data=logindata, headers=headers, allow_redirects=True)
    his = r.history[0]
    Location = his.headers["Location"]
    sign = re.findall(r"ticket=(.+)", Location)[0]
    return sign

@keyword('save_to_file')
#保存参数到文件里
def save_to_file(file_path, data):
    print '*INFO*=====' + os.getcwd()
    file = open(file_path, 'wb')
    pickle.dump(data, file)
    file.close()

@keyword('get_from_file')
#读取文件内的参数
def get_from_file(file_path):
    print '*INFO*=====' + os.getcwd()
    file = open(file_path, 'rb')
    data = pickle.load(file)
    file.close()
    return data