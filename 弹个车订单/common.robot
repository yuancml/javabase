*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           MyLibrary.py
Library           DatabaseLibrary

*** Variables ***
&{hosts}          dfc_dev=http://dfc.sqaproxy.souche.com    dfc_da=http://dfc.dasouche.net    site5=http://leasesite5.sqaproxy.souche.com       site1=http://leasesite1.sqaproxy.souche.com     site2=http://leasesite2.sqaproxy.souche.com    site3=http://leasesite3.sqaproxy.souche.com    site4=http://leasesite4.sqaproxy.souche.com    site5=http://leasesite5.sqaproxy.souche.com      finance-car-manage=http://finance-car-manage.sqaproxy.souche.com    site9=http://leasesite1.sqaproxy.dasouche.net
${token}          ${EMPTY}
&{proxy}
&{databases}      finance_car_lease_v3=database='finance_car_lease_v3', user='appdb_rw', password='zV4cLS8ma7hE1A5e', host='112.124.112.81', port=3306, charset='utf8'    clearing_center=database='souche_clearing_center', user='root', password='dpjA8Z6XPXbvos', host='115.29.10.121', port=3306 , charset='utf8'       # 链接成功的数据库schema
...               dealership=database='souche-dealership', user='root', password='dpjA8Z6XPXbvos', host='115.29.10.121', port=3306 , charset='utf8'       # 链接成功的数据库schema

