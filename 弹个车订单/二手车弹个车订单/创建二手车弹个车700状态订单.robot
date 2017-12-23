*** Setting ***
Library           RequestsLibrary
Library           Collections
Resource          ../common.robot
Library           ../MyLibrary.py
Variables         ../sql_scripts.py

*** Variables ***
${authCode}       79519dd35e9c4196a65a5439ba34QD84
${shopCode}       00102063     #002166阿拉蕾    00102063大鹏
${salespersonId}    Nn4QNs7Ulk      #002166--uZcZjlG9NQ   00102063--Nn4QNs7Ulk
${name}           陈明亮    #刘梦    #李欣莉
${isMybankOrder}    1
${mobile}         13575730431    #15869182946
${idCardNo}       130427199112120915    #130427199112120915    #332525199305240923
${captcha}        158460    #获取到弹个车验证码后填写，签署合同
#${vin}           WBA3N110XEK303444    #可以根据 ${carId} 从数据库获取
${carId}          761df01083464e068fb7bda4e5581800    #carid
${carColor}       {"color": "#FFFFFF","value": "珠光白"}    #车型颜色
${alipayAccount}    13575730431
${alipayUserId}    2088802650971848
${userId}         udes6b3Pkb    #测试环境：udes6b3Pkb陈明亮
${iid}            1314144    #测试环境：1314144陈明亮
${productId}      1    #新车金融产品Id,二手车改字段不为空即可
${alipayVersion}    1.1.1    #支付宝客户端版本，格式按照1.1.1设置即可
${bankCardNum}    \    #银行卡
${orderid}        ${EMPTY}
${}               ${EMPTY}
#${save["orderId"]}
&{hosts}          site1=http://leasesite1.sqaproxy.souche.com    site2=http://leasesite2.sqaproxy.souche.com    site3=http://leasesite3.sqaproxy.souche.com    site4=http://leasesite4.sqaproxy.souche.com    site5=http://leasesite5.sqaproxy.souche.com    finance-car-manage=http://finance-car-manage.sqaproxy.souche.com
...               site9=http://leasesite1.sqaproxy.dasouche.net
...               #预发环境：http://lease.prepub.souche.com    线上：http://lease.souche.com

*** Test Cases ***
取消已经生成的订单-接口
    取消弹个车订单     ${alipayUserId}

创建二手车金融产品
    发车      15000001111    souche2015


