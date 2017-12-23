*** Settings ***
Resource          ../common.robot

*** Test Cases ***
${salespersonId}    51gpgiV7Rc    #销售id，004762：51gpgiV7Rc
${shopCode}     004762    #店铺，默认为004762，账号：17700000008 密码：souche2015
${productId}    1000      #2016款 奔腾B50 1.6L 自动舒适型
${carId}    T2MJXFRtDO    #车辆id，T2MJXFRtDO

*** Test Cases ***
下单二维码
登录lease    ${token}
${data}     CREATE DICTIONARY     salespersonId=${salespersonId}

