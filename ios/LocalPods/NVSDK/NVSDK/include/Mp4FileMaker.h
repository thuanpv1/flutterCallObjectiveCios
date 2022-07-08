#ifndef _MP4FILE_H_
#define _MP4FILE_H_


#import <Foundation/Foundation.h>

#include "MP4Defines.h"
#include "stdint.h"
#ifdef __cplusplus
extern "C" {
#endif
/* 注意:返回可用handle失败值与其他函数不一致,因为要遵循原来返回值方式,避免原来的调用者改动太多,后期建议统一化 */
// 返回一个可用handle,返回-1失败
int NVMakeMP4File(void);
// 创建writer,所有参数都不可缺,返回0失败
int NVCreateMP4File(long lMP4Handle, char *pFileName, VIDEO_TYPE enumVideoType, int width, int height, int framerate, int sampelRate, int channel);
// 关闭,save:指示文件是否需要保存
void NVCloseMP4File(long lMP4Handle, bool save);

// 写入非空视频帧,返回0失败
int NVEncodeVideoToMP4(long lMP4Handle, unsigned char *pbuff, int buffsize, int64_t lTimstamp, bool isKeyFrame);
// 写入空视频帧,返回0失败
int NVEncodeEmptyVideoToMp4(long lMP4Handle, int64_t lTimestamp);
// 写入音频帧,返回0失败
int NVEncodeAACToMP4(long lMP4Handle, unsigned char *paacbuff, int buffsize, int64_t lTimstamp);

#define MP4_Edit_Record_Save_Info {'v', '3', '8', '0'}
#define MP4_Edit_Record_Save_Pict {'p', 'i', 'c', 't'}
 
typedef enum {
    MP4_Edit_Info = 0,
    MP4_Edit_Pic,
}MP4_Edit_Type;

typedef enum {
    MP4_File_Pano = 0,
    MP4_File_Nomal,
}MP4_Edit_File_Type;

typedef
struct MP4_Edit_Arg {
    MP4_Edit_File_Type file_type;
    int pano_x;
    int pano_y;
    int pano_rad;
    int pano_width;
    int pano_height;

} MP4_Edit_Arg;


typedef struct tagMP4UserInfo {
    int nCamType;
    int nPanoX;
    int nPanoY;
    int nPanoRad;
	long long lStartTimestamp;
    int recType;
} MP4_USER_INFO, *PMP4_USER_INFO;



int addUserInfoToMP4File(const char * strFilePath, PMP4_USER_INFO pMP4UserInfo);
int getUserInfoToMP4File(const char * strFilePath, PMP4_USER_INFO pMP4UserInfo);
    
int getUserInfoToMP4Data(char *data, uint64_t length, PMP4_USER_INFO pMP4UserInfo);
#ifdef __cplusplus
} // extern "C"
#endif
#endif
