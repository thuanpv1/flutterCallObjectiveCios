#ifndef MP4_DEFINES_H
#define MP4_DEFINES_H

typedef struct
{
   int type;
   int size;
   unsigned char *data;
}MP4_NaluUnit;



typedef struct
{//ISO/IEC 14496-3 ADTS部分
    //adts_fixed_header
    int synword;                                        //0~11      12 bslbf
    unsigned char ID;                                   //12        1  bslbf
    unsigned char layer;                                //13~14     2  uimsbf
    unsigned char protection_absent;                    //15        1  bslbf
    unsigned char profile_ObjectType;                   //16~17     2  uimsbf
    unsigned char sampling_frequency_index;             //18~21     4  uimsbf
    unsigned char private_bit;                          //22        1  bslbf
    unsigned char channel_configuration;                //23~25     3  uimsbf
    unsigned char original_copy;                        //26        1  bslbf
    unsigned char home;                                 //27        1  bslbf
    //adts_variable_header
    unsigned char copyright_identification_bit;         //28        1  bslbf
    unsigned char copyright_identification_start;       //29        1  bslbf
    unsigned char _[1];
    int aac_frame_length;                               //30~42     13 bslbf
    int adts_buffer_fullness;                           //33~53     11 bslbf
    unsigned char number_of_raw_data_blocks_in_frame;   //54~55     2 uimsfb
    unsigned char __[3];
}ADTSHeader;


typedef enum {
      AAC_MAIN=1,
      AAC_LOW=2,
      AAC_SSR=3,
      AAC_LTP=4
  }AAC_TYPE;

	typedef enum {
      VIDEO_H264=1,
      VIDEO_H265=2,
  }VIDEO_TYPE;

	typedef enum {
		NAL_TRAIL_N    = 0,
		NAL_TRAIL_R    = 1,
		NAL_TSA_N      = 2,
		NAL_TSA_R      = 3,
		NAL_STSA_N     = 4,
		NAL_STSA_R     = 5,
		NAL_RADL_N     = 6,
		NAL_RADL_R     = 7,
		NAL_RASL_N     = 8,
		NAL_RASL_R     = 9,
		NAL_BLA_W_LP   = 16,
		NAL_BLA_W_RADL = 17,
		NAL_BLA_N_LP   = 18,
		NAL_IDR_W_RADL = 19,
		NAL_IDR_N_LP   = 20,
		NAL_CRA_NUT    = 21,
		NAL_VPS        = 32,
		NAL_SPS        = 33,
		NAL_PPS        = 34,
		NAL_AUD        = 35,
		NAL_EOS_NUT    = 36,
		NAL_EOB_NUT    = 37,
		NAL_FD_NUT     = 38,
		NAL_SEI_PREFIX = 39,
		NAL_SEI_SUFFIX = 40,
	} NALUnitType;



#endif // MP4V2_IMPL_UTIL_H
