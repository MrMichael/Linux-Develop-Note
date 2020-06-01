#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>


//RFID的IIC地址
#define RFID_Device_Addr  0xA2
//RFID的内存区域地址
#define RFID_EPCMemory   0x2000
#define RFID_TIDMemory   0x4000

#define RFID_UserMemory   0x6000

#define definitionID_Addr  RFID_UserMemory
#define ChookState_Addr   RFID_UserMemory+0x000A

#define Configuration_Word  RFID_EPCMemory+40


static int file_i2c = 0;


int RFIDInit(int iChannel, int iAddr)
{
	int rc;
	char filename[32];
	unsigned char ucTemp[2];

	sprintf(filename, "/dev/i2c-%d", iChannel);
	if ((file_i2c = open(filename, O_RDWR)) < 0)
	{
		fprintf(stderr, "Failed to open the i2c bus; not running as root?\n");
		file_i2c = 0;
		return 1;
	}

	if (ioctl(file_i2c, I2C_SLAVE, iAddr) < 0)
	{
		fprintf(stderr, "Failed to acquire bus access or talk to slave\n");
		file_i2c = 0;
		return 1;
	}

	return 0;
} 


 int iic_read(int fd, uint8_t buff[], uint16_t addr, int count)
{
	int res;
	uint8_t sendbuffer1[2];
	sendbuffer1[0]=addr>>8;
	sendbuffer1[1]=addr;
	write(fd,sendbuffer1,2);      
	res=read(fd,buff,count);
	//printf("read %d byte at 0x%x \n", res, addr);
	return res;
}


int iic_write(int fd, uint8_t buff[], uint16_t addr, int count)
{
	int res;
	int i,n;
	static uint8_t sendbuffer[100];
	memcpy(sendbuffer+2, buff, count);
	sendbuffer[0]=addr>>8;
	sendbuffer[1]=addr;
	res=write(fd,sendbuffer,count+2);
	//printf("write %d byte at 0x%x \n", res, addr);
}

int main(int argc, char *argv[])
{
	int i, j;
	int res;
	uint8_t buf[50];
	uint16_t  regaddr;

	i = RFIDInit(4, 0x51);
	if (i != 0) {
		return -1; // problem - quit
	}

	usleep(10000); // wait for data to settle for first read

	if (argc == 2 ) {
		if (strcmp(argv[1], "read") == 0) {
			regaddr = 0x2040;
			res=iic_read(file_i2c,buf,regaddr,2);
			printf("%d bytes read:",res);
			for(i=0;i<res;i++){
				printf("%02x ",buf[i]);
			}
			printf("\n");
		} else if (strcmp(argv[1], "write") == 0) {
			regaddr = 0x2004;
			buf[0]=0x30;
            buf[1]=0x31;
			buf[2]=0x32;
			res=iic_write(file_i2c,buf,regaddr,3);
			printf("%d bytes write success\n",res);
		} else if (strcmp(argv[1], "id") == 0) {
			regaddr = 0x2004;
			res=iic_read(file_i2c,buf,regaddr,3);
			printf("RFID ID: ");
			for(i=0;i<res;i++){
				printf("%02x ",buf[i]);
			}
			printf("\n");
		}

	} else {
		printf("usage: ./main [cmd] [*para]  \n");
	}

	return 0;
} /* main() */
