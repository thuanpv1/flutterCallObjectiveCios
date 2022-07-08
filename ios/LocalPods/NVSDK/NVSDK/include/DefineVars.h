#ifndef _DEFINES_
#define _DEFINES_


/* char 指针定义 */
typedef char* PCHAR;

/* bool 类型定义 */
#ifndef bool
#define bool int
#endif

#ifndef true
#define true 0x0001
#endif

#ifndef false
#define false 0x0000
#endif

#define OP_OK                       100         //操作成功
#define OP_CONN_SERVER_FAIL         -101        //连接设备失败

#define CMD_WAIT_FOR_DATA           260     //需要等待CMD(收)

//MARK: 控制定义
#define NV_ENABLE                   1000        //开启
#define NV_DISABLE                  1001        //关闭
#define NV_LANGUAGE_CN              1000        //中文
#define NV_LANGUAGE_EN              1100        //英文

//MARK: 录像状态
#define RECORD_STAT_UNKNOW              0       //录像状态: 未知
#define RECORD_STAT_RUN_OK              10      //录像状态: 运行正常
#define RECORD_STAT_NO_SDCARD           -11     //录像状态: 没有TF卡
#define RECORD_STAT_SDCARD_WRITE_ERR    -12     //录像状态: TF卡写入异常

//MARK: 主动触发报警
#define NV_IPC_ALARM_REQUEST                185    //主动触发报警指令字
#define NV_IPC_ALARM_ACTION_ON              1001   //主动触发报警:开
#define NV_IPC_ALARM_ACTION_OFF             1002   //主动触发报警:关

//MARK: 录像文件类型
#define FILE_TYPE_ALL               0           //所有文件
#define FILE_TYPE_NORMAL            1           //自动录像
#define FILE_TYPE_MOTION            2           //移动侦测录像
#define FILE_TYPE_ALARM             3           //报警录像
#define FILE_TYPE_EPITOME           4           //延时

//MARK: 报警类型
#define ALARM_TYPE_UNDIFINED                0       //普通报警
#define ALARM_TYPE_SMOG                     1       //烟感报警
#define ALARM_TYPE_MOTION                   2       //移动报警报警
#define ALARM_TYPE_PIR                      3       //人体感应报警
#define ALARM_TYPE_ACCESS_CTRL              4       //访问控制报警
#define ALARM_TYPE_GAS                      5       //煤气报警
#define ALARM_TYPE_WARM                     6       //温感报警
#define ALARM_TYPE_PWD_CHANGE               7       //设备密码修改报警
#define ALARM_TYPE_HUMAN                    8       //发现人型报警
#define ALARM_TYPE_DOORBELL                 9       //门铃消息
#define ALARM_TYPE_BATTERY                  10      //低电量报警
#define ALARM_TYPE_TEMPERATURE_HIGH         11      //高温报警
#define ALARM_TYPE_TEMPERATURE_LOW          12      //低温报警
#define ALARM_TYPE_CRY                      13      //哭声报警

//MARK: NV_RESULT_FAILED 失败类型描述
#define NV_RESULT_DESC_NO_USER              1011    //用户不存在
#define NV_RESULT_DESC_PWD_ERR              1012    //密码错误
#define NV_RESULT_DESC_NO_PRI               1013    //权限不足
#define NV_RESULT_DESC_TIME_ERR             1014    //时间格式错误
#define NV_RESULT_DESC_PWD_FMT_ERR_AP       1015    //AP密码格式错误
#define NV_RESULT_DESC_PWD_FMT_ERR_STATION  1016    //Station密码格式错误
#define NV_RESULT_DESC_PWD_FMT_ERR          1017    //密码格式错误
#define NV_RESULT_ID_ERR                    1018    //ID错误
#define NV_RESULT_NO_NEW_VERSION            1019    //没有新版本
#define NV_RESULT_NET_NO_SUPORT             1020    //网络不支持
#define NV_RESULT_NO_SUPPORT_VERSION        1021    //不支持新设备，需走新协议
#define NV_RESULT_LOWPOWER_NOTSUPPORT       1022    // 低功耗不支持