创建90订单
    #获取userId、iid、mobile、name    此处改为直接录入，减少创建时间和错误率
    #    ${data}=    create dictionary    authCode=${authCode}
    #    ${json}=    rest.post    /consumer/v1/authapi/login.json    ${data}    form    ${hosts["site3"]}
    #    Should Be True    ${json["success"]}
    #    set suite variable    ${userId}    ${json["data"]["consumerVO"]["userId"]}
    #    ${save}=    create dictionary    userId=${json["data"]["consumerVO"]["userId"]}    iid=${json["data"]["consumerVO"]["iid"]}    token=${json["data"]["consumerVO"]["token"]}    alipayUserId=${json["data"]["consumerVO"]["aliPayUserId"]}
    # alipayAccount=${json["data"]["consumerVO"]["loginPhone"]}
    #    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    #    logmany    ${save}
    #获取车辆销售ID    此处改为直接录入，减少创建时间和错误率
    #    登录风车    15094448010    cml448010
    #    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    #    ${data}    create dictionary
    #    ${json}    rest.get    /v2/users/follows/getSalers    ${data}    form    http://crm.sqaproxy.souche.com
    #    Should Be True    ${json["success"]}
    #    Set suite Variable    ${items}    ${json["data"]["items"]}
    #    : FOR    ${salerInfo}    IN    @{items}
    #    ${salespersonId}=    run keyword if    "${salerInfo["saler"]}"!=""    set variable    ${salerInfo["saler"]}
    #    log    ${salespersonId}
    #    run keyword if    "${salerInfo["saler"]}"!=""    exit for loop
    #    set to dictionary    ${save}    salespersonId=${salespersonId}
    #    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    #    logmany    ${save}
    set test variable    ${shopCode}    ${shopCode}
    ${rowset}    DB.QueryOne    dealership    ${select_sec_relate}
    log    ${rowset["car_id"]}
    log    ${rowset["product_id"]}
    登录风车    15094448010    cml448010
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}    Create dictionary    alipayUserId=${alipayUserId}    shopCode=${shopCode}    carId=${rowset["car_id"]}    salespersonId=${salespersonId}    isMybankOrder=${isMybankOrder}
    ...    name=${name}    mobile=${mobile}    idCardNo=${idCardNo}    alipayAccount=${alipayAccount}    userId=${userId}    iid=${iid}
    ...    productId=${rowset["product_id"]}    alipayVersion=${alipayVersion}
    ${json}=    rest.post    /alipay/v1/orderapplytestapi/createAccessPassedOrder.json    ${data}    form    ${hosts["site9"]}
    log     创建90订单返回结果：${json["data"]["message"]}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    orderId=${json["data"]["orderId"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    log     ${json["orderId"]}

创建200状态，下单
    登录风车    15000001111    souche2015   #周鹏的店铺
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${params}    Create dictionary    orderId=${save["orderId"]}    carColor=    interiorColor=黑色
    ${json}=    Rest.post    /dealer/v1/saleorderapi/createOrder.json    ${params}    form    ${hosts["site9"]}
    Should Be True    ${json["success"]}
    logmany    ${save}
    log    ${json['data']['order_code']}

签署合同获取验证码
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}
    ${json}=    Rest.post    /consumer/v1/agreementapi/sendCaptcha.json    ${data}    form_Auth    ${hosts["site4"]}
    Should Be True    ${json["success"]}
    logmany    ${save}

获取taskid
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}
    ${json}    rest.post    /consumer/v1/consumerorderapi/getConciseOrderInfo.json    ${data}    form_Auth    ${hosts["site5"]}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    taskId=${json["data"]["taskId"]}
    set to dictionary    ${save}    orderCode=${json["data"]["orderCode"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

签署合同，校验验证码
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    taskId=${save["taskId"]}    orderId=${save["orderId"]}    captcha=${captcha}
    ${json}    rest.get    /consumer/v1/agreementapi/signAgreement.json    ${data}    form_Auth    ${hosts["site1"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

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
    #数据库获取vin码
    #    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    #    set test variable    ${order_id}    ${save["orderId"]}
    #    ${row}=    DB.QueryOne    finance_car_lease_v3    ${get_vin}
    #    set to dictionary    ${save}    vin=${row["vin"]}
    #    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    #    log many    ${save}

支付首付后回调
    #未验证
    ${save}    get from file    弹个车订单/二手车弹个车订单/save.txt
    set to variable    ${orderId}    ${save["orderId"]}
    ${row}    DB.QueryOne    finance_car_lease_v3    ${get_order}
    set suite variable    ${order_code}    ${row["order_code"]}    #数据库获取order_code
    ${data}    create dictionary    order_code=${order_code}    status=pai_to_platform
    ${json}    rest.get    /callback/v1/ordercenterapi/firstPayResult.json    ${data}    form    ${hosts["site3"]}
    SHOULD BE TRUE    ${json["success"]}
    set to dictionary    ${save}    order_code=${order_code}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    #接口获取vin码
    #    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    #    登录风车    15094448010    cml448010
    #    ${data}    create dictionary    carId=${carId}
    #    ${json}    rest.get    /app/car/appcarsearchaction/getCarDetail.json    ${data}    form    http://erp-test.sqaproxy.souche.com
    #    should be true    ${json["success"]}
    #    set to dictionary    ${save}    vin=${json["data"]["vin"]}
    #    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    #    logmany    ${save}
    #    log    ${save["vin"]}

车商-销售提交车辆凭证材料
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    set test variable    ${order_id}    ${save["orderId"]}
    ${row}    DB.QueryOne    finance_car_lease_v3    ${get_vin}    #数据库获取vin
    set suite variable    ${vin}    ${row["vin"]}
    登录风车    15094448010    cml448010
    ${data}    create dictionary    orderId=${save["orderId"]}    vin=${vin}    vehicleRegistrationImg=http://img.souche.com/files/default/8048bb8a95697023c4ee7aaba043179e.jpg    drivingLicenseImg=http://img.souche.com/files/default/306fa7c725005d414a978a1374d79f47.jpg    oldNameplateImg=http://img.souche.com/files/default/d0fde40a08fbececf0c282e496007119.jpg
    ...    dashboardImg=http://img.souche.com/files/default/9b232722977156bb57d632312c952f59.jpg    detailImgs=http://img.souche.com/files/default/75076e032293108cd71511b7894b52f5.jpg","http://img.souche.com/files/default/2812715c7defb8bf292068df069b7616.jpg","http://img.souche.com/files/default/cf1a55431a1c29229e9bcd83bd2043af.jpg","http://img.souche.com/files/default/df0014d02e2d24b1aef4058cbfa53d26.jpg    farmoutAgreementImg=http://img.souche.com/files/default/94c11f39a683ec52dd7de3a8794d4b92.jpg    leasebackAgreementImg=http://img.souche.com/files/default/b67d9b58923505fbe5cd5f5a2dd393dc.jpg    carKeyImg=http://img.souche.com/files/default/e708fd77027d0160c53231560e143d4e.jpg    insuranceSlipImg=http://img.souche.com/files/default/bbfddde8602a4e9134a190ae437932be.jpg
    ${response}    rest.post    /dealer/v1/saleorderapi/submitVinInfo.json    ${data}    form    ${hosts["site5"]}
    Should Be True    ${response["success"]}
    set to dictionary    ${save}    vin=${vin}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

获取carDealId
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${queryParam}    create dictionary    content=${save["vin"]}    type=1
    ${data}    create dictionary    current=1    pageSize=20    queryParam=${queryParam}
    ${json}    rest.get.inc    /admin/carapi/carList.json    ${data}    form    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    Set suite Variable    ${items}    ${json["data"]["items"]}
    : FOR    ${carList}    IN    @{items}
    \    ${carDealId}=    run keyword if    "${carList["carDealDO"]["carDealId"]}"!=""    set variable    ${carList["carDealDO"]["carDealId"]}
    \    log    ${carDealId}
    \    run keyword if    "${carList["carDealDO"]["carDealId"]}"!=""    exit for loop
    set to dictionary    ${save}    carDealId=${carDealId}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

车辆凭证审核
    登录souche-inc    13575730431    123456
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}    create dictionary    carDealId=${save["carDealId"]}    type=1    status=30
    ${json}    rest.get.inc    /admin/carapi/audit.json    ${data}    form    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

gps安装
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data1}    create dictionary    vin=${save["vin"]}
    ${json1}    rest.post.inc    /bd/v3/gpsinfoapi/getInstalledGpsInfo.json    ${data1}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json1["success"]}
    ${carInstalledGpsId}    set variable    ${json["data"]["carInstalledGpsId"]}
    set to dictionary    ${save}    carInstalledGpsId=${carInstalledGpsId}
    ${data2}    create dictionary    carDealId=${save["carDealId"]}    gps1No=TEST01    carInstalledGpsId=${carInstalledGpsId}    gps1Imgs=["http://f.souche.com/03b0075eddb1ecf107d9fe9c83870fb8.jpg"]    supplier1Code=bsj
    ...    gps2No=TEST02    gps2Imgs=["http://f.souche.com/a14e6cd482b319d2b5d881ef3ba4e881.jpg"]    supplier2Code=bsj    gpsInstallationSheetImgs=["http://f.souche.com/934199c96996c8428814bdf8066cc470.jpg"]
    ${json2}    rest.post.inc    /bd/v3/gpsinfoapi/uploadGpsInfo.json    ${data2}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json1["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

gps审核
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}    create dictionary    vin=${save["vin"]}    status=3    carInstalledGpsId=${save["carInstalledGpsId"]}
    ${json}    rest.get.inc    /admin/gpsapi/audit.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json1["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

交强险登记
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}    create dictionary    compulsoryCompanyType=12    compulsoryInsuranceNo=test001    carDealId=${save["carDealId"]}    vin=${save["vin"]}    compulsoryInsuranceFee=100
    ...    behalfVehicleVesselTax=100    rawCompulsoryStartDate=    rawCompulsoryEndDate    compulsoryInsuredEntity=杭州大搜车汽车服务有限公司长沙分公司    compulsoryStartDate=    compulsoryEndDate=
    ...    compulsoryInsuranceImg=["http://souche-devqa.oss-cn-hangzhou.aliyuncs.com/20170907/jpeg/8911a70219054cba75dd0a0de91dbe09.jpeg"]
    ${data}    create dictionary    data=${data}
    ${json}    rest.get.inc    /admin/insuranceapi/compulsoryInsuranceRegister.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json1["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

商业险等级
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}    create dictionary    commercialCompanyType=10    commercialInsuranceNo=test1234    carDealId=${save["carDealId"]}    vin=${save["vin"]}    commercialInsuranceFee=100
    ...    rawCommercialStartDate    rawCommercialEndDate    commercialInsuredEntity=杭州大搜车汽车服务有限公司长沙分公司    commercialStartDate    commercialEndDate    commercialInsuranceImg=["http://souche-devqa.oss-cn-hangzhou.aliyuncs.com/20170908/jpg/433865077738898c112dafac93e29c7d.jpg"]
    ${data}    create dictionary    data=${data}
    ${json}    rest.get.inc    /admin/insuranceapi/commercialInsuranceRegister.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json1["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/insuranceapi/commercialInsuranceRegister.json?data={"commercialCompanyType":"10","commercialInsuranceNo":"test1234","carDealId":167786,"vin":"bmzckbwindnvfsfzz","commercialInsuranceFee":100,"rawCommercialStartDate":"2017-09-08T01:58:50.001Z","rawCommercialEndDate":"2017-09-08T01:58:53.705Z","commercialInsuredEntity":"杭州大搜车汽车服务有限公司长沙分公司","commercialStartDate":"2017-09-08 09:58:50","commercialEndDate":"2017-09-08 09:58:53","commercialInsuranceImg":["http://souche-devqa.oss-cn-hangzhou.aliyuncs.com/20170908/jpg/433865077738898c112dafac93e29c7d.jpg"]}&

获取receiverId
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${queryParam}    create dictionary    vin=${save["vin"]}
    ${data}    create dictionary    current=1    pageSize=20    queryParam=${queryParam}
    ${json}    rest.get.inc    /admin/insuranceapi/insuranceManageList.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    receiverId=${json["data"]["items"]["carDealExpressDO"]["receiverId"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

寄送交强险资料
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${carDealId}    create list    ${save["carDealId"]}
    ${data}    create dictionary    carDealId=${carDealId}    expressCompanyName=顺丰快递    expressNo=test001    receiverId=${save["receiverId"]}
    ${json}    rest.get.inc    /admin/logisticsmanagementapi/sendCompulsoryInsurance.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/logisticsmanagementapi/sendCompulsoryInsurance.json?carDealIds=%5B167786%5D&expressCompanyName=%E9%A1%BA%E4%B8%B0%E5%BF%AB%E9%80%92&expressNo=test001&receiverId=FAQRm0SMNg&

寄送发票&合格证资料
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${carDealId}    create list    ${save["carDealId"]}
    ${data}    create dictionary    carDealId=${carDealId}    expressCompanyName=顺丰快递    expressNo=test002    receiverId=${save["receiverId"]}
    ${json}    rest.get.inc    /admin/logisticsmanagementapi/sendInvoiceAndCertificate.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/logisticsmanagementapi/sendInvoiceAndCertificate.json?carDealIds=%5B167786%5D&expressCompanyName=%E9%A1%BA%E4%B8%B0%E9%80%9F%E8%BF%90&expressNo=test22&receiverId=FAQRm0SMNg&

根据carDealId查找单个款项申请详情
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}    create dictionary    carDealId=${save["carDealId"]}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/findCarFundsDetailByCarDealId.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    purTaxApplyNo=${json["data"]["purTaxApplyNo"]}
    set to dictionary    ${save}    purTaxPayApplyNo=${json["data"]["purTaxPayApplyNo"]}
    set to dictionary    ${save}    payee=${json["data"]["payee"]}
    set to dictionary    ${save}    payeeBankNo=${json["data"]["payeeBankNo"]}
    set to dictionary    ${save}    payeeBankName=${json["data"]["payeeBankName"]}
    set to dictionary    ${save}    tempPurchaseTax=${json["data"]["tempPurchaseTax"]}
    set to dictionary    ${save}    tempRegisterCost=${json["data"]["tempRegisterCost"]}
    set to dictionary    ${save}    registerCityType=${json["data"]["${json["data"]["tempRegisterCost"]}"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

购置税杂费申请
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${carInfoList}    create dictionary    carDealId=${save["carDealId"]}    tempPurchaseTax=${save["tempPurchaseTax"]}    tempRegisterCost=${save["tempRegisterCost"]}    registerCityType=${save["registerCityType"]}
    ${carInfoList}    create list    ${carInfoList}
    ${carFundsApplyParamList}    create dictionary    carInfoList=${carInfoList}    applyNo=${save["purTaxApplyNo"]}    payee=${save["payee"]}    dituiId=${save["receiverId"]}    payeeBankNo=${save["payeeBankNo"]}
    ...    payeeBankName=${save["payeeBankName"]}    totalTempPurchaseTax=${save["tempPurchaseTax"]}    totalTempRegisterCost=${save["tempRegisterCost"]}    payeeContact=15858202767
    ${carFundsApplyParamList}    create list    ${carFundsApplyParamList}
    ${data}    create dictionary    carFundsApplyParamList${carFundsApplyParamList}    applyNo=${save["purTaxApplyNo"]}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/applyPurTax.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carfundsapplyapi/applyPurTax.json?carFundsApplyParamList=%5B%7B%22carInfoList%22%3A%5B%7B%22carDealId%22%3A167786%2C%22tempPurchaseTax%22%3A0%2C%22tempRegisterCost%22%3A70000%2C%22registerCityType%22%3A%22B%22%7D%5D%2C%22applyNo%22%3A%22SQ2017090808976%22%2C%22payee%22%3A%22%E8%92%8B%E6%99%A8%22%2C%22dituiId%22%3A%22FAQRm0SMNg%22%2C%22payeeBankNo%22%3A%226885551000999999999%22%2C%22payeeBankName%22%3A%22%E5%B7%A5%E5%95%86%E9%93%B6%E8%A1%8C%22%2C%22payeeContact%22%3A%2215858202767%22%2C%22totalTempPurchaseTax%22%3A0%2C%22totalTempRegisterCost%22%3A70000%7D%5D&applyNo=SQ2017090808976&

根据条件查询款项申请和打款申请单
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${queryParam1}    create dictionary    content=${save["vin"]}    searchType=2    type=1
    ${queryParam2}    create dictionary    content=${save["vin"]}    searchType=3    type=1
    ${data1}    create dictionary    current=1    pageSize=20    queryParam=${queryParam1}
    ${data2}    create dictionary    current=1    pageSize=20    queryParam=${queryParam2}
    ${json1}    rest.get.inc    /admin/carfundsapplyapi/carFundsApplyBillList.json    ${data1}    json    ${hosts["finance-car-manage"]}
    ${json2}    rest.get.inc    /admin/carfundsapplyapi/carFundsApplyBillList.json    ${data2}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json1["success"]}
    Should Be True    ${json2["success"]}
    set to dictionary    ${save}    purTaxBillIds=${json1["data"]["items"]["carFundsApplyBillId"]}
    set to dictionary    ${save}    purTaxPayApplyBillId=${json2["data"]["items"]["carFundsApplyBillId"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carfundsapplyapi/carFundsApplyBillList.json?current=1&pageSize=20&queryParam=%7B%22searchType%22%3A2%2C%22lastDateChecked%22%3A0%2C%22type%22%3A1%2C%22content%22%3A%22bmzckbwindnvfsfzz%22%7D&

生成打款申请单
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${carFundsPayApplyBillIds}    create list    ${save["purTaxBillIds"]}
    ${data}    create dictionary    carFundsPayApplyBillIds=${carFundsPayApplyBillIds}    applyNo=${save["purTaxPayApplyNo"]}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/applyCarFundsPayApplyBill.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carfundsapplyapi/applyCarFundsPayApplyBill.json?carFundsPayApplyBillIds=%5B1892%5D&applyNo=DK2017090853955&

财务打款接口
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${purTaxBillIds}    create list    ${save["purTaxBillIds"]}
    ${applyPurTaxPayCarDealIds}    create list    ${save["carDealId"]}
    ${data}    create dictionary    purTaxBillIds=${purTaxBillIds}    applyPurTaxPayCarDealIds=${applyPurTaxPayCarDealIds}    purTaxPayApplyBillId=${save["purTaxPayApplyBillId"]}
    ${json}    rest.get.inc    /admin/carfundsapplyapi/applyPurTaxPay.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carfundsapplyapi/applyPurTaxPay.json?purTaxPayApplyBillId=1893&purTaxBillIds=%5B1892%5D&applyPurTaxPayCarDealIds=%5B167786%5D&

打款回调
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}    create dictionary    data[order][product_id]=${save["orderCode"]}    data[order][trade_code]=${save["orderCode"]}    success=true    msg=true    data[event][type]=settled
    ...    code=true
    ${json}    rest.get    /callback/v1/chargeapi/payToSellerResult.json    ${data}    json    ${hosts["site5"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://leasesite5.sqaproxy.souche.com/callback/v1/chargeapi/payToSellerResult.json?data%5Border%5D%5Bid%5D=&data%5Border%5D%5Bproduct_id%5D=512829704121&data%5Border%5D%5Btrade_code%5D=512829704121&success=true&msg=true&data%5Bevent%5D%5Btype%5D=settled&code=true

获取款项明细
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}=    create dictionary    pageNo=1    pageSize=20    isReceived=false    keyword=${save["vin"]}
    ${json}=    rest.post.inc    /bd/v3/foundsreceiveapi/getList.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    ${json["data"]["items"]["carFundsPayRecordId"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

确认收款
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}=    create dictionary    carFundsPayRecordId=${save["carFundsPayRecordId"]}
    ${json}=    rest.post.inc    /bd/v3/foundsreceiveapi/receive.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/bd/v3/foundsreceiveapi/receive.json    carFundsPayRecordId=872

获取/搜索资料接收列表
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}=    create dictionary    pageNo=1    pageSize=20    expressStatus=2    keyword=${save["vin"]}
    ${json}=    rest.post.inc    /bd/v3/materialreceiveapi/getList.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    ${json["data"]["items"]["expressId"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

接收保险单/发票合格证信息
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${abnormalCarDeals}    create list
    ${data}=    create dictionary    expressId=${save["expressId"]}    carDealIds=${carDealIds}    abnormalCarDeals=${abnormalCarDeals}
    ${json}=    rest.post.inc    /bd/v3/materialreceiveapi/receive.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

交车申请
    登录工作台    15858202767    123456
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}=    create dictionary    carDealId=${save["carDealId"]}    plateNo=TEST0001    drivingLicenseImg=["http://f.souche.com/2acfb5319b7f70b0b48f02058915fb3d.jpg"]    registrationCertificateImg=["http://f.souche.com/ee313291ac52a7bd19196bd82f7eb377.jpg"]    purchaseInvoiceImg=["http://f.souche.com/33b7bfb39029283d9a61786eaa289fde.jpg"]
    ...    purchaseTaxInvoiceImg=["http://f.souche.com/03b0075eddb1ecf107d9fe9c83870fb8.jpg"]    purchaseTaxInvoiceAmount=0.00    licensingFeeInvoiceImg=["http://f.souche.com/65f0f9af4b48636d272d30a0ce1649e2.jpg"]    licensingFeeInvoiceAmount=0.00
    ${json}=    rest.post.inc    /bd/v3/cardeliveryapplyapi/applyDelivery.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/bd/v3/cardeliveryapplyapi/applyDelivery.json    carDealId=34070&plateNo=TEST001&drivingLicenseImg=%5B%22http%3A%2F%2Ff.souche.com%2F2acfb5319b7f70b0b48f02058915fb3d.jpg%22%5D&registrationCertificateImg=%5B%22http%3A%2F%2Ff.souche.com%2Fee313291ac52a7bd19196bd82f7eb377.jpg%22%5D&purchaseInvoiceImg=%5B%22http%3A%2F%2Ff.souche.com%2F33b7bfb39029283d9a61786eaa289fde.jpg%22%5D&purchaseTaxInvoiceImg=%5B%22http%3A%2F%2Ff.souche.com%2F03b0075eddb1ecf107d9fe9c83870fb8.jpg%22%5D&purchaseTaxInvoiceAmount=0.00&licensingFeeInvoiceImg=%5B%22http%3A%2F%2Ff.souche.com%2F65f0f9af4b48636d272d30a0ce1649e2.jpg%22%5D&licensingFeeInvoiceAmount=0.00&remarks=sss%0A

审核车辆信息
    登录souche-inc    18808080808    souche2015
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}    carDealId=${save["carDealId"]}    type=2    status=30
    ${json}=    rest.get.inc    /admin/carapi/audit.json    ${data}    json    ${hosts["finance-car-manage"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}
    #http://finance-car-manage.sqaproxy.souche-inc.com/admin/carapi/audit.json?carDealId=167786&type=2&status=30&

车商确认交车
    登录风车    15094448010    cml448010
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    ${data}=    create dictionary    orderId=${save["orderId"]}
    ${json}=    rest.post    /dealer/v1/saleorderapi/confirmPickup.json    ${data}    json    ${hosts["site5"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

获取taskid
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}
    ${json}    rest.post    /consumer/v1/consumerorderapi/getConciseOrderInfo.json    ${data}    form_Auth    ${hosts["site5"]}
    Should Be True    ${json["success"]}
    set to dictionary    ${save}    taskId=${json["data"]["taskId"]}
    set to dictionary    ${save}    orderCode=${json["data"]["orderCode"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

获取验证码
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}
    ${json}    rest.get    /consumer/v1/agreementapi/sendCaptcha.json    ${data}    form_Auth    ${hosts["site5"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

确认提车
    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    登录弹个车    ${save["alipayUserId"]}
    ${data}    create dictionary    orderId=${save["orderId"]}    taskId=${save["taskId"]}    captcha=${captcha}
    ${json}    rest.post    /consumer/v1/agreementapi/confirmPickUp.json    ${data}    form_Auth    ${hosts["site5"]}
    Should Be True    ${json["success"]}
    save_to_file    弹个车订单/二手车弹个车订单/save.txt    ${save}
    logmany    ${save}

取消订单（非700订单）
    set test variable    ${order_id}    407959
    #${order_id}    create dictionary    order_id=387971
    DB.Script    finance_car_lease_v3    ${close_order}
    #订单发起退车
    #    ${save}=    get_from_file    弹个车订单/二手车弹个车订单/save.txt
    #    登录souche-inc    13575730431    123456
    #    ${data}    create dictionary    orderId=${save["orderId"]}    refundBankNo=测试    refundBankName=测试    refundReasonEnumName=OUT_OF_STORE
    #    ${json}    rest.get    /admin/orderapi/applyRefund    ${data}    form    http://leaseadmin1.sqaproxy.souche-inc.com
    #    should be true    ${json["success"]}
    #    ${response}    to json    ${json}
    #通过接口取消订单
    #    ${data}    create dictionary    orderId=387971    tokenValue=orderCancel    closeReason=EXPIRED
    #    ${json}    rest.get    /alipay/v1/orderapplytestapi/cancelOrderForTest.Json    ${data}    form    ${hosts["site9"]}
    #    should be true    ${json['success']}
    #    logmany
