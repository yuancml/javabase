*** Setting ***
Library           RequestsLibrary
Library           Collections
Resource          common.robot
Library           MyLibrary.py
Library           HttpLibrary
Library           string
Library           requests
Library           json
Resource          ../common.robot

*** Test Cases ***
000.获取车系列表-list.json
    ${data}=    create dictionary
    ${addr}    rest.get    /api/carSeries/list.json    ${data}    form    http://2703.wd.chebaba.com/
    ${items}=    set variable    ${addr["data"]["items"]}
    ${List}=    Get From List    ${items}    0    #items[0]
    ${seriesList}=    set variable    ${List["seriesList"]}
    #${seriesCode}=    set variable    ${seriesList["seriesCode"]}
    #log    ${seriesCode}
    : FOR    ${Code}    IN    @{seriesList}
    \    ${seriesCode}=    set variable    ${Code["seriesCode"]}
    \    ${thirdSeriesCode}=    get from dictionary    ${Code}    thirdSeriesCode
    \    log    ${seriesCode}
    \    log    ${thirdSeriesCode}
    \    ${url}=    evaluate    "/api/carSeries/" + "${seriesCode}" + "/models.json"
    \    ${params}=    create dictionary    thirdSeriesCode=${thirdSeriesCode}
    \    ${resp}=    rest.get    ${url}    ${params}    form    http://2703.wd.chebaba.com/
    \    #\    ${jsons}=    set variable    ${resp.json()}
    \    Should Be True    ${resp["success"]}

登录sso
    [Tags]    sso
    ${dataparams}    CREATE DICTIONARY    userName=18808080808    password=souche2015    userDomain=
    ${data}    CREATE DICTIONARY    callback=jQuery1910695851862096488_1502979850500    dataparams=userName=18808080808&password=souche2015&userDomain=    requestClassName=com.souche.sso.service.LoginService    requestMethod=getSSOToken    _=1502979850511
    ${json}=    Rest.get    /dubboJson/get.jsonp    ${data}
    ${sso}=    Set Variable    ${json['data']}
    ${token}=    Tup    ${sso}
    delete all sessions

登录souche-inc
    [Tags]  souche-inc
    登录souche-inc   18808080808     souche2015

登录弹个车
    登录弹个车   2088702670120924


登录工作台
    登录工作台   15858202767     123456
    log  ${_security_token_inc}


test
    ${a}    create dictionary   a=11    b=22
    set to dictionary    ${a}     c=33
    log many  ${a}

test1
    ${save}=   get_from_file   弹个车订单/二手车弹个车订单/save.txt
    save_to_file    弹个车订单/二手车弹个车订单/save.txt     ${save}