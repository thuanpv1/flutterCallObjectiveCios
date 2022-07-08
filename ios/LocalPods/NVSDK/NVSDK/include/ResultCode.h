//
//  ResultCode.h
//  iCamSee
//
//  Created by macrovideo on 15/10/19.
//  Copyright © 2015年 macrovideo. All rights reserved.
//

#ifndef ResultCode_h
#define ResultCode_h

//MARK: 操作结果码
#define NV_RESULT_SUCCEED                   1001    //成功
#define NV_RESULT_FAILED                    2001    //失败
#define NV_RESULT_FAILED_EX                 2002    //失败(V20)

//操作返回码
#define RESULT_CODE_SUCCESS_REFRESH             0x104   //刷新，并没有真正请求
#define RESULT_CODE_SUCCESS                     0x100   //成功
#define RESULT_CODE_PROCESSING                  0x102   //处理中，还没有成功，针对录像文件搜索，表示没有搜索完全
#define RESULT_CODE_SERVERCONNECT               0x103   //连接上了服务器，但是没有得到响应数据
#define RESULT_CODE_FAIL_SERVER_CONNECT_FAIL    -0x101  //连接失败 -257
#define RESULT_CODE_FAIL_COMMUNICAT_FAIL        -0x102  //通信失败 -258
#define RESULT_CODE_FAIL_VERIFY_FAIL            -0x103  //验证失败
#define RESULT_CODE_FAIL_USER_NOEXIST           -0x104  //用户不存在
#define RESULT_CODE_FAIL_PWD_ERR                -0x105  //密码错误
#define RESULT_CODE_FAIL_OLD_VERSION            -0x106  //旧版本
#define RESULT_CODE_FAIL_ID_ERR                 -0x107  //ID错误
#define RESULT_CODE_FAIL_PWD_ERR_AP             -0x108  //AP密码错误
#define RESULT_CODE_FAIL_PWD_ERR_STATION        -0x109  //Station密码错误
#define RESULT_CODE_FAIL_PWD_FMT_ERR            -0x1010 //密码格式错误
#define RESULT_CODE_FAIL_USERNAME_NULL          -0x111  //用户名为空
#define RESULT_CODE_FAIL_PARAM_ERROR            -0x112  //传入参数有误
#define RESULT_CODE_FAIL_TIME_FMT_ERROR         -0x113  //时间格式错误
#define RESULT_CODE_FAIL_CMD_NO_SUPORT          -0x114  //前端不支持该指令

//获取报警图片列表返回码
#define RESULT_CODE_SUCCESS_NEWMESSAGE          100     //成功，并且有新的报警信息
#define RESULT_CODE_SUCCESS_NOTNEWMESSAGE       0       //成功，但是没有新的报警信息
#define RESULT_CODE_FAIL_CONNECT_SERVER_FAIL    -100    //失败，连接数据库失败
#define RESULT_CODE_FAIL_USERNAME_NOEXIST       -101    //失败，用户名不存在
#define RESULT_CODE_FAIL_PASSWORD_ERROR         -102    //失败，密码不正确
#define RESULT_CODE_FAIL_PARM_ERROR             -103    //失败，请求参数不正确

//MARK: 云盘相关结果类型
#define PB_RESULT_OK                        1000    //成功
#define PB_RESULT_USER_ERR                  -1001   //用户信息错误
#define PB_RESULT_TOKEN_ERR                 -1002   //Token错误
#define PB_RESULT_FILE_NOT_EXIST            -1004   //文件不存在
#define PB_RESULT_ERR                       -1005   //其他错误
#define PB_RESULT_POS_EXIST                 -1006   //无法定位, 如:文件不存在
#define PB_RESULT_USERID_NOT_MATCH          -1007   //user id不匹配
#define PB_RESULT_TOKEN_EXPIRATION          -1008   //Token过期
#define PB_RESULT_NOT_FOUND_USER_MSG        -1009   //找不到信息
#define PB_RESULT_SYSTEM_ERR                -1010   //系统问题
#define PB_RESULT_INTERFACE_ERR             -1011   //验证结果其他错误

//MARK: 操作结果码
#define OP_RESULT_OK                            1000    //成功
#define OP_RESULT_USER_ERR                      -1001   //用户名错误
#define OP_RESULT_PWD_ERR                       -1002   //密码错误
#define OP_RESULT_NO_PRI                        -1003   //权限不足
#define OP_RESULT_FILE_NOT_EXIST                -1004   //文件不存在

#endif /* ResultCode_h */
