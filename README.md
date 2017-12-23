#coding=utf-8
@keyword('get phoneNum')
#随机生成手机号码
def	PhoneNum():
    list =	['139','188','185','136','155','135','158','151','152','153','134','137']
    str = "0123456789"
    phone = random.choice(list) + "".join(random.choice(str) for i in range(8))
    return phone

print @keyword('get phoneNum')