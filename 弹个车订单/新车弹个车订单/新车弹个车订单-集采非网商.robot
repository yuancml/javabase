*** Setting ***
Library           RequestsLibrary
Library           Collections
Resource          ../common.robot
Library           ../MyLibrary.py

*** Variables ***
${authCode}       b971f052c13e4b27a097bcd8a7f2WA12    #d8feeb06c9a041f594bbe06f2947SX53    #从弹个车客户端支付宝登录抓取login接口中获取
${shopCode}       002166    #店铺code，一般指定002166这家测试店
${isMybankOrder}    1    #1为网商订单，0为非网商订单
${name}           摇锴    #客户姓名
${mobile}         13750856517    #18888970448    #15869182946    #客户手机号码
${idCardNo}       330184199411224114    #411328199111057167    #331004199004190918    #332525199305240923    #客户身份证号码
${captcha}        562131    #获取到验证码后填写
${carId}          bZgJCXTzlW    #从大风车要下单的车辆抓取
${carColor}       {"color": "#FFFFFF","value": "珠光白"}    #车型颜色
${bankCardNum}    \    #银行卡，非集采订单必填
${leasesite_host}    http://leasesite5.sqaproxy.souche.com    #leasesite测试环境
${finance_host_inc}    http://finance-car-manage.sqaproxy.souche-inc.com    #运营后台测试环境
${finance_host}    http://finance-car-manage.sqaproxy.souche.com    #工作台测试环境

*** Test Cases ***
调试接口
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    #set to dictionary    ${save}    vin=20170907000000003
    #set to dictionary    ${save}    orderId=301716
    #set to dictionary    ${save}    receiverId=FAQRm0SMNg
    #set to dictionary    ${save}    purTaxApplyNo=
    #set to dictionary    ${save}    purTaxPayApplyNo=
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}