*** Keywords ***
登录风车
    [Arguments]    ${loginName}    ${password}
    #共用登录接口
    log    "######登录大风车######"
    ${headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${host}=    Create Session    _session    http://dfc.dasouche.net    ${headers}
    ${data}=    Create Dictionary    loginName=${loginName}    password=${password}
    ${response}=    post request    _session    /rest/account/login    data=${data}
    ${json}=    Set Variable    ${response.json()}
    Should Be True    ${json["success"]}
    Set Global Variable    ${token}    ${json["data"]["token"]}

登录车牛
    [Arguments]    ${user_id}    ${password}
    #共用登录接口
    log    “######登录车牛######”
    ${headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${host}=    Create Session    _session    http://niu.souche.com    ${headers}
    ${data}=    Create Dictionary    user_id=${user_id}    password=${password}
    ${response}=    post request    _session    /user/login    data=${data}
    ${json}=    Set Variable    ${response.json()}
    Set Global Variable    ${phone}    ${json["data"]["phone"]}
    Should Be Equal    ${phone}    ${user_id}
    Set Global Variable    ${token}    ${json["data"]["token"]}

登录sso
    [Arguments]    ${userName}    ${password}
    ${dataparams}    CREATE DICTIONARY    userName=${userName}    password=${password}    userDomain=
    ${data}    CREATE DICTIONARY    callback=jQuery1910695851862096488_1502979850500    dataparams=userName=18808080808&password=souche2015&userDomain=    requestClassName=com.souche.sso.service.LoginService    requestMethod=getSSOToken    _=1502979850511
    ${json}=    Rest.get    /dubboJson/get.jsonp    ${data}    form    http://test-ssmt.sqaproxy.souche-inc.com
    ${sso}=    Set Variable    ${json['data']}
    ${token}=    Tup    ${sso}
    Set Global Variable    ${token}

登录souche-inc
    [Arguments]    ${userName}    ${password}
    ${url}=    set variable    http://devsso.sqaproxy.souche-inc.com/loginAction/login.do
    ${logindata}=    create dictionary    username=${userName}    password=${password}    fingerPrint=2793536939
    ${souche-inc-token}=    get_souche-inc_token    ${url}    ${logindata}
    Set Global Variable    ${souche-inc-token}

登录弹个车
    [Arguments]    ${alipayId}
    #${dataparams}    CREATE DICTIONARY    alipayId=${alipayId}
    ${data}    CREATE DICTIONARY    callback=jQuery1910695851862096488_1502979850500    dataparams=alipayId=${alipayId}    requestClassName=com.souche.sso.service.LoginService    requestMethod=useBuyerAlipayId    _=1502979850527
    ${json}=    Rest.get    /dubboJson/get.jsonp    ${data}    form    http://test-ssmt.sqaproxy.souche-inc.com
    ${sso}=    Set Variable    ${json['data']}
    ${token}=    Tup    ${sso}
    Set Global Variable    ${token}

登录工作台
    [Arguments]    ${userAccount}    ${password}
    ${data}    CREATE DICTIONARY    userAccount=${userAccount}    password=${password}
    ${json}    Rest.get    accountApi/login.json    ${data}    form    http://devsso.sqaproxy.souche-inc.com
    ${souche-inc-token}    Set Variable    ${json['data']}
    Set Global Variable    ${souche-inc-token}

Rest.post
    [Arguments]    ${url}    ${data}    ${type}    ${cur_host}=${EMPTY}
    [Documentation]    post请求封装
    #设置代理，用于调试
    #${proxy}    Set Variable    http://127.0.0.0:8888/
    #根据用例的tag，来默认获取host
    ${host}    Set Variable    \\${EMPTY}
    : FOR    ${tag}    IN    @{TEST TAGS}
    \    ${host}=    Evaluate    $hosts.get($tag,"")
    \    Run keyword If    "${host}"!=""    Exit For Loop
    #创建session
    Run keyword If    "${cur_host}"!=""    Create Session    _session    ${cur_host}
    ...    ELSE    Create Session    _session    ${host}
    #已登录的用户补充token
    Run keyword If    "${token}"!=""    Set To Dictionary    ${data}    _security_token=${token}
    #根据请求类型设置headers
    ${headers}=    Run keyword If    "${type}" == "form"    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ...    ELSE IF    "${type}" == "form_Auth"    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Authorization=Token token=${token}
    ...    ELSE IF    "${type}" == "json"    Create Dictionary    Content-Type=application/json
    ${response}=    Post Request    _session    ${url}    ${data}    headers=&{headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Run keyword if    "${url}".find("jsonp") != -1    jsonp    ${response.content}
    ...    ELSE    Set Variable    ${response.json()}
    [Return]    ${json}

Rest.post.inc
    [Arguments]    ${url}    ${data}    ${type}    ${cur_host}=${EMPTY}
    [Documentation]    post请求封装
    #设置代理，用于调试
    #${proxy}    Set Variable    http://127.0.0.0:8888/
    #根据用例的tag，来默认获取host
    ${host}    Set Variable    \\${EMPTY}
    : FOR    ${tag}    IN    @{TEST TAGS}
    \    ${host}=    Evaluate    $hosts.get($tag,"")
    \    Run keyword If    "${host}"!=""    Exit For Loop
    #创建session
    Run keyword If    "${cur_host}"!=""    Create Session    _session    ${cur_host}
    ...    ELSE    Create Session    _session    ${host}
    #已登录的用户补充token
    ${params}    create dictionary
    Run keyword If    "${souche-inc-token}"!=""    Set To Dictionary    ${params}    _security_token_inc=${souche-inc-token}
    #根据请求类型设置headers
    ${headers}=    Run keyword If    "${type}" == "form"    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ...    ELSE IF    "${type}" == "form_Auth"    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Authorization=Token token=${token}
    ...    ELSE IF    "${type}" == "json"    Create Dictionary    Content-Type=application/json
    ${response}=    Post Request    _session    ${url}    data=${data}    params=${params}    headers=&{headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Run keyword if    "${url}".find("jsonp") != -1    jsonp    ${response.content}
    ...    ELSE    Set Variable    ${response.json()}
    [Return]    ${json}

Rest.get
    [Arguments]    ${url}    ${params}    ${type}    ${cur_host}=${EMPTY}
    [Documentation]    get请求封装
    #设置代理，用于调试
    #${proxy}    Set Variable    http://127.0.0.0:8888/
    #根据用例的tag，来默认获取host
    ${host}    Set Variable    \\${EMPTY}
    : FOR    ${tag}    IN    @{TEST TAGS}
    \    ${host}=    Evaluate    $hosts.get($tag,"")
    \    Run keyword If    "${host}"!=""    Exit For Loop
    #创建session
    Run keyword If    "${cur_host}"!=""    Create Session    _session    ${cur_host}
    ...    ELSE    Create Session    _session    ${host}
    #已登录的用户补充token
    Run keyword If    "${token}"!=""    Set To Dictionary    ${params}    _security_token=${token}
    #根据请求类型设置headers
    ${headers}=    Run keyword If    "${type}"=="form"    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ...    ELSE IF    "${type}"=="form_Auth"    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Authorization=Token token=${token}
    ...    ELSE IF    "${type}"=="json"    Create Dictionary    Content-Type=application/json
    ${response}=    Get Request    _session    ${url}    params=${params}    headers=&{headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Run keyword if    "${url}".find("jsonp") != -1    jsonp    ${response.content}
    ...    ELSE    Set Variable    ${response.json()}
    [Return]    ${json}

Rest.get.inc
    [Arguments]    ${url}    ${params}    ${type}    ${cur_host}=${EMPTY}
    [Documentation]    get请求封装
    #设置代理，用于调试
    #${proxy}    Set Variable    http://127.0.0.0:8888/
    #根据用例的tag，来默认获取host
    ${host}    Set Variable    \\${EMPTY}
    : FOR    ${tag}    IN    @{TEST TAGS}
    \    ${host}=    Evaluate    $hosts.get($tag,"")
    \    Run keyword If    "${host}"!=""    Exit For Loop
    #创建session
    Run keyword If    "${cur_host}"!=""    Create Session    _session    ${cur_host}
    ...    ELSE    Create Session    _session    ${host}
    #已登录的用户补充token
    Run keyword If    "${souche-inc-token}"!=""    Set To Dictionary    ${params}    _security_token_inc=${souche-inc-token}
    #根据请求类型设置headers
    ${headers}=    Run keyword If    "${type}"=="form"    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ...    ELSE IF    "${type}"=="form_Auth"    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Authorization=Token token=${token}
    ...    ELSE IF    "${type}"=="json"    Create Dictionary    Content-Type=application/json
    ${response}=    Get Request    _session    ${url}    headers=${headers}    params=${params}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Run keyword if    "${url}".find("jsonp") != -1    jsonp    ${response.content}
    ...    ELSE    Set Variable    ${response.json()}
    [Return]    ${json}

Test.get
    [Arguments]    ${url}    ${params}=&{EMPTY}    ${x-izayoi-sign}=${EMPTY}    ${files}=${None}    ${cookies}=&{EMPTY}    ${cur_host}=${EMPTY}
    #设置代理，便于调试
    #${proxy}=    Set Variable    http://127.0.0.1:8888/
    Create Session    _session    ${cur_host}    cookies=${cookies}    #proxies=${proxy}
    #根据请求类型设置headers
    &{headers}=    Run Keyword If    "${x-izayoi-sign}"!=""    Create Dictionary    Content-Type=application/x-www-form-urlencoded    x-izayoi-sign=${x-izayoi-sign}
    ...    ELSE    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${response}=    Get Request    _session    ${url}    params=${params}    headers=&{headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    [Return]    ${json}

Rest.patch
    [Arguments]    ${url}    ${params}    ${type}    ${cur_host}=${EMPTY}
    [Documentation]    get请求封装
    #设置代理，用于调试
    #${proxy}    Set Variable    http://127.0.0.0:8888/
    #根据用例的tag，来默认获取host
    ${host}    Set Variable    \\${EMPTY}
    : FOR    ${tag}    IN    @{TEST TAGS}
    \    ${host}=    Evaluate    $hosts.get($tag,"")
    \    Run keyword If    "${host}"!=""    Exit For Loop
    #创建session
    Run keyword If    "${cur_host}"!=""    Create Session    _session    ${cur_host}    proxies=${proxy}
    ...    ELSE    Create Session    _session    ${host}    #proxies=${proxy}
    #根据请求类型设置headers
    ${headers}=    Run keyword If    "${type}"=="json"    Create Dictionary    Content-Type=application/json
    ...    ELSE IF    "${type}"=="form_Auth"    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Authorization=Token token=${token}
    ...    ELSE IF    "${type}"=="form"    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${response}=    RequestsLibrary.Patch    _session    ${url}    headers=${headers}    data=${params}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Run keyword if    "${url}".find("jsonp") != -1    jsonp    ${response.content}
    ...    ELSE    Set Variable    ${response.json()}
    [Return]    ${json}

Rest.delete
    [Arguments]    ${url}    ${params}    ${type}    ${cur_host}=${EMPTY}
    [Documentation]    delete请求封装
    #设置代理，用于调试
    #${proxy}    Set Variable    http://127.0.0.0:8888/
    #根据用例的tag，来默认获取host
    ${host}    Set Variable    \\${EMPTY}
    : FOR    ${tag}    IN    @{TEST TAGS}
    \    ${host}=    Evaluate    $hosts.get($tag,"")
    \    Run keyword If    "${host}"!=""    Exit For Loop
    #创建session
    Run keyword If    "${cur_host}"!=""    Create Session    _session    ${cur_host}    proxies=${proxy}
    ...    ELSE    Create Session    _session    ${host}    #proxies=${proxy}
    #已登录的用户补充token
    Run keyword If    "${token}"!=""    Set To Dictionary    ${params}    _security_token=${token}
    #根据请求类型设置headers
    ${headers}=    Run keyword If    "${type}"=="form"    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ...    ELSE    "${type}"=="form-Auth"    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Authorization=Token token=${tangeche_token}
    ...    ELSE    "${type}"=="json"    Create Dictionary    Content-Type=application/json
    ${response}=    Delete Request    _session    ${url}    headers=&{headers}    params=${params}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    [Return]    ${json}

DB.Script
    [Arguments]    ${database}    ${scripts}    # 数据库名 | 存放脚本的list类型的变量
    [Documentation]    在指定数据库上执行一组脚本
    ...    脚本存放在一个list类型的变量里，可以通过变量文件来管理
    ...    主要用于执行一组sql语句，不处理返回值
    Connect To Database Using Custom Params    pymysql    ${databases["${database}"]}
    : FOR    ${sql}    IN    @{scripts}
    \    ${sql}=    Replace Variables    ${sql}
    \    Log    执行SQL语句: ${sql}
    \    Execute Sql String    ${sql}
    Disconnect From Database

DB.Query
    [Arguments]    ${database}    ${sql}    # 数据库名 | 需要执行的sql语句
    [Documentation]    在指定数据库上执行一句查询SQL操作
    ...    SQL中可包含变量
    ...    返回值为List形式，List中每一项是一个Dictionary
    #coding=utf-8;
    @{resultset}=    Create List
    Connect To Database Using Custom Params    pymysql    ${databases["${database}"]}
    ${sql}=    Replace Variables    ${sql}
    #获得结果集的列名
    @{description}=    Description    ${sql}
    #执行SQL
    @{results}=    Query    ${sql}
    : FOR    ${result}    IN    @{results}
    \    ${rowset}=    Convert To List    ${result}
    \    &{row}=    $._row    ${description}    ${rowset}
    \    Append To List    ${resultset}    ${row}
    Disconnect From Database
    [Return]    ${resultset}    # 结果集

DB.QueryOne
    [Arguments]    ${database}    ${sql}    # 数据库名 | 需要执行的sql语句
    [Documentation]    在指定数据库上执行一句查询SQL操作
    ...    SQL中可包含变量
    ...    返回值为一个Dictionary
    Connect To Database Using Custom Params    pymysql    ${databases["${database}"]}
    ${sql}=    Replace Variables    ${sql}
    #获得结果集的列名
    @{description}=    Description    ${sql}
    #执行SQL,只能请求单行数据，结算中心需要修改
    @{results}=    Query    ${sql}
    Length Should Be    ${results}    ${1}
    ${result}=    Get From List    ${results}    ${0}
    ${rowset}=    Convert To List    ${result}    #返回一个list
    &{resultset}=    $._row    ${description}    ${rowset}
    Disconnect From Database
    [Return]    ${resultset}    # 结果集

$._row
    [Arguments]    ${desc}    ${rowset}
    [Documentation]    构造一个Dictionary方式的数据行。
    ...    该关键字在Query内部使用，不应直接调用
    &{row}=    Create Dictionary
    ${index}=    Set Variable    ${0}
    : FOR    ${column}    IN    @{desc}
    \    Set To Dictionary    ${row}    ${column[0]}=${rowset[${index}]}
    \    ${index}=    Set Variable    ${index+1}
    [Return]    ${row}

Index.Update
    [Arguments]    ${target}    ${type}    ${id}    # 操作目标(car或shop或order) | 操作类型(add或update或delete) | 数据id
    [Documentation]    为车辆、店铺或订单创建、更新或者删除一条外部索引
    ${uri}=    Set Variable    /${target}/index/update
    ${data}=    Create Dictionary    ${target}id=${id}    operateType=${type}
    Rest.Post    ${uri}    ${data}    form    ${hosts["searcher"]}

取消弹个车订单
    [Arguments]    ${alipayUserId}    # 拿到客户信息
    ${rowset}    DB.QueryOne    finance_car_lease_v3    ${get_order_id}
    log   ${rowset["order_id"]}
    set test variable    ${order_id}    ${rowset["order_id"]}
    DB.Script    finance_car_lease_v3    ${close_order}
#    #预发使用接口调试
#    登录风车    15094448010      cml448010
#    log   ${token}
#    ${data}    create dictionary    orderId=${rowset["order_id"]}    tokenValue=orderCancel    closeReason=EXPIRED
#    ${json}    Rest.post    /alipay/v1/orderapplytestapi/cancelOrderForTest.Json    ${data}    form    ${hosts["site9"]}
#    should be true     ${json["success"]}   #预发调试
#    ${rowset}    DB.QueryOne    finance_car_lease_v3    ${get_order_id}
#    should not contain    ${rowset["order_id"]}