//MARK: 设备网络模式
#define NV_WIFI_MODE_AP                     1001    //AP模式
#define NV_WIFI_MODE_STATION                1002    //Station模式
#define NV_WIFI_MODE_ALL                    1003    //ALL 安卓那边会发1003来切AP,IOS 没有用到
#define NV_WIFI_MODE_MESHLINK               1004    //MESHLINK模式（自组网模式）
#define NV_WIFI_SET_NO                      1000    //WiFi状态 NO
#define NV_WIFI_SET_YES                     1001    //WiFi状态 YES

//MARK: 远程配置透传
#define NV_IPC_REMOTE_GET_REQUEST   880         //获取CMD指令(互联网部分)
#define NV_IPC_REMOTE_SET_REQUEST   881         //设置CMD指令(互联网部分)
#define NV_IPC_NO_SUPORT            -100        //设备固件太老,不支持

//MARK: 对焦
#define NV_IPC_FOCUSING                         195     //对焦
#define NV_IPC_FOCUSIN                          1000    //放大(deprecate)
#define NV_IPC_FOCUSOUT                         1001    //缩小(deprecate)

//MARK: 预置位操作
#define NV_PRESET_ACTION_RESET                  102     //预置位重置
#define NV_PRESET_ACTION_LOCATION               103     //预置位位置
#define NV_PRESET_ACTION_INIT                   104     //云台一键校准

//MARK: 录像文件相关CMD
#define REC_FILE_SEARCH                     150     //录像文件搜索CMD(发请求)
#define REC_FILE_SEARCH_RESP                250     //录像文件搜索 响应CMD(收)

//MARK: 灯光相关
#define NV_IPC_LIGHT_SET_REQUEST                196     //灯光控制CMD(发请求)
#define NV_IPC_ACTION_LIGHT_ON                  1001    //开灯
#define NV_IPC_ACTION_LIGHT_OFF                 1002    //关灯
#define NV_IPC_ACTION_LIGHT_AUTO                1003    //自动
#define NV_IPC_LIGHT_SENSITY_SETTING            198     //灯光开关灵敏度控制
#define VALUE_LIGHT_SENSITIVITY_LOW             1       //灯光开关灵敏度: 低
#define VALUE_LIGHT_SENSITIVITY_NORMAL          2       //灯光开关灵敏度: 正常
#define VALUE_LIGHT_SENSITIVITY_HIGH            3       //灯光开关灵敏度: 高

//MARK: 黑白全彩切换
#define NV_IPC_FULLCOLOR_SET_REQUEST            197     //图像全彩黑白设置CMD(发请求)
#define NV_IPC_ACTION_FULLCOLOR                 1001    //全彩
#define NV_IPC_ACTION_BLACKWHITE                1002    //黑白
#define NV_IPC_ACTION_AUTO                      1003    //自动

//MARK: 移动跟踪
#define NV_IPC_STRACK_SETTING                   199     //移动跟踪CMD(发请求)
#define NV_IPC_ACTION_TRACK_SET                 1001    //设置驻点
#define NV_IPC_ACTION_TRACK_ENABLE              1002    //跟随开关设置(开启：1100，关闭：1101)
#define NV_IPC_ACTION_TRACK_ON                  1100    //跟随:开启
#define NV_IPC_ACTION_TRACK_OFF                 1101    //跟随:关闭

//MARK: 调聚焦
#define IPC_ZOOM_SETTING                        195     //调焦距CMD(发请求)
#define IPC_ZOOM_IN                             1000    //拉远
#define IPC_ZOOM_OUT                            1001    //拉近
#define IPC_ZOOM_LENS_IN                        1002    //变倍加
#define IPC_ZOOM_LENS_OUT                       1003    //变倍减
#define IPC_ZOOM_END                            1100    //变倍聚焦结束 add by qin 20210318

//MARK: 在线状态检测
#define STAT_SERVER_FAIL                        -1      //在线状态:连接失败
#define STAT_ONLINE                             1       //在线状态:互联网在线
#define STAT_OFFLINE                            0       //在线状态:互联网离线
#define STAT_UNKNOW                             10      //在线状态:未知

//MARK: 远程配置
#define CMD_MR_WAIT                     2000    //需要等待CMD(收 互联网)
#define CONFIG_RESULT_OK_MR             1001    //设置成功(互联网)
#define CONFIG_RESULT_FAIL_MR           2001    //设置失败(互联网)

//MARK: 报警状态
#define ALARM_UNKNOW                    0       //报警状态未知
#define ALARM_OFF                       1       //报警状态: 关
#define ALARM_ON                        2       //报警状态: 开