获取userId、iid、mobile、name
    ${data}=    create dictionary    authCode=${authCode}
    ${json}=    rest.post    /consumer/v1/authapi/login.json    ${data}    form    ${leasesite_host}
    Should Be True    ${json["success"]}
    set suite variable    ${userId}    ${json["data"]["consumerVO"]["userId"]}
    ${save}=    create dictionary    userId=${json["data"]["consumerVO"]["userId"]}    iid=${json["data"]["consumerVO"]["iid"]}    alipayUserId=${json["data"]["consumerVO"]["aliPayUserId"]}    alipayAccount=${json["data"]["consumerVO"]["loginPhone"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

获取销售ID
    登录风车    15094448010    cml448010
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary
    ${json}    rest.get    /v2/users/follows/getSalers    ${data}    form    http://crm.sqaproxy.souche.com
    Should Be True    ${json["success"]}
    Set suite Variable    ${items}    ${json["data"]["items"]}
    : FOR    ${salerInfo}    IN    @{items}
    \    run keyword if    "${salerInfo["saler"]}"!=""    set to dictionary    ${save}    salespersonId=${salerInfo["saler"]}
    \    run keyword if    "${salerInfo["saler"]}"!=""    exit for loop
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

创建90订单
    登录风车    15094448010    cml448010
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    Create dictionary    alipayUserId=${save["alipayUserId"]}    shopCode=${shopCode}    carId=${carId}    salespersonId=${save["salespersonId"]}    isMybankOrder=${isMybankOrder}
    ...    name=${name}    mobile=${mobile}    idCardNo=${idCardNo}    alipayAccount=${save["alipayAccount"]}    userId=${save["userId"]}    iid=${save["iid"]}
    ${json}=    rest.post    /alipay/v1/orderapplytestapi/createAccessPassedOrder.json    ${data}    form    ${leasesite_host}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    orderId=${json["data"]["orderId"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

创建200订单，下单
    登录风车    15094448010    cml448010
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${params}    Create dictionary    orderId=${save["orderId"]}    carColor=${carColor}    interiorColor=黑色
    ${json}=    Rest.post    /dealer/v1/saleorderapi/createOrder.json    ${params}    form    ${leasesite_host}
    Should Be True    ${json["success"]}
    log many    ${save}
    delete all sessions

签署合同获取验证码
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}
    ${json}=    Rest.post    /consumer/v1/agreementapi/sendCaptcha.json    ${data}    form_Auth    ${leasesite_host}
    Should Be True    ${json["success"]}
    log many    ${save}
    delete all sessions

获取taskid
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}
    ${json}    rest.post    /consumer/v1/consumerorderapi/getConciseOrderInfo.json    ${data}    form_Auth    ${leasesite_host}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    taskId=${json["data"]["taskId"]}
    set to dictionary    ${save}    orderCode=${json["data"]["orderCode"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

签署合同，校验验证码
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    taskId=${save["taskId"]}    orderId=${save["orderId"]}    captcha=${captcha}
    ${json}    rest.get    /consumer/v1/agreementapi/signAgreement.json    ${data}    form_Auth    ${leasesite_host}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

修改订单价格---暂不可用
    ${data}    create dictionary    _method=patch    order_code=528152094231    amount_yuan=0.02    charge_amount_fen=    authenticity_token=aDWBcNqMvKg+DcIi/y9Ax7zVu/YpjO1pjQ/r7UzBNHkzo6C503iEfNhnD4g/u8QVYseVSSxevxRas3mTmEDr4Q==
    ${headers}    create dictionary    Content-Type=application/x-www-form-urlencoded    Referer=http://paimaidev2.souche.com:8888/order_prices?order_code=528152094231
    Create session    _session    http://paimaidev2.souche.com:8888    headers=${headers}
    ${response}    RequestsLibrary.Patch    _session    /order_prices    headers=${headers}    data=${data}
    #用户基本信息
    #    登录弹个车    2088702670120924
    #    ${data}=    create dictionary    orderId=301655
    #    ${json}=    rest.post    /consumer/v2/consumerorderapi/getBasicConsumerInfo.json    ${data}    form_Auth    ${hosts["site5"]}
    #    Should Be True    ${json["success"]}

四要素校验
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}=    create dictionary    orderId=${save["orderId"]}    bankCardNum=${bankCardNum}    phone=${mobile}
    ${json}=    rest.post    /consumer/v2/consumerorderapi/sendCaptch.json    ${data}    form_Auth    ${leasesite_host}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    bindNo=${json["data"]["bindNo"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

绑定银行卡
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}=    create dictionary    orderId=${save["orderId"]}    bankCardNum=${bankCardNum}    bindNo=${save["bindNo"]}    phone=${mobile}    captcha=${captcha}
    ${json}=    rest.post    /consumer/v2/consumerorderapi/bindBankCard.json    ${data}    form_Auth    ${leasesite_host}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

支付验证
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}=    create dictionary    orderId=${save["orderId"]}    phone=${mobile}
    ${json}=    rest.post    /consumer/v2/consumerorderapi/payVerifyDeduct.json    ${data}    form_Auth    ${leasesite_host}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

获取销售单ID和vin码
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}=    create dictionary    current=1    pageSize=20    queryParam={"customerName":"${name}"}
    ${json}=    rest.post.inc    /admin/dispatchapi/queryDispatchPage.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    Set suite Variable    ${items}    ${json["data"]["items"]}
    : FOR    ${carInfo}    IN    @{items}
    \    run keyword if    "${carInfo["carDealId"]}"!=""    set to dictionary    ${save}    carDealId=${carInfo["carDealId"]}
    \    run keyword if    "${carInfo["vin"]}"!=""    set to dictionary    ${save}    vin=${carInfo["vin"]}
    \    run keyword if    "${carInfo["carDealId"]}"!=""    exit for loop
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

生成出库通知
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    ${data}    create dictionary    idList=[${save["carDealId"]}]
    ${json}    rest.get.inc    /admin/dispatchapi/genOutWarehouseBill.json    ${data}    json    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

确认出库登记
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${date}    startdate
    ${data}    create dictionary    vinList=["${save["vin"]}"]    date=${date}
    ${json}    rest.get.inc    /admin/inventoryApi/submitOutWarehouse.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/inventoryApi/submitOutWarehouse.json?date=2017-09-08%2018:35:49&vinList=%5B%2220172017090800001%22%5D&

接车
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    carDealId=${save["carDealId"]}    nameplateImg=["http://f.souche.com/934199c96996c8428814bdf8066cc470.jpg"]    certificationImg=["http://f.souche.com/934199c96996c8428814bdf8066cc470.jpg"]    logisticsOrderImg=["http://f.souche.com/934199c96996c8428814bdf8066cc470.jpg"]
    ${json}    rest.post.inc    /bd/v3/carreceiveapi/receive.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

接车审核
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    carDealId=${save["carDealId"]}    type=1    status=30
    ${json}    rest.get.inc    /admin/carapi/audit.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

gps安装
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data1}    create dictionary    vin=${save["vin"]}
    ${json1}    rest.post.inc    /bd/v3/gpsinfoapi/getInstalledGpsInfo.json    ${data1}    form    ${finance_host}
    Should Be True    ${json1["success"]}
    ${carInstalledGpsId}    set variable    ${json1["data"]["carInstalledGpsId"]}
    set to dictionary    ${save}    carInstalledGpsId=${carInstalledGpsId}
    ${data2}    create dictionary    carDealId=${save["carDealId"]}    gps1No=TEST01    carInstalledGpsId=${carInstalledGpsId}    gps1Imgs=["http://f.souche.com/03b0075eddb1ecf107d9fe9c83870fb8.jpg"]    supplier1Code=bsj
    ...    gps2No=TEST02    gps2Imgs=["http://f.souche.com/a14e6cd482b319d2b5d881ef3ba4e881.jpg"]    supplier2Code=bsj    gpsInstallationSheetImgs=["http://f.souche.com/934199c96996c8428814bdf8066cc470.jpg"]
    ${json2}    rest.post.inc    /bd/v3/gpsinfoapi/uploadGpsInfo.json    ${data2}    form    ${finance_host}
    Should Be True    ${json1["success"]}
    Should Be True    ${json2["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

gps审核
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    vin=${save["vin"]}    status=3    carInstalledGpsId=${save["carInstalledGpsId"]}
    ${json}    rest.get.inc    /admin/gpsapi/audit.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

交强险登记
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${commercialStartDate}=    startdate
    ${commercialEndDate}=    enddate
    # ${data}    create dictionary    compulsoryCompanyType=12    compulsoryInsuranceNo=test001    carDealId=${save["carDealId"]}    vin=${save["vin"]}    compulsoryInsuranceFee=100
    #...    behalfVehicleVesselTax=100    rawCompulsoryStartDate=${commercialStartDate}    rawCompulsoryEndDate=${commercialStartDate}    compulsoryInsuredEntity=杭州大搜车汽车服务有限公司长沙分公司    compulsoryStartDate=${commercialStartDate}    compulsoryEndDate=${commercialEndDate}
    #...    compulsoryInsuranceImg=["http://souche-devqa.oss-cn-hangzhou.aliyuncs.com/20170907/jpeg/8911a70219054cba75dd0a0de91dbe09.jpeg"]
    ${data}    create dictionary    data={"compulsoryCompanyType":"12","compulsoryInsuranceNo":"test001","carDealId":"${save["carDealId"]}","vin":"${save["vin"]}","compulsoryInsuranceFee":"100","behalfVehicleVesselTax":"100","rawCompulsoryStartDate":"${commercialStartDate}","rawCompulsoryEndDate":"${commercialStartDate}","compulsoryInsuredEntity":"杭州大搜车汽车服务有限公司长沙分公司","compulsoryStartDate":"${commercialStartDate}","compulsoryEndDate":"${commercialEndDate}","compulsoryInsuranceImg":["http://souche-devqa.oss-cn-hangzhou.aliyuncs.com/20170907/jpeg/8911a70219054cba75dd0a0de91dbe09.jpeg"]}
    ${json}    rest.get.inc    /admin/insuranceapi/compulsoryInsuranceRegister.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

商业险登记
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${commercialStartDate}=    startdate
    ${commercialEndDate}=    enddate    #    ${data}    create dictionary    commercialCompanyType=10    commercialInsuranceNo=test1234
    ...    # carDealId=${save["carDealId"]}    vin=${save["vin"]}    # commercialInsuranceFee=100    #    ...    rawCommercialStartDate=${commercialStartDate}
    ...    # rawCommercialEndDate=${commercialStartDate}    commercialInsuredEntity=杭州大搜车汽车服务有限公司长沙分公司    commercialStartDate=${commercialStartDate}    commercialEndDate=${commercialEndDate}    # commercialInsuranceImg=["http://souche-devqa.oss-cn-hangzhou.aliyuncs.com/20170908/jpg/433865077738898c112dafac93e29c7d.jpg"]
    ${data}    create dictionary    data={"commercialCompanyType":"10","commercialInsuranceNo":"test002","carDealId":"${save["carDealId"]}","vin":"${save["vin"]}","commercialInsuranceFee":"100","rawCommercialStartDate":"${commercialStartDate}","rawCommercialEndDate":"${commercialStartDate}","commercialInsuredEntity":"杭州大搜车汽车服务有限公司长沙分公司","commercialStartDate":"${commercialStartDate}","commercialEndDate":"${commercialEndDate}","commercialInsuranceImg":["http://souche-devqa.oss-cn-hangzhou.aliyuncs.com/20170908/jpg/433865077738898c112dafac93e29c7d.jpg"]}
    ${json}    rest.get.inc    /admin/insuranceapi/commercialInsuranceRegister.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/insuranceapi/commercialInsuranceRegister.json?data={"commercialCompanyType":"10","commercialInsuranceNo":"test1234","carDealId":167786,"vin":"bmzckbwindnvfsfzz","commercialInsuranceFee":100,"rawCommercialStartDate":"2017-09-08T01:58:50.001Z","rawCommercialEndDate":"2017-09-08T01:58:53.705Z","commercialInsuredEntity":"杭州大搜车汽车服务有限公司长沙分公司","commercialStartDate":"2017-09-08 09:58:50","commercialEndDate":"2017-09-08 09:58:53","commercialInsuranceImg":["http://souche-devqa.oss-cn-hangzhou.aliyuncs.com/20170908/jpg/433865077738898c112dafac93e29c7d.jpg"]}&
    #获取receiverId
    #    登录souche-inc    18808080808    souche2015
    #    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    #    ${data}    create dictionary    current=1    pageSize=20    queryParam={"vin":"${save["vin"]}"}
    #    ${json}    rest.post.inc    /admin/insuranceapi/insuranceManageList.json    ${data}    form    ${finance_host_inc}
    #    Should Be True    ${json["success"]}
    #    set to dictionary    ${save}    receiverId=${json["data"]["items"]["carDealExpressDO"]["receiverId"]}
    #    set to dictionary    ${save}    receiverPhone=${json["data"]["items"]["carDealExpressDO"]["receiverPhone"]}
    #    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    #    log many    ${save}

根据cityCode查询该城市下的所有主管人员信息
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    cityCode=01841
    ${json}    rest.get.inc    /admin/carfundsapplyapi/findCityConfByCityCode.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    ${data}=    set variable    ${json["data"]}
    : FOR    ${cityconf}    IN    @{data}
    \    run keyword if    "${cityconf["bdId"]}"!=""    set to dictionary    ${save}    receiverId=${cityconf["bdId"]}
    \    run keyword if    "${cityconf["contactPhone"]}"!=""    set to dictionary    ${save}    contactPhone=${cityconf["contactPhone"]}
    \    run keyword if    "${cityconf["bdId"]}"!=""    exit for loop
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

寄送交强险资料
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${carDealId}    create list    ${save["carDealId"]}
    ${data}    create dictionary    carDealIds=${carDealId}    expressCompanyName=顺丰快递    expressNo=test001    receiverId=${save["receiverId"]}
    ${json}    rest.get.inc    /admin/logisticsmanagementapi/sendCompulsoryInsurance.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/logisticsmanagementapi/sendCompulsoryInsurance.json?carDealIds=%5B167786%5D&expressCompanyName=%E9%A1%BA%E4%B8%B0%E5%BF%AB%E9%80%92&expressNo=test001&receiverId=FAQRm0SMNg&

寄送发票&合格证资料
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${carDealId}    create list    ${save["carDealId"]}
    ${data}    create dictionary    carDealIds=${carDealId}    expressCompanyName=顺丰快递    expressNo=test002    receiverId=${save["receiverId"]}
    ${json}    rest.get.inc    /admin/logisticsmanagementapi/sendInvoiceAndCertificate.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/logisticsmanagementapi/sendInvoiceAndCertificate.json?carDealIds=%5B167786%5D&expressCompanyName=%E9%A1%BA%E4%B8%B0%E9%80%9F%E8%BF%90&expressNo=test22&receiverId=FAQRm0SMNg&

根据carDealId查找单个款项申请详情
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    carDealId=${save["carDealId"]}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/findCarFundsDetailByCarDealId.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    ${purTaxApplyNo}=    purTaxApplyNo
    set to dictionary    ${save}    purTaxApplyNo=${purTaxApplyNo}
    set to dictionary    ${save}    payee=${json["data"]["payee"]}
    set to dictionary    ${save}    payeeBankNo=${json["data"]["payeeBankNo"]}
    set to dictionary    ${save}    payeeBankName=${json["data"]["payeeBankName"]}
    set to dictionary    ${save}    tempPurchaseTax=${json["data"]["tempPurchaseTax"]}
    set to dictionary    ${save}    tempRegisterCost=${json["data"]["tempRegisterCost"]}
    set to dictionary    ${save}    registerCityType=${json["data"]["registerCityType"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

购置税杂费申请
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    #${carInfoList}    create dictionary    carDealId=${save["carDealId"]}    tempPurchaseTax=${save["tempPurchaseTax"]}    tempRegisterCost=${save["tempRegisterCost"]}    registerCityType=${save["registerCityType"]}
    #${carInfoList}    create list    ${carInfoList}
    #${carFundsApplyParamList}    create dictionary    carInfoList=${carInfoList}    applyNo=${save["purTaxApplyNo"]}    payee=${save["payee"]}    dituiId=${save["receiverId"]}    payeeBankNo=${save["payeeBankNo"]}
    #...    payeeBankName=${save["payeeBankName"]}    totalTempPurchaseTax=${save["tempPurchaseTax"]}    totalTempRegisterCost=${save["tempRegisterCost"]}    payeeContact=${save["contactPhone"]}
    #${carFundsApplyParamList}    create list    ${carFundsApplyParamList}
    ${data}    create dictionary    carFundsApplyParamList=[{"carInfoList":[{"carDealId":"${save["carDealId"]}","tempPurchaseTax":"${save["tempPurchaseTax"]}","tempRegisterCost":"${save["tempRegisterCost"]}","registerCityType":"${save["registerCityType"]}"}],"applyNo":"${save["purTaxApplyNo"]}","payee":"${save["payee"]}","dituiId":"${save["receiverId"]}","payeeBankNo":"${save["payeeBankNo"]}","payeeBankName":"${save["payeeBankName"]}","payeeContact":"${save["contactPhone"]}","totalTempPurchaseTax":"${save["tempPurchaseTax"]}","totalTempRegisterCost":"${save["tempRegisterCost"]}"}]    applyNo=${save["purTaxApplyNo"]}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/applyPurTax.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carfundsapplyapi/applyPurTax.json?carFundsApplyParamList=%5B%7B%22carInfoList%22%3A%5B%7B%22carDealId%22%3A167786%2C%22tempPurchaseTax%22%3A0%2C%22tempRegisterCost%22%3A70000%2C%22registerCityType%22%3A%22B%22%7D%5D%2C%22applyNo%22%3A%22SQ2017090808976%22%2C%22payee%22%3A%22%E8%92%8B%E6%99%A8%22%2C%22dituiId%22%3A%22FAQRm0SMNg%22%2C%22payeeBankNo%22%3A%226885551000999999999%22%2C%22payeeBankName%22%3A%22%E5%B7%A5%E5%95%86%E9%93%B6%E8%A1%8C%22%2C%22payeeContact%22%3A%2215858202767%22%2C%22totalTempPurchaseTax%22%3A0%2C%22totalTempRegisterCost%22%3A70000%7D%5D&applyNo=SQ2017090808976&

根据条件查询款项申请和打款申请单
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    current=1    pageSize=20    queryParam={"content":"${save["vin"]}","searchType":"2","type":"1"}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/carFundsApplyBillList.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    ${items}=    set variable    ${json["data"]["items"]}
    : FOR    ${info}    IN    @{items}
    \    run keyword if    "${info["carFundsApplyBillId"]}"!=""    set to dictionary    ${save}    purTaxBillIds=${info["carFundsApplyBillId"]}
    \    run keyword if    "${info["carFundsApplyBillId"]}"!=""    exit for loop
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carfundsapplyapi/carFundsApplyBillList.json?current=1&pageSize=20&queryParam=%7B%22searchType%22%3A2%2C%22lastDateChecked%22%3A0%2C%22type%22%3A1%2C%22content%22%3A%22bmzckbwindnvfsfzz%22%7D&

获取打款申请单
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    carFundsPayApplyBillIds=[${save["purTaxBillIds"]}]    isPayApply=true
    ${json}    rest.get.inc    /admin/carfundsapplyapi/getPurTaxPayApplyListForPayAndApply.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    purTaxPayApplyNo=${json["data"]["applyNo"]}
    log many    ${save}
    delete all sessions

生成打款申请单
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    carFundsPayApplyBillIds=[${save["carFundsApplyBillId"]}]    applyNo=${save["purTaxPayApplyNo"]}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/applyCarFundsPayApplyBill.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carfundsapplyapi/applyCarFundsPayApplyBill.json?carFundsPayApplyBillIds=%5B1892%5D&applyNo=DK2017090853955&

根据条件查询款项申请和打款申请单
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    current=1    pageSize=20    queryParam={"content":"${save["vin"]}","searchType":"3","type":"1"}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/carFundsApplyBillList.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    ${items}=    set variable    ${json["data"]["items"]}
    : FOR    ${info}    IN    @{items}
    \    run keyword if    "${info["carFundsApplyBillId"]}"!=""    set to dictionary    ${save}    purTaxPayApplyBillId=${info["carFundsApplyBillId"]}
    \    run keyword if    "${info["applyBillNo"]}"!=""    set to dictionary    ${save}    purTaxPayApplyNo=${info["applyBillNo"]}
    \    run keyword if    "${info["carFundsApplyBillId"]}"!=""    exit for loop
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

财务打款接口
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    purTaxBillIds=[${save["purTaxBillIds"]}]    applyPurTaxPayCarDealIds=[${save["carDealId"]}]    purTaxPayApplyBillId=${save["purTaxPayApplyBillId"]}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/applyPurTaxPay.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carfundsapplyapi/applyPurTaxPay.json?purTaxPayApplyBillId=1893&purTaxBillIds=%5B1892%5D&applyPurTaxPayCarDealIds=%5B167786%5D&

获取款项明细
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}=    create dictionary    pageNo=1    pageSize=20    isReceived=false    keyword=${save["vin"]}
    ${json}=    rest.post.inc    /bd/v3/foundsreceiveapi/getList.json    ${data}    form    ${finance_host}
    Should Be True    ${json["success"]}
    ${list}=    set variable    ${json["data"]["items"]}
    : FOR    ${data}    IN    @{list}
    \    run keyword if    "${data["carFundsPayRecordId"]}"!=""    set to dictionary    ${save}    carFundsPayRecordId=${data["carFundsPayRecordId"]}
    \    run keyword if    "${data["carFundsPayRecordId"]}"!=""    exit for loop
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

确认收款
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}=    create dictionary    carFundsPayRecordId=${save["carFundsPayRecordId"]}
    ${json}=    rest.post.inc    /bd/v3/foundsreceiveapi/receive.json    ${data}    form    ${finance_host}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/bd/v3/foundsreceiveapi/receive.json    carFundsPayRecordId=872

获取/搜索资料接收列表
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}=    create dictionary    pageNo=1    pageSize=20    expressStatus=2    keyword=${save["vin"]}
    ${json}=    rest.post.inc    /bd/v3/materialreceiveapi/getList.json    ${data}    form    ${finance_host}
    Should Be True    ${json["success"]}
    ${list}=    set variable    ${json["data"]["items"]}
    : FOR    ${data}    IN    @{list}
    \    run keyword if    "${data["dealExpressTypeDesc"]}"=="交强险单寄送"    set to dictionary    ${save}    expressId1=${data["expressId"]}    else if
    \    ...    "${data["dealExpressTypeDesc"]}"=="商业险单寄送"    set to dictionary    ${save}    expressId2=${data["expressId"]}
    \    run keyword if    "${save["expressId2"]}" and "${save["expressId1"]}!=""    exit for loop
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

接收保险单/发票合格证信息
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${abnormalCarDeals}    create list
    ${data1}=    create dictionary    expressId=${save["expressId1"]}    carDealIds=["${save["carDealId"]}"]    abnormalCarDeals=${abnormalCarDeals}
    ${data2}    create dictionary    expressId=${save["expressId2"]}    carDealIds=["${save["carDealId"]}"]    abnormalCarDeals=${abnormalCarDeals}
    ${json1}=    rest.post.inc    /bd/v3/materialreceiveapi/receive.json    ${data1}    form    ${finance_host}
    ${json2}=    rest.post.inc    /bd/v3/materialreceiveapi/receive.json    ${data2}    form    ${finance_host}
    Should Be True    ${json1["success"]}
    Should Be True    ${json2["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

交车申请
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${plateNo}  plate_number
    ${data}=    create dictionary    carDealId=${save["carDealId"]}    plateNo=${plateNo}    drivingLicenseImg=["http://f.souche.com/2acfb5319b7f70b0b48f02058915fb3d.jpg"]    registrationCertificateImg=["http://f.souche.com/ee313291ac52a7bd19196bd82f7eb377.jpg"]    purchaseInvoiceImg=["http://f.souche.com/33b7bfb39029283d9a61786eaa289fde.jpg"]
    ...    purchaseTaxInvoiceImg=["http://f.souche.com/03b0075eddb1ecf107d9fe9c83870fb8.jpg"]    purchaseTaxInvoiceAmount=0.00    licensingFeeInvoiceImg=["http://f.souche.com/65f0f9af4b48636d272d30a0ce1649e2.jpg"]    licensingFeeInvoiceAmount=0.00
    ${json}=    rest.post.inc    /bd/v3/cardeliveryapplyapi/applyDelivery.json    ${data}    form    ${finance_host}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions
    #http://finance-car-manage.sqaproxy.souche-inc.com/bd/v3/cardeliveryapplyapi/applyDelivery.json    carDealId=34070&plateNo=TEST001&drivingLicenseImg=%5B%22http%3A%2F%2Ff.souche.com%2F2acfb5319b7f70b0b48f02058915fb3d.jpg%22%5D&registrationCertificateImg=%5B%22http%3A%2F%2Ff.souche.com%2Fee313291ac52a7bd19196bd82f7eb377.jpg%22%5D&purchaseInvoiceImg=%5B%22http%3A%2F%2Ff.souche.com%2F33b7bfb39029283d9a61786eaa289fde.jpg%22%5D&purchaseTaxInvoiceImg=%5B%22http%3A%2F%2Ff.souche.com%2F03b0075eddb1ecf107d9fe9c83870fb8.jpg%22%5D&purchaseTaxInvoiceAmount=0.00&licensingFeeInvoiceImg=%5B%22http%3A%2F%2Ff.souche.com%2F65f0f9af4b48636d272d30a0ce1649e2.jpg%22%5D&licensingFeeInvoiceAmount=0.00&remarks=sss%0A

手工支付采购款
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}=    create dictionary    orderId=${save["orderId"]}    key=p9asidfupOIUFOPDIekwdr
    ${json}=    rest.post.inc    /admin/loanmanualapi/repay.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

打款回调
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}    create dictionary    data[order][product_id]=${save["orderCode"]}    data[order][trade_code]=${save["orderCode"]}    success=true    msg=true    data[event][type]=settled
    ...    code=true
    ${json}    rest.get    /callback/v1/chargeapi/payToSellerResult.json    ${data}    json    ${leasesite_host}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

审核车辆信息
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}=    create dictionary    carDealId=${save["carDealId"]}    type=2    status=30
    ${json}=    rest.get.inc    /admin/carapi/audit.json    ${data}    form    ${finance_host_inc}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carapi/audit.json?carDealId=167786&type=2&status=30&

车商确认交车
    登录风车    15094448010    cml448010
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    ${data}=    create dictionary    orderId=${save["orderId"]}
    ${json}=    rest.post    /dealer/v1/saleorderapi/confirmPickup.json    ${data}    form    ${leasesite_host}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

获取taskid
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}
    ${json}    rest.post    /consumer/v1/consumerorderapi/getConciseOrderInfo.json    ${data}    form_Auth    ${leasesite_host}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    taskId=${json["data"]["taskId"]}
    set to dictionary    ${save}    orderCode=${json["data"]["orderCode"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

获取验证码
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}
    ${json}    rest.get    /consumer/v1/agreementapi/sendCaptcha.json    ${data}    form_Auth    ${leasesite_host}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions

确认提车
    ${save}=    get_from_file    弹个车订单/新车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}    taskId=${save["taskId"]}    captcha=${captcha}
    ${json}    rest.post    /consumer/v1/agreementapi/confirmPickUp.json    ${data}    form_Auth    ${leasesite_host}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/新车弹个车订单/save.txt    ${save}
    log many    ${save}
    delete all sessions