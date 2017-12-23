# -*- coding: utf-8 -*-

# 测试数据
data_send_car = [
    # TB_ORDER 表写两条测试数据，批次号由外部变量${batch_id}指定
    "INSERT INTO `TB_ORDER` VALUES (NULL, '798194', '28903', '10311', '00', '641491765', '20160613034521946641229', '2016-06-13 00:00:00', '1', '5000.00', '5.00', '201606130110000641491765', '${batch_id}', '2017-03-01 12:46:43');",
    "INSERT INTO `TB_ORDER` VALUES (NULL, '798194', '28903', '10311', '00', '641508882', '20160613064115852854672', '2016-06-13 00:00:00', '1', '10000.00', '10.00', '201606130110000641508882', '${batch_id}', '2017-03-01 12:46:43');",
    # TB_ORDER_SUMMARY 表写一条测试数据
    "INSERT INTO `TB_ORDER_SUMMARY` VALUES (NULL, '798194', '28903', '10311', '00', '36', '608800.00', '624.10', '2017-03-03 17:24:41', 'F', '${batch_id}', '2017-03-01 12:46:43');"
]

get_a_car = "SELECT * FROM TB_ORDER WHERE ID='${car_id}'"

get_cars = "SELECT * FROM TB_ORDER WHERE ID >='${car_id}'"

get_order = "SELECT * FROM fcl_order WHERE order_id ='${order_id}'"

get_order_id="Select * from fcl_order where status_code<800 and order_id in (SELECT order_id from `fcl_order_user` where alipay_user_id='${alipayUserId}')"

get_vin = "SELECT * FROM fcl_order_car WHERE order_id ='${order_id}'"

get_car_deal_id = "SELECT * FROM fcm_car_deal WHERE sale_order_no ='${order_no}'"

close_order = [
    "update fcl_order set status_code=1000 WHERE order_id ='${order_id}'"]

delete_repay = [
    "delete repay.* from orders,withholdings,repay where orders.id = withholdings.order_id and withholdings.id = repay.withholding_id and orders.trade_code in ('${order_code}')",
    "delete timer_tasks.* from orders,withholdings,repay,timer_tasks where 1=1 and orders.id = withholdings.order_id and withholdings.id = repay.withholding_id and repay.id = timer_tasks.repay_id and orders.trade_code in ('${order_code}')"
]

clear_send_car = [
    "DELETE FROM `TB_ORDER` WHERE `BATCH_ID`='${batch_id}'",
    "DELETE FROM `TB_ORDER_SUMMARY` WHERE `BATCH_ID`='${batch_id}'"
]

delete_settle = [
    "delete from settlement_record where order_code='${order_Code}'",
    "delete from settlement_record_detail where order_code='${order_Code}'"]

select_settle_record ="select * from settlement_record where order_code='${order_code}'"

select_settle_record_detail ="select * from settlement_record_detail where order_code='${order_code}'"

select_sec_relate="SELECT * FROM `sec_financial_product_shop_relate` where shop_code='${shopCode}' and is_self='1' and sys_type='SEC_LEASE' and deleted=0 order by date_create desc limit 0,1"
      #查询'sec_financial_product_shop_relate'


