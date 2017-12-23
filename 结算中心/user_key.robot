*** Keywords ***
拉取订单
    [Arguments]    ${key}    ${order_code}    # key+订单中心编号
    ${data}    create dictionary    key=${key}    orderCode=${order_code}
    ${json}    Rest.get    /mockJobAction/syncOrder.json    ${data}    form    ${host['debug1']}
    SHOULD BE EQUAL    ${json["msg"]}    success

生成新车融租方扣款结算单
    [Arguments]    ${key}    # 多个参数，需要添加

返佣打款
    [Arguments]    ${detail_id}

删除二手车采购款
    [Arguments]    ${order_code}        # 操作mysql数据库，执行2条语句，删除settlement_record 和 settlement_record_detail，总共2条数据
    DB.Script       ${database['clearing_center']}      ${delete_settle}
    [Teardown]