//MARK: 手机类型定义
#define PHONE_TYPE_IOS                  1011    //iOS
#define PHONE_TYPE_ANDROID              1002    //Android
#define PHONE_TYPE_WP8                  1003    //Windows Phone

//MARK: 运营商+网络类型
#define CHINA_MOBILE_WIFI               20      //中国移动WiFi
#define CHINA_MOBILE_MOBILE             21      //中国移动蜂窝数据
#define CHINA_MOBILE_4G                 22      //中国移动4G
#define CHINA_MOBILE_3G                 23      //中国移动3G
#define CHINA_MOBILE_2G                 24      //中国移动2G
#define CHINA_MOBILE_NO_CONNECT         25      //中国移动无连接
#define CHINA_MOBILE_MOBILE_UNKNOWN     26      //中国移动未知
#define CHINA_UNICOM_WIFI               27      //中国联通WiFi
#define CHINA_UNICOM_MOBILE             28      //中国联通蜂窝数据
#define CHINA_UNICOM_4G                 29      //中国联通4G
#define CHINA_UNICOM_3G                 30      //中国联通3G
#define CHINA_UNICOM_2G                 31      //中国联通2G
#define CHINA_UNICOM_NO_CONNECT         32      //中国联通无连接
#define CHINA_UNICOM_MOBILE_UNKNOWN     33      //中国联通未知
#define CHINA_TELECOM_WIFI              34      //中国电信WiFi
#define CHINA_TELECOM_MOBILE            35      //中国电信蜂窝数据
#define CHINA_TELECOM_4G                36      //中国电信4G
#define CHINA_TELECOM_3G                37      //中国电信3G
#define CHINA_TELECOM_2G                38      //中国电信2G
#define CHINA_TELECOM_NO_CONNECT        39      //中国电信无连接
#define CHINA_TELECOM_MOBILE_UNKNOWN    40      //中国电信未知
#define UNKNOWN_OPERATOR_WIFI           41      //未知运营商WiFi
#define UNKNOWN_OPERATOR_MOBILE         42      //未知运营商蜂窝数据
#define UNKNOWN_OPERATOR_4G             43      //未知运营商4G
#define UNKNOWN_OPERATOR_3G             44      //未知运营商3G
#define UNKNOWN_OPERATOR_2G             45      //未知运营商2G
#define UNKNOWN_OPERATOR_NO_CONNECT     46      //未知运营商无连接
#define UNKNOWN_OPERATOR_MOBILE_UNKNOWN 47      //未知运营商未知

//MARK: 数据流质量
#define STREAM_TYPE_SMOOTH              0       //流畅(标清)
#define STREAM_TYPE_HD                  1       //高清
#define STREAM_TYPE_AUTO                2       //自动

//MARK: 图像类型
#define VIDEO_TYPE_1080P                1000    //1080P
#define VIDEO_TYPE_720P                 1001    //720P
#define VIDEO_TYPE_D1                   1002    //D1
#define VIDEO_TYPE_VGA                  1003    //VGA
#define VIDEO_TYPE_CIF                  1004    //CIF
#define VIDEO_TYPE_QVGA                 1005    //QVGA
#define VIDEO_TYPE_QCIF                 1006    //QCIF
#define VIDEO_TYPE_960P                 1007    //960P

//MARK: 报警版本
#define ALARM_VERSION_OSS_20            20      //报警版本 V20
#define ALARM_MODEL_WIRELESS            315     //无线报警器

// MARK: 设备复合类型
/* 以下类型可以组合 */
#define DTYPE_UNKNOWN 0
    /* 个位数可选 */
    #define DTYPE_PTZ 1
    #define DTYPE_MINI 2
    #define DTYPE_NVR 3
    #define DTYPE_OUTDOOR 4
        
    /* 十位数可选 */
    #define DTYPE_4G 1
    #define DTYPE_LOWPOWER 2
#endif

#define DEVICE_NOT_UPLOAD -1
#define DEVICE_UPLOADED 0

#define DEVICE_HAS_SOFTWARE_UPDATE_UNKNOW 0
#define DEVICE_HAS_SOFTWARE_UPDATE_UNUPDATE 1
#define DEVICE_HAS_SOFTWARE_UPDATE 2

#define CAM_TYPE_NORMAL 0
#define CAM_TYPE_WALL 1
#define CAM_TYPE_CELL 2
