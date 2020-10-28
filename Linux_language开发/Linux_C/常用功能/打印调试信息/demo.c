#define DEBUG    
#ifdef DEBUG
    // 调试日志信息
    #define LOG_INFO(format, ...)                                                              \
    {                                                                                          \
        time_t t = time(0);                                                                    \
        struct tm ptm;                                                                         \
        memset(&ptm, 0, sizeof(ptm));                                                          \
        localtime_r(&t, &ptm);                                                                 \
        fprintf(stdout, "[ INFO ] [ %02d:%02d:%02d ] [ %s:%s:%d ] " format "",   \
                ptm.tm_hour, ptm.tm_min, ptm.tm_sec, __FILE__, __FUNCTION__ , __LINE__, ##__VA_ARGS__);     \
    }
    
    // 错误日志信息
    #define LOG_ERROR(format, ...)                                                             \
    {                                                                                          \
        time_t t = time(0);                                                                    \
        struct tm ptm;                                                                         \
        memset(&ptm, 0, sizeof(ptm));                                                          \
        localtime_r(&t, &ptm);                                                                 \
        fprintf(stderr, "[ ERROR] [ %02d:%02d:%02d ] [ %s:%s:%d ] " format "",    \
                ptm.tm_hour,  ptm.tm_min, ptm.tm_sec, __FILE__, __FUNCTION__ , __LINE__, ##__VA_ARGS__);     \
    }
 
#else
    #define LOG_INFO(format, ...)         NULL      
    #define LOG_ERROR(format, ...)     NULL      
#endif /* DEBUG */