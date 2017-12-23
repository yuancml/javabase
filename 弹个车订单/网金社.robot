*** Setting ***
Library           RequestsLibrary
Library           Collections
Resource          common.robot
Library           MyLibrary.py

*** Test Cases ***
产品发布服务
    ${data}=    create dictionary
    ...     loanNumber=DSC20170830014      #产品融资编号
    ...     productName=弹个车资产权益转让产品170830014号       #产品名称
    ...     amount=100000     #融资申请金额
    ...     shelve=20170901     #上架日期
    ...     unshelve=20170901       #下架日期
    ...     startedAt=20170902      #起息日
    ...     endedAt=20180927        #到期日
    ...     period=390       #期限
    ...     repaymentAvailableDate=20180828     #最早可提前还款日
    ...     yearRate=0.066      #发行利率
    ${params}   create dictionary  caller=funds-adm
    ${json}=    rest.post    /financial/funds/common/v1/assets/product    ${data}   ${params}    form    http://api.inc.sqaproxy.souche.com


产品信息查询接口
    ${params}=  create dictionary   caller=funds-adm
    ${json}     rest.get  /financial/funds/common/v1/assets/product/DSC20170830001     ${params}    form    http://api.inc.sqaproxy.souche.com


资产推送接口
    ${params}=  create dictionary   caller=funds-adm

    ${order}=    create dictionary
    ...     number=20170728300000453713512     #订单编号(网商20编号)
    ...     source=TMALL        #订单来源

    ${alipay}=   create dictionary
    ...     account=18888970448     #支付宝账号
    ...     userId=2088702670120924     #支付宝用户ID

    ${identityCardFrontPic}=    create dictionary
    ...     name=身份证正面照片       #身份证正面照片名称
    ...     url=http://img.souche.com/20170829/jpg/2f80a9a50bd8f3b7fe18a133733bb337.jpg       #身份证正面照片地址

    ${identityCardBackPic}=     create dictionary
    ...     name=身份证反面照片       #身份证反面照片名称
    ...     url=http://img.souche.com/20170829/jpg/2f80a9a50bd8f3b7fe18a133733bb337.jpg       #身份证反面照片地址

    ${drivingLicencePic}=   create dictionary
    ...     name=驾驶证照片       #驾驶证照片名称
    ...     url=http://img.souche.com/20170829/jpg/2f80a9a50bd8f3b7fe18a133733bb337.jpg        #驾驶证照片地址

    ${borrower}=     create dictionary
    ...     name=雷冬      #购车人姓名
    ...     identityType=1      #证件类型
    ...     identityNumber=232101198612114213        #证件号码
    ...     mobile=18904595158        #电话号码
    #...     alipay=${alipay}        #支付宝账号
    #...     identityCardFrontPic=${identityCardFrontPic}
    #...     identityCardBackPic=${identityCardBackPic}
    #...     drivingLicencePic=${drivingLicencePic}


    ${picture1}=  create dictionary
    ...     name=商业险保单        #商业险保单图片名称
    ...     url=http://img.souche.com/20170829/jpg/2f80a9a50bd8f3b7fe18a133733bb337.jpg     #商业险保单图片地址
    ${picture}=     create list    ${picture1}
    ${business}=    create dictionary
    ...     company=中国人民财产保险有限公司       #商业保险公司名称
    ...     policyId=PDAA201733010000477586      #商业险保单号
    ...     insurantCode=91230100MA18YYD071      #商业被保险人社会统一信用代码
    ...     insurantName=浙江大搜车融资租赁有限公司哈尔滨分公司         #商业险被保险人名称
    ...     fee=3691       #商业险保费
    ...     picture=${picture}

    ${c.picture1}  create dictionary
    ...     name=交强险险保单        #交强险险保单图片名称
    ...     url=http://img.souche.com/20170829/jpg/04278c222e171d8ecb79ae17a1bc21dd.jpg     #交强险险保单图片地址
    ${c.picture}    create list  ${c.picture1}

    ${compulsoriness}   create dictionary
    ...     company=中国人民财产保险有限公司       #交强险保险公司名称
    ...     policyId=PDZA201733010000559644      #交强险险保单号
    ...     insurantCode=91230100MA18YYD071      #交强险被保险人社会统一信用代码
    ...     insurantName=浙江大搜车融资租赁有限公司哈尔滨分公司      #交强险险被保险人名称
    ...     fee=1000       #交强险保费
    ...     picture=${c.picture}

    ${sourceGPS}    create dictionary
    ...     provider=博实结      #有源GPS供应商
    ...     code=0863014530654032      #有源GPS代码

    ${nonSourceGPS}     create dictionary
    ...     provider=博实结      #无源GPS供应商
    ...     code=14142268213      #无源GPS代码

    ${registerLicense1}      create dictionary
    ...     name=车辆登记证      #车辆登记证名称
    ...     url=http://f.souche.com/03a41c13410a5a30e925cc99743c9c97.png       #车辆登记证地址
    ${registerLicense}      create list  ${registerLicense1}
    ${drivingPermitLicense1}     create dictionary
    ...     name=车辆行驶证     #车辆行驶证名称
    ...     url=http://f.souche.com/e77f5227e65ff91896af72ceaef8ac06.png      #车辆行驶证地址
    ${drivingPermitLicense}     create list     ${drivingPermitLicense1}
    ${downPayment}  create dictionary
    ...     ratio=10     #首付比例
    ...     amount=10700        #首付金额
    ...     type=ALIPAY	    #首付支付方式
    ...     rate=0.15       #利率
    ...     period=12        #租期
    ...     adMonthlyRepaymentAmount=1698      #名义月供
    ...     realMonthlyRepaymentAmount=1698        #月供
    ...     startedAt=20170827     #租约起始日期
    ...     endedAt=20180827	    #租约结束日期
    ...     balanceRatio=0.7143       #尾款比例
    ...     balance=77000       #尾款金额
    ...     number=20170728300000453875510     #首付支付流水号---非必填！

    ${rebate}   create dictionary
    ...     amount=0        #优惠金额
    #...     payId=20170728300000453875510         #支付流水号---非必填！

    ${repayment1}    create dictionary
    ...     period=1       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment2}    create dictionary
    ...     period=2       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment3}    create dictionary
    ...     period=3       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment4}    create dictionary
    ...     period=4       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment5}    create dictionary
    ...     period=5       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment6}    create dictionary
    ...     period=6       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment7}    create dictionary
    ...     period=7       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment8}    create dictionary
    ...     period=8       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment9}    create dictionary
    ...     period=9       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment10}    create dictionary
    ...     period=10       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment11}    create dictionary
    ...     period=11       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment12}    create dictionary
    ...     period=12       #期数
    ...     date=20170827     #应还款日
    ...     adMonthlyRepaymentAmount=1698         #名义月供
    ...     amount=1698       #应还款金额
    ...     status=REPAID       #状态
    ...     realAmount=0     #实际还款金额
    ...     realDate=0     #实际还款日期
    ...     penaltyInterest=0          #罚息
    ...     rebate= ${rebate}           #优惠
    ${repayment}    create list  ${repayment1}  ${repayment2}   ${repayment3}       ${repayment4}   ${repayment5}   ${repayment6}   ${repayment7}   ${repayment8}   ${repayment9}   ${repayment10}   ${repayment11}   ${repayment12}
    ${solution}     create dictionary
    ...     guidePrice=107800        #厂商指导价
    ...     totalCost=112812     #总成本
    ...     downPayment=${downPayment}       #首付相关

    ${insurance}=    create dictionary
    ...     fee=4691       #保险费用
    ...     business=${business}      #商业保险
    ...     compulsoriness=${compulsoriness}        #机动车第三者责任强制保险
    ${contracts1}=   create dictionary
    ...     name=融资租赁协议.pdf       #文件名称
    ...     url=test/2017-07-17/69283530008791040.pdf        #OSS地址
    ${contracts}    create list  ${contracts1}

    ${confirmation1}=    create dictionary
    ...     name=提车确认单.pdf       #提车确认单文件
    ...     url=test/2017-07-17/69283530008791040.pdf        #提车确认单文件
    ${confirmation}=    create list  ${confirmation1}

    ${file}=    create dictionary
    ...     contracts=${contracts}      #融资租赁协议
    ...     confirmation=${confirmation}        #提车确认单文件
    ${car}=      create dictionary
    ...     city=广东 汕头 龙湖区        #城市
    ...     typeCode=14134-n        #针对车型的编码
    ...     brand=福特       #车辆品牌
    ...     series=福睿斯      #车系
    ...     model=2017款 福睿斯 1.5L 自动舒适型       #车型
    ...     vin=LVSHFFAL3HS328495     #车架号,汽车vin码
    ...     plateNumber=黑AS90W3     #车牌号
    ...     guidePrice=107800      #厂商指导价
    ...     totalCost=112812       #总成本
    ...     tax=11111       #车船税
    ...     insurance=${insurance}       #保险信息
    ...     sourceGPS=${sourceGPS}
    ...     nonSourceGPS=${nonSourceGPS}
    ...     registerLicense=${registerLicense}      #车辆登记证
    ...     drivingPermitLicense=${drivingPermitLicense}       #车辆行驶证

    ${data}     create dictionary
    ...     loanNumber=DSC20170830102      #产品融资编号
    ...     contractNumber=TM6959601946362880      #产品融资编号
    ...     order=${order}           #订单信息
    ...     pickDate=20170826        #提车日期
    ...     borrower=${borrower}        #客户信息
    ...     car=${car}     #车辆信息
    ...     solution=${solution}        #金融方案信息
    ...     repayment=${repayment}     #还款计划
    ...     file=${file}        #附件
    ...     callback=http://spay.funds-adm.sqaproxy.souche-inc.com/openplatform/wjs/attachcallback       #接受回调地址


    ${json}=    rest.post  /financial/funds/common/v1/assets       ${data}   ${params}    json    http://api.inc.sqaproxy.souche.com

产品还款信息同步服务
    ${data}=    create dictionary   orderNumber=20170728300000453875510    #订单编号
    ...     period=3   #期数
    ...     realRepaymentAmount=1698  #实际还款金额
    ...     realRepaymentDate=20171027   #实际还款日期
    ...     penaltyInterest=0   #罚息
    ...     rebate=0    #优惠金额
    ...     payId=20170728300000453875510      #支付流水号
    ${params}   create dictionary   caller=funds-adm
    ${json}=    rest.post   /financial/funds/common/v1/assets/repay     ${data}     ${params}   form    http://api.inc.sqaproxy.souche.com

资产唯一性校验
    ${assetsCode}   set variable        20170721300000449699510
    ${data}     create dictionary        assetsCode=20170721300000449699510
    ${x-izayoi-sign}     ${data}    sign    ${data}
    ${json}     test.get  /v1/financial/assets/${assetsCode}/loaner   params=${data}     x-izayoi-sign=${x-izayoi-sign}        cur_host=https://api.souche.com